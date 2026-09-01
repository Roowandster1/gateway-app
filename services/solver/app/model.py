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


class _CbcViaLp(pulp.PULP_CBC_CMD):
    """
    CBC, fed an LP file instead of an MPS one.

    PuLP hands CBC an MPS file and gives no public way to ask for anything else
    (`solve_CBC(lp, use_mps=True)` — the flag exists, `actualSolve` never
    forwards it). For most models that is invisible. For at least one of ours it
    is a segmentation fault:

        cbc bulk-7day.mps -sec 45 -branch -solution out.sol   -> SIGSEGV
        cbc bulk-7day.lp  -sec 45 -branch -solution out.sol   -> Optimal, 15s

    Same model, same flags, same binary. The bug is in CBC's MPS reader, not in
    the model, and it is deterministic — 'aldi | 7 days | bulk | no filters'
    crashed it on every run, which is why retrying the call never helped and
    only made the export take three times as long to fail.

    An LP file also keeps our own variable names, where MPS renames them to
    X0001 for the wire, so a crash left behind by some later model will at least
    name what it was carrying.
    """

    def actualSolve(self, lp, **kwargs):
        kwargs.setdefault("use_mps", False)
        return self.solve_CBC(lp, **kwargs)


def _cbc() -> pulp.LpSolver:
    return _CbcViaLp(msg=0, timeLimit=config.SOLVE_TIMEOUT_SECONDS)


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
    max_snacks_per_day: float = config.DEFAULT_MAX_SNACKS_PER_DAY
    min_distinct_mains: int = config.DEFAULT_MIN_DISTINCT_MAINS
    min_distinct_proteins: int = config.DEFAULT_MIN_DISTINCT_PROTEINS
    pantry: dict[str, float] | None = None
    exclude_items: tuple[str, ...] = ()
    exclude_recipes: tuple[str, ...] = ()
    # `protein` is the shipped default, and the reason is the budget slider.
    #
    # `cheapest` looked like the honest choice for a budgeting app until it was
    # measured: it spends the floor and nothing more, so at Aldi every budget from
    # £25 to £60 returns the same £21.32 plan. The app's central input would do
    # nothing above the floor. Under `protein` the budget does real work —
    # £25 -> £24.43 at 132g/day, £30 -> £29.44 at 144g, £40 -> £32.72 at 147g —
    # and then it stops and hands the rest back, which is exactly the behaviour
    # CLAUDE.md says to preserve.
    #
    # `cheapest` stays available, and is what /floor uses to price the floor.
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
    consumed_value: float      # spend minus what stays in the cupboard: the food
                               # this period actually cost. On a 1-day plan the two
                               # differ by 80%, and showing only `spend` reads as
                               # "£15 for one day".
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


class Infeasible(Exception):
    def __init__(self, binding: str = "unknown", suggestion: str = "",
                 min_feasible_budget: float | None = None,
                 also_binding: list[str] | None = None):
        self.binding = binding
        self.suggestion = suggestion
        self.min_feasible_budget = min_feasible_budget
        # Constraints can bind jointly — asking for 12 distinct mains also puts
        # the protein floor out of reach. Reporting only the largest slack would
        # send the user to fix one thing and hit the other immediately.
        self.also_binding = also_binding or []
        super().__init__(suggestion or f"no feasible plan (binding: {binding})")


@dataclass
class _Built:
    """One assembled model, shared by the plan solve, the diagnosis and the
    cheapest-budget search so all three see exactly the same constraints."""
    prob: pulp.LpProblem
    items: dict
    recipes: dict
    params: "SolveParams"
    carries: dict
    pantry: dict
    x: dict
    y: dict
    leftover: dict
    z: dict
    protein: object
    kcal: object
    pack_cost: object
    net_cost: object
    slacks: dict          # constraint name -> (slack var, scale for normalising)


def _prepare(items, recipes, params):
    p = params
    items = {s: it for s, it in items.items() if s not in p.exclude_items}
    recipes = {
        s: r for s, r in recipes.items()
        if s not in p.exclude_recipes and set(r.ingredients) <= set(items)
    }
    if not recipes:
        raise Infeasible("catalogue", "No recipes are available after exclusions.")
    carries = {s: it.carries(p.days, config.CARRY_BY_SHELF_LIFE) for s, it in items.items()}
    pantry = {s: q for s, q in (p.pantry or {}).items()
              if s in items and carries[s] and q > 0}
    return items, recipes, carries, pantry


