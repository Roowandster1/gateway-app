"""
The solver. This is the actual product.

We choose how many SERVINGS of each recipe to cook this week, and how many
PACKS of each item to buy. The link between them is the constraint that you
cannot cook with more of an ingredient than the packs you bought contain.

That single constraint is what forces ingredient reuse: buying a 500g bag of
lentils for one 70g serving is wasteful, so the optimiser naturally picks a
second and third lentil meal to justify the bag.

Objective options:
  - "cheapest"  : minimise spend
  - "protein"   : maximise protein per pound, under the budget cap
"""
import pulp
from catalogue import ITEMS, RECIPES, serving_macros


def plan_week(store, budget, days=7, meals_per_day=3, max_repeat=3,
              min_protein_per_day=100, min_kcal_per_day=2000,
              max_kcal_per_day=2700, objective="protein", max_mins_per_day=75):

    dinners = [r for r in RECIPES if RECIPES[r].get("meal") != "breakfast"]
    breakfasts = [r for r in RECIPES if RECIPES[r].get("meal") == "breakfast"]
    main_servings = days * (meals_per_day - 1)

    prob = pulp.LpProblem("meal_plan", pulp.LpMaximize if objective == "protein" else pulp.LpMinimize)

    # servings of each recipe across the week
    x = {r: pulp.LpVariable(f"x_{r}", 0, max_repeat, cat="Integer") for r in RECIPES}
    # whole packs bought of each item
    y = {i: pulp.LpVariable(f"y_{i}", 0, 12, cat="Integer") for i in ITEMS}

    cost = pulp.lpSum(y[i] * ITEMS[i][store] for i in ITEMS)
    protein = pulp.lpSum(x[r] * serving_macros(r)[1] for r in RECIPES)
    kcal = pulp.lpSum(x[r] * serving_macros(r)[0] for r in RECIPES)

    # --- the pack constraint: can't cook what you didn't buy ---
    for i in ITEMS:
        used = pulp.lpSum(x[r] * RECIPES[r]["ing"].get(i, 0) for r in RECIPES)
        prob += used <= y[i] * ITEMS[i]["pack"], f"pack_{i}"

    # --- structure of the week ---
    prob += pulp.lpSum(x[r] for r in dinners) == main_servings
    prob += pulp.lpSum(x[r] for r in breakfasts) == days
    prob += cost <= budget
    prob += protein >= min_protein_per_day * days
    prob += kcal >= min_kcal_per_day * days
    prob += kcal <= max_kcal_per_day * days
    # keep total cooking time sane
    prob += pulp.lpSum(x[r] * RECIPES[r]["mins"] for r in RECIPES) <= max_mins_per_day * days
    # variety floor: at least 5 different main dishes
    z = {r: pulp.LpVariable(f"z_{r}", cat="Binary") for r in dinners}
    for r in dinners:
        prob += x[r] <= max_repeat * z[r]
        prob += x[r] >= z[r]
    prob += pulp.lpSum(z.values()) >= 5

    prob += (protein - 0.5 * cost) if objective == "protein" else cost

    status = prob.solve(pulp.PULP_CBC_CMD(msg=0))
    if pulp.LpStatus[status] != "Optimal":
        return None

    basket, spend = [], 0.0
    for i in ITEMS:
        n = int(round(y[i].value() or 0))
        if n:
            line = n * ITEMS[i][store]
            spend += line
            used = sum((x[r].value() or 0) * RECIPES[r]["ing"].get(i, 0) for r in RECIPES)
            basket.append(dict(item=ITEMS[i]["name"], aisle=ITEMS[i]["aisle"], packs=n,
                               size=ITEMS[i]["pack"], unit=ITEMS[i]["unit"], cost=line,
                               used=used, leftover=n * ITEMS[i]["pack"] - used))

    meals = [dict(name=RECIPES[r]["name"], servings=int(round(x[r].value())),
                  kcal=serving_macros(r)[0], protein=serving_macros(r)[1],
                  mins=RECIPES[r]["mins"], breakfast=RECIPES[r].get("meal") == "breakfast")
             for r in RECIPES if (x[r].value() or 0) > 0.5]

    tot_p = sum(m["servings"] * m["protein"] for m in meals)
    tot_k = sum(m["servings"] * m["kcal"] for m in meals)
    return dict(store=store, spend=spend, budget=budget, basket=basket, meals=meals,
                protein_day=tot_p / days, kcal_day=tot_k / days,
                waste=sum(b["leftover"] for b in basket if b["unit"] != "unit"))
