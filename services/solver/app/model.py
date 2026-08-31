"""
The optimiser. This is the product.

We choose how many SERVINGS of each recipe to cook, and how many PACKS of each
item to buy. The link is the constraint that you cannot cook with more of an
ingredient than the packs you bought contain, plus whatever the cupboard already
holds. That single constraint is what forces ingredient reuse.

SPEC §3 additions over prototype/solver.py:
  b) pantry stock is free — packs are bought on the remainder
  c) leftover splits into carry-over (an asset) and waste (dead money)
  d) the objective values the first and punishes the second

The carry/waste split is decided per item by data (shelf life vs horizon), not
by a decision variable, so the whole model stays linear.
"""
from dataclasses import dataclass

import pulp

from . import config
from .domain import Item, Recipe


@dataclass
class SolveParams:
    store: str
    budget: float
    days: int = config.DEFAULT_DAYS
    meals_per_day: int = config.DEFAULT_MEALS_PER_DAY
    household_size: int = 1
    min_protein_per_day: float = config.DEFAULT_MIN_PROTEIN_PER_DAY
    kcal_band: tuple[float, float] = config.DEFAULT_KCAL_BAND
    max_cook_minutes_per_day: float = config.DEFAULT_MAX_COOK_MINUTES_PER_DAY
    max_repeat: int = config.DEFAULT_MAX_REPEAT
    min_distinct_mains: int = config.DEFAULT_MIN_DISTINCT_MAINS
    pantry: dict[str, float] | None = None
    exclude_items: tuple[str, ...] = ()
    exclude_recipes: tuple[str, ...] = ()
    objective: str = "protein"


@dataclass
class BasketLine:
    item: str
    name: str
    aisle: str
    unit: str
    packs: int
    pack_size: float
    unit_price: float
    line_cost: float
    qty_from_pantry: float
    qty_used: float
    qty_carry_over: float
    qty_wasted: float
    carries: bool


@dataclass
class Plan:
    store: str
    budget: float
    spend: float               # till spend: sum of packs x price. The honest number.
    carry_over_value: float    # value of NEW leftover this shop leaves behind
    wasted_value: float        # value of leftover that will rot
    cupboard_value: float      # value of the whole closing pantry
    protein_per_day: float
    kcal_per_day: float
    meals: list[dict]
    basket: list[BasketLine]
    closing_pantry: dict[str, float]


class Infeasible(Exception):
    def __init__(self, binding: str = "unknown"):
        self.binding = binding
        super().__init__(f"no feasible plan (binding: {binding})")