def _build(items, recipes, params, *, elastic=False, enforce_budget=True) -> _Built:
    """
    Assemble the model.

    elastic=True adds a slack variable to every constraint a user could
    plausibly relax. Minimising the slacks then names the binding constraint:
    CBC cannot tell you that directly, because an infeasible integer program has
    no dual and PuLP exposes no irreducible infeasible subset.
    """
    p = params
    items, recipes, carries, pantry = _prepare(items, recipes, params)

    mains = [s for s, r in recipes.items() if r.meal_slot == "main"]
    breakfasts = [s for s, r in recipes.items() if r.meal_slot == "breakfast"]
    snacks = [s for s, r in recipes.items() if r.meal_slot == "snack"]
    main_servings = p.days * (p.meals_per_day - 1) * p.household_size
    breakfast_servings = p.days * p.household_size

    prob = pulp.LpProblem("meal_plan", pulp.LpMinimize)

    def repeat_cap(slug):
        mult = config.SNACK_REPEAT_MULTIPLIER if recipes[slug].meal_slot == "snack" else 1
        return p.max_repeat * p.household_size * mult

    x = {s: pulp.LpVariable(f"x_{s}", 0, repeat_cap(s), cat="Integer") for s in recipes}
    y = {s: pulp.LpVariable(f"y_{s}", 0, config.MAX_PACKS_PER_ITEM, cat="Integer")
         for s in items}
    leftover = {s: pulp.LpVariable(f"L_{s}", 0, cat="Continuous") for s in items}

    used = {s: pulp.lpSum(x[r] * recipes[r].ingredients.get(s, 0) for r in recipes)
            for s in items}
    bought = {s: y[s] * items[s].pack_size for s in items}

    slacks: dict = {}

    def slack(name, scale):
        """A shortfall/overshoot allowance, normalised so £, grams and minutes
        are comparable when we minimise them together."""
        if not elastic:
            return 0
        v = pulp.LpVariable(f"slack_{name}", 0, cat="Continuous")
        slacks[name] = (v, max(scale, 1e-6))
        return v

    # --- the pack constraint: you cannot cook what you did not buy or own ----
    for s in items:
        prob += used[s] <= bought[s] + pantry.get(s, 0), f"pack_{s}"
        if carries[s]:
            prob += leftover[s] <= bought[s], f"left_bought_{s}"
            prob += leftover[s] <= bought[s] + pantry.get(s, 0) - used[s], f"left_net_{s}"
        else:
            prob += leftover[s] == bought[s] - used[s], f"left_waste_{s}"

    # --- structure of the week ----------------------------------------------
    # Elastic as a SHORTFALL only: the failure mode is a recipe set too small to
    # fill the slots (three breakfasts cannot cover fourteen days), never a
    # surplus of meals.
    prob += (pulp.lpSum(x[s] for s in mains)
             >= main_servings - slack("main_recipe_supply", main_servings)), "main_lo"
    prob += pulp.lpSum(x[s] for s in mains) <= main_servings, "main_hi"
    prob += (pulp.lpSum(x[s] for s in breakfasts)
             >= breakfast_servings
             - slack("breakfast_recipe_supply", breakfast_servings)), "breakfast_lo"
    prob += pulp.lpSum(x[s] for s in breakfasts) <= breakfast_servings, "breakfast_hi"

    # Snacks are optional extras, not one of meals_per_day. They exist so a high
    # calorie target is reachable at all: three meals a day of these recipes tops
    # out around 2400 kcal, which made every `bulk` request infeasible on
    # kcal_band_low no matter the budget. Capped so the solver cannot answer a
    # calorie floor with an unbounded pile of peanut butter.
    if snacks:
        prob += (pulp.lpSum(x[s] for s in snacks)
                 <= p.max_snacks_per_day * p.days * p.household_size), "max_snacks"

    protein = pulp.lpSum(x[s] * recipes[s].macros(items)[1] for s in recipes)
    kcal = pulp.lpSum(x[s] * recipes[s].macros(items)[0] for s in recipes)
    pack_cost = pulp.lpSum(y[s] * items[s].price for s in items)

    scale = p.days * p.household_size
    if enforce_budget:
        prob += pack_cost <= p.budget + slack("budget", p.budget), "budget"
    prob += (protein >= p.min_protein_per_day * scale
             - slack("min_protein_per_day", p.min_protein_per_day * scale)), "min_protein_per_day"
    prob += (kcal >= p.kcal_band[0] * scale
             - slack("kcal_band_low", p.kcal_band[0] * scale)), "min_kcal_per_day"
    prob += (kcal <= p.kcal_band[1] * scale
             + slack("kcal_band_high", p.kcal_band[1] * scale)), "max_kcal_per_day"

    cooks = {s: pulp.LpVariable(f"c_{s}", 0, cat="Integer") for s in recipes}
    for s in recipes:
        prob += cooks[s] * p.household_size >= x[s], f"cooks_{s}"
    cook_budget = p.max_cook_minutes_per_day * p.days
    prob += (pulp.lpSum(cooks[s] * recipes[s].minutes for s in recipes)
             <= cook_budget
             + slack("max_cook_minutes_per_day", cook_budget)), "max_cook_minutes_per_day"

    z = {s: pulp.LpVariable(f"z_{s}", cat="Binary") for s in mains}
    for s in mains:
        prob += x[s] <= p.max_repeat * p.household_size * z[s]
        prob += x[s] >= z[s]
    # A variety floor above the number of main meals is not a preference, it is
    # arithmetic: you cannot eat five different dinners across two meals. Asking
    # for it used to make every 1- and 2-day plan infeasible on min_distinct_mains.
    # Clamp to what the plan can physically hold, and to the recipes available.
    distinct_floor = max(1, min(p.min_distinct_mains, main_servings, len(mains)))
    prob += (pulp.lpSum(z.values()) >= distinct_floor
             - slack("min_distinct_mains", distinct_floor)), "min_distinct_mains"

    # Distinct *recipes* stopped meaning distinct *dinners* once the catalogue
    # went from 24 hand-written recipes to 338 generated ones. Five different
    # rows can now be lentils five different ways — "Lentil & carrot" and
    # "Lentil & carrot rice (big portion)" both counted, and a week of that is
    # not variety however the constraint scores it.
    #
    # So the floor is also applied to the protein a main is built on. This is a
    # constraint, not a preference in the objective: the solver may not buy its
    # way out of it, and it says so if it cannot be met.
    by_protein: dict[str, list[str]] = {}
    for s in mains:
        key = recipes[s].main_protein or s
        by_protein.setdefault(key, []).append(s)
    if len(by_protein) > 1:
        w = {k: pulp.LpVariable(f"w_{k}", cat="Binary") for k in by_protein}
        for key, slugs in by_protein.items():
            for s in slugs:
                prob += w[key] >= z[s]
            prob += w[key] <= pulp.lpSum(z[s] for s in slugs)
        protein_floor = max(1, min(p.min_distinct_proteins, main_servings, len(by_protein)))
        prob += (pulp.lpSum(w.values()) >= protein_floor
                 - slack("min_distinct_proteins", protein_floor)), "min_distinct_proteins"

    carry_credit = config.CARRY_VALUE * pulp.lpSum(
        leftover[s] * items[s].unit_cost for s in items if carries[s])
    waste_cost = config.WASTE_PENALTY * pulp.lpSum(
        leftover[s] * items[s].unit_cost for s in items if not carries[s])
    net_cost = pack_cost - carry_credit + waste_cost

    return _Built(prob=prob, items=items, recipes=recipes, params=params,
                  carries=carries, pantry=pantry, x=x, y=y, leftover=leftover, z=z,
                  protein=protein, kcal=kcal, pack_cost=pack_cost, net_cost=net_cost,
                  slacks=slacks)


