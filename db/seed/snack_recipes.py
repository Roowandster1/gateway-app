"""
Snacks (migration 008).

Three meals a day of the existing recipes tops out around 2400 kcal, so every
`bulk` request came back INFEASIBLE on kcal_band_low at any budget and any meal
count. The `snack` meal_slot has existed in the schema since migration 001 and
was never used; these fill it.

Chosen for calorie density per penny and for overlap with what the mains already
justify buying — peanut butter, oats, bread, cheese, eggs and bananas all earn
their packs elsewhere. Every ingredient is already priced: no new items, no new
prices, nothing invented.
"""

SNACK_RECIPES = {
    "pbbanana": dict(
        name="Peanut butter banana", mins=2, meal="snack",
        ing={"pb": 40, "banana": 1}),
    "cheesetoast": dict(
        name="Cheese on toast", mins=6, meal="snack",
        ing={"bread": 80, "cheese": 40}),
    "oatpb": dict(
        name="Oats, peanut butter & banana pot", mins=3, meal="snack",
        ing={"oats": 60, "pb": 30, "banana": 1}),
    "yogbanana": dict(
        name="Yoghurt with oats and banana", mins=3, meal="snack",
        ing={"yoghurt": 150, "oats": 40, "banana": 1}),
    "boiledeggs": dict(
        name="Boiled eggs", mins=10, meal="snack",
        ing={"eggs": 2, "bread": 40}),
}