def solve_plan(items: dict[str, Item], recipes: dict[str, Recipe],
               params: SolveParams) -> Plan:
    p = params
    horizon = p.days
    pantry = dict(p.pantry or {})

    items = {s: it for s, it in items.items() if s not in p.exclude_items}
    recipes = {
        s: r for s, r in recipes.items()
        if s not in p.exclude_recipes and set(r.ingredients) <= set(items)
    }
    if not recipes:
        raise Infeasible("no recipes available after exclusions")

    carries = {s: it.carries(horizon, config.CARRY_BY_SHELF_LIFE) for s, it in items.items()}

    # Stock that cannot survive a week was never really in the cupboard.
    # Dropping it here keeps `leftover_from_packs` exact for non-carrying items.
    pantry = {s: q for s, q in pantry.items() if s in items and carries[s] and q > 0}

    mains = [s for s, r in recipes.items() if r.meal_slot != "breakfast"]
    breakfasts = [s for s, r in recipes.items() if r.meal_slot == "breakfast"]
    main_servings = p.days * (p.meals_per_day - 1) * p.household_size
    breakfast_servings = p.days * p.household_size

    sense = pulp.LpMaximize if p.objective == "protein" else pulp.LpMinimize
    prob = pulp.LpProblem("meal_plan", sense)

    # --- decision variables -------------------------------------------------
    # servings cooked of each recipe; max_repeat counts MEALS, so a household of
    # four eating chilli three times is 12 servings, not 3.
    x = {s: pulp.LpVariable(f"x_{s}", 0, p.max_repeat * p.household_size, cat="Integer")
         for s in recipes}
    # whole packs bought
    y = {s: pulp.LpVariable(f"y_{s}", 0, config.MAX_PACKS_PER_ITEM, cat="Integer")
         for s in items}
    # leftover attributable to packs bought THIS week (SPEC §3(b): pantry is free,
    # so pantry stock is not re-credited every week it sits there)
    leftover = {s: pulp.LpVariable(f"L_{s}", 0, cat="Continuous") for s in items}

    used = {s: pulp.lpSum(x[r] * recipes[r].ingredients.get(s, 0) for r in recipes)
            for s in items}
    bought = {s: y[s] * items[s].pack_size for s in items}

    # --- the pack constraint: you cannot cook what you did not buy or own ----
    for s in items:
        prob += used[s] <= bought[s] + pantry.get(s, 0), f"pack_{s}"

        # leftover = bought - max(0, used - pantry), linearised.
        #
        # The two cases are NOT symmetric, and getting this wrong silently
        # disables SPEC §3(d):
        #
        #   carrying items are CREDITED, so the objective pushes L up and it
        #   settles at min(bought, bought + pantry - used) on its own. Upper
        #   bounds are enough.
        #
        #   non-carrying items are PENALISED, so the objective pushes L down.
        #   With upper bounds alone it would sit at zero and the model would
        #   never see the waste it was about to create. It has to be pinned.
        #   Pantry holds no non-carrying stock, so bought - used is exact.
        if carries[s]:
            prob += leftover[s] <= bought[s], f"left_bought_{s}"
            prob += leftover[s] <= bought[s] + pantry.get(s, 0) - used[s], f"left_net_{s}"
        else:
            prob += leftover[s] == bought[s] - used[s], f"left_waste_{s}"

    # --- structure of the week ----------------------------------------------
    prob += pulp.lpSum(x[s] for s in mains) == main_servings, "main_count"
    prob += pulp.lpSum(x[s] for s in breakfasts) == breakfast_servings, "breakfast_count"

    protein = pulp.lpSum(x[s] * recipes[s].macros(items)[1] for s in recipes)
    kcal = pulp.lpSum(x[s] * recipes[s].macros(items)[0] for s in recipes)
    pack_cost = pulp.lpSum(y[s] * items[s].price for s in items)

    prob += pack_cost <= p.budget, "budget"
    prob += protein >= p.min_protein_per_day * p.days * p.household_size, "min_protein_per_day"
    prob += kcal >= p.kcal_band[0] * p.days * p.household_size, "min_kcal_per_day"
    prob += kcal <= p.kcal_band[1] * p.days * p.household_size, "max_kcal_per_day"

    # Cook time is per COOK, not per serving: one pan of chilli for four is one
    # cook. SPEC §7 asks for household scaling to be explicit rather than linear.
    cooks = {s: pulp.LpVariable(f"c_{s}", 0, cat="Integer") for s in recipes}
    for s in recipes:
        prob += cooks[s] * p.household_size >= x[s], f"cooks_{s}"
    prob += (pulp.lpSum(cooks[s] * recipes[s].minutes for s in recipes)
             <= p.max_cook_minutes_per_day * p.days), "max_cook_minutes_per_day"

    # variety floor
    z = {s: pulp.LpVariable(f"z_{s}", cat="Binary") for s in mains}
    for s in mains:
        prob += x[s] <= p.max_repeat * p.household_size * z[s]
        prob += x[s] >= z[s]
    prob += pulp.lpSum(z.values()) >= p.min_distinct_mains, "min_distinct_mains"

    # --- objective (SPEC §3(d)) ---------------------------------------------
    carry_credit = config.CARRY_VALUE * pulp.lpSum(
        leftover[s] * items[s].unit_cost for s in items if carries[s])
    waste_cost = config.WASTE_PENALTY * pulp.lpSum(
        leftover[s] * items[s].unit_cost for s in items if not carries[s])
    net_cost = pack_cost - carry_credit + waste_cost

    if p.objective == "protein":
        # Prototype behaviour, preserved deliberately: CLAUDE.md is explicit that
        # handing money back when the remaining budget buys nothing worth having
        # is a feature, not a bug to be fixed.
        prob += protein - config.PROTEIN_COST_WEIGHT * net_cost
    elif p.objective == "variety":
        prob += pulp.lpSum(z.values()) * 100 - net_cost
    else:  # "cheapest"
        prob += net_cost

    status = prob.solve(pulp.PULP_CBC_CMD(msg=0, timeLimit=config.SOLVE_TIMEOUT_SECONDS))
    if pulp.LpStatus[status] != "Optimal":
        raise Infeasible(pulp.LpStatus[status])

    return _extract(items, recipes, params, carries, pantry, x, y, prob)