def solve_plan(items: dict[str, Item], recipes: dict[str, Recipe],
               params: SolveParams) -> Plan:
    b = _build(items, recipes, params)
    prob, p = b.prob, params

    # --- objective (SPEC §3(d)) ---------------------------------------------
    # The problem is built as a minimisation, so the protein and variety
    # objectives are negated rather than flipping the sense.
    if p.objective == "protein":
        # Prototype behaviour, preserved deliberately: CLAUDE.md is explicit that
        # handing money back when the remaining budget buys nothing worth having
        # is a feature, not a bug to be fixed.
        prob += config.PROTEIN_COST_WEIGHT * b.net_cost - b.protein
    elif p.objective == "variety":
        prob += b.net_cost - pulp.lpSum(b.z.values()) * 100
    else:  # "cheapest"
        prob += b.net_cost

    status = prob.solve(_cbc())

    # A time limit is not an infeasibility, and reporting one as the other is
    # the single thing SPEC §2 says an infeasible answer must never do. CBC
    # returns "Not Solved" when it runs out of time, and the catalogue growing
    # from 24 recipes to 223 made that reachable: the diagnosis then invented a
    # binding constraint for a problem that has a perfectly good answer.
    #
    # If CBC found *an* incumbent before the clock ran out, that plan is real —
    # every constraint holds, it is just not proved optimal — so it is returned.
    # Only a run with no incumbent at all is handed to the diagnosis.
    state = pulp.LpStatus[status]
    if state != "Optimal":
        # "Infeasible" is a proof and must be diagnosed. "Not Solved" is a clock,
        # and CBC leaves the relaxation's values in the variables either way — so
        # the status, not the variable values, is what separates them.
        if state in ("Not Solved", "Undefined") and _has_incumbent(b.x, b.y):
            return _extract(b.items, b.recipes, params, b.carries, b.pantry,
                            b.x, b.y, prob)
        raise diagnose(items, recipes, params)

    return _extract(b.items, b.recipes, params, b.carries, b.pantry, b.x, b.y, prob)


