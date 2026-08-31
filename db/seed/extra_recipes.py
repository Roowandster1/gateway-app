"""
Additional breakfasts (migration 006).

Three breakfast recipes cannot fill fourteen days at max_repeat 3 — the solver
reports `breakfast_recipe_supply` and a 2-week plan is impossible. Seven can.

Every ingredient here is already in the priced catalogue: no new items, so no
new prices, so nothing invented (CLAUDE.md rule 3). They are also chosen for
overlap with the existing mains — bread, eggs, cheese, beans, tortilla and
yoghurt all already earn their packs elsewhere, which is what the optimiser
trades on.
"""

EXTRA_RECIPES = {
    "pbtoast": dict(
        name="Peanut butter toast & banana", mins=5, meal="breakfast",
        ing={"bread": 90, "pb": 30, "banana": 1}),
    "beanstoast": dict(
        name="Beans on toast with cheese", mins=10, meal="breakfast",
        ing={"beans": 205, "bread": 90, "cheese": 25}),
    "eggwrap": dict(
        name="Egg & cheese breakfast wrap", mins=10, meal="breakfast",
        ing={"eggs": 2, "tortilla": 112, "cheese": 25, "oil": 6}),
    "oatpancake": dict(
        name="Oat pancakes with yoghurt", mins=15, meal="breakfast",
        ing={"oats": 90, "eggs": 1, "milk": 120, "yoghurt": 100, "oil": 6}),
}