def _extract(items, recipes, params, carries, pantry, x, y, prob) -> Plan:
    val = lambda v: float(v.value() or 0.0)  # noqa: E731

    servings = {s: int(round(val(x[s]))) for s in recipes}
    servings = {s: n for s, n in servings.items() if n > 0}

    spend = 0.0
    carry_value = waste_value = 0.0
    basket: list[BasketLine] = []
    closing: dict[str, float] = {}

    for s, it in items.items():
        packs = int(round(val(y[s])))
        used = sum(n * recipes[r].ingredients.get(s, 0) for r, n in servings.items())
        have = pantry.get(s, 0.0)

        # Pantry is drawn down first — it is free (SPEC §3(b)).
        from_pantry = min(have, used)
        from_packs = used - from_pantry
        bought = packs * it.pack_size
        new_leftover = round(bought - from_packs, 6)

        if carries[s]:
            carry_over, wasted = new_leftover, 0.0
            kept = (have - from_pantry) + new_leftover
            if kept > 0:
                closing[s] = round(kept, 4)
        else:
            carry_over, wasted = 0.0, new_leftover

        if packs == 0 and used == 0:
            continue

        line_cost = packs * it.price
        spend += line_cost
        carry_value += carry_over * it.unit_cost
        waste_value += wasted * it.unit_cost

        basket.append(BasketLine(
            item=s, name=it.name, aisle=it.aisle, unit=it.unit,
            packs=packs, pack_size=it.pack_size, unit_price=it.price,
            line_cost=round(line_cost, 2),
            qty_from_pantry=round(from_pantry, 2), qty_used=round(used, 2),
            qty_carry_over=round(carry_over, 2), qty_wasted=round(wasted, 2),
            carries=carries[s],
        ))

    meals = []
    for s, n in servings.items():
        kcal, protein = recipes[s].macros(items)
        meals.append(dict(recipe=s, name=recipes[s].name, servings=n,
                          slot=recipes[s].meal_slot, minutes=recipes[s].minutes,
                          kcal_per_serving=round(kcal, 1),
                          protein_per_serving=round(protein, 1)))

    tot_p = sum(m["servings"] * m["protein_per_serving"] for m in meals)
    tot_k = sum(m["servings"] * m["kcal_per_serving"] for m in meals)
    denom = params.days * params.household_size
    cupboard = sum(q * items[s].unit_cost for s, q in closing.items())

    return Plan(
        store=params.store, budget=params.budget, spend=round(spend, 2),
        carry_over_value=round(carry_value, 2), wasted_value=round(waste_value, 2),
        cupboard_value=round(cupboard, 2),
        protein_per_day=round(tot_p / denom, 1), kcal_per_day=round(tot_k / denom, 1),
        meals=sorted(meals, key=lambda m: -m["servings"]),
        basket=sorted(basket, key=lambda b: (b.aisle, b.name)),
        closing_pantry=closing,
    )