def _has_incumbent(x, y) -> bool:
    """
    Did CBC find a whole-number plan before the clock ran out?

    Servings and pack counts are integer variables, so a fractional value means
    this is the LP relaxation rather than a plan anyone could shop — that is not
    an incumbent, and returning it would hand someone 2.4 bags of rice.
    """
    served = [float(v.value() or 0.0) for v in x.values()]
    bought = [float(v.value() or 0.0) for v in y.values()]
    if sum(served) <= 0.0 or sum(bought) <= 0.0:
        return False
    return all(abs(v - round(v)) < 1e-6 for v in served + bought)


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
                          image_url=recipes[s].image_url,
                          kcal_per_serving=round(kcal, 1),
                          protein_per_serving=round(protein, 1)))

    tot_p = sum(m["servings"] * m["protein_per_serving"] for m in meals)
    tot_k = sum(m["servings"] * m["kcal_per_serving"] for m in meals)
    denom = params.days * params.household_size
    cupboard = sum(q * items[s].unit_cost for s, q in closing.items())

    return Plan(
        store=params.store, budget=params.budget, spend=round(spend, 2),
        consumed_value=round(spend - carry_value, 2),
        carry_over_value=round(carry_value, 2), wasted_value=round(waste_value, 2),
        cupboard_value=round(cupboard, 2),
        protein_per_day=round(tot_p / denom, 1), kcal_per_day=round(tot_k / denom, 1),
        meals=sorted(meals, key=lambda m: -m["servings"]),
        basket=sorted(basket, key=lambda b: (b.aisle, b.name)),
        closing_pantry=closing,
    )


# --- infeasibility as a feature (SPEC §2) ----------------------------------
#
# "Your budget doesn't work at this store" is a legitimate and valuable answer,
# so it gets the same care as a successful plan: name what broke, and say what
# the week would actually cost.

_PLAIN_ENGLISH = {
    "budget": "The budget is the binding constraint.",
    "min_protein_per_day": "The protein floor is what cannot be met.",
    "kcal_band_low": "The calorie floor cannot be reached.",
    "kcal_band_high": "The calorie ceiling is too low for these meals.",
    "max_cook_minutes_per_day": "The cooking-time ceiling is what cannot be met.",
    "min_distinct_mains": "There are not enough distinct main dishes available.",
    "min_distinct_proteins": "The mains available are all built on too few "
                             "different proteins.",
    "main_recipe_supply": "There are not enough main recipes to fill that many days.",
    "breakfast_recipe_supply": "There are not enough breakfast recipes to fill that many days.",
}


def cheapest_feasible_budget(items, recipes, params) -> float | None:
    """
    The cheapest week that still meets every nutrition and structure constraint,
    found by dropping the budget cap and minimising till spend. Returns None when
    the plan is impossible for a reason money cannot fix.
    """
    b = _build(items, recipes, params, enforce_budget=False)
    b.prob += b.pack_cost
    status = b.prob.solve(_cbc())
    if pulp.LpStatus[status] != "Optimal":
        return None
    return round(float(pulp.value(b.pack_cost)), 2)


def diagnose(items, recipes, params) -> Infeasible:
    """
    Identify the binding constraint, then price the cheapest week that would work.

    Every relaxable constraint gets a slack variable, each normalised by its own
    right-hand side so pounds, grams, calories and minutes are comparable. We
    then minimise the total normalised slack: the smallest set of relaxations
    that restores feasibility. Whichever slack comes back largest is what is
    actually blocking the plan.
    """
    b = _build(items, recipes, params, elastic=True)
    b.prob += pulp.lpSum(v * (1.0 / scale) for v, scale in b.slacks.values())
    status = b.prob.solve(_cbc())

    if pulp.LpStatus[status] != "Optimal":
        # Even fully relaxed it will not solve — the catalogue itself is the problem.
        return Infeasible("catalogue",
                          "No plan is possible from the current catalogue and recipes.")

    violated = sorted(
        (((v.value() or 0.0) / scale, name, (v.value() or 0.0))
         for name, (v, scale) in b.slacks.items()),
        reverse=True,
    )
    relative, binding, absolute = violated[0]
    if relative <= 1e-6:
        return Infeasible("unknown",
                          "The solver could not find a plan, but no single "
                          "constraint appears to be binding.")

    floor = cheapest_feasible_budget(items, recipes, params)
    p = params
    store = p.store.title()

    if binding == "budget" and floor is not None:
        suggestion = (f"£{p.budget:.2f} is not enough at {store}. "
                      f"£{floor:.2f} is the cheapest feasible week there for these targets.")
    else:
        suggestion = _PLAIN_ENGLISH.get(binding, f"{binding} is the binding constraint.")
        suggestion = f"{suggestion} " + _detail(binding, absolute, params)
        if floor is not None:
            suggestion += f" The cheapest week meeting these targets at {store} is £{floor:.2f}."
        else:
            suggestion += " No budget makes this work — the targets themselves need to move."

    also = [n for rel, n, _ in violated[1:] if rel > 1e-6]
    if also:
        names = " and ".join(_PLAIN_ENGLISH.get(n, n).rstrip(".").lower() for n in also)
        suggestion += f" Note that {names} — both have to move."

    return Infeasible(binding, suggestion, floor, also)


def _detail(binding, absolute, params) -> str:
    p = params
    scale = p.days * p.household_size
    if binding == "min_protein_per_day":
        short = absolute / scale
        return (f"It falls {short:.0f}g/day short of {p.min_protein_per_day:.0f}g — "
                f"about {p.min_protein_per_day - short:.0f}g/day is reachable.")
    if binding == "breakfast_recipe_supply":
        return (f"{absolute:.0f} of the {p.days * p.household_size} breakfast servings "
                f"cannot be filled without repeating a recipe more than {p.max_repeat} times.")
    if binding == "main_recipe_supply":
        return (f"{absolute:.0f} of the {p.days * (p.meals_per_day - 1) * p.household_size} "
                f"main servings cannot be filled at max_repeat {p.max_repeat}.")
    if binding == "max_cook_minutes_per_day":
        return (f"It needs about {absolute / p.days:.0f} more minutes a day than the "
                f"{p.max_cook_minutes_per_day:.0f} allowed.")
    if binding == "min_distinct_mains":
        return f"About {absolute:.0f} fewer distinct mains than requested are achievable."
    if binding == "min_distinct_proteins":
        return (f"About {absolute:.0f} fewer different proteins than requested are "
                f"achievable across the mains.")
    if binding in ("kcal_band_low", "kcal_band_high"):
        return f"It misses the band by roughly {absolute / scale:.0f} kcal/day."
    return ""
