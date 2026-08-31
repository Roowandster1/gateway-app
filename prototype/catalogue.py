"""
Catalogue: the atoms of the system.

KEY IDEA: an item is bought as a PACK, not per gram.
`pack_size` is in the item's unit; `price` is for the whole pack.
Prices are seed estimates and are meant to be corrected in-app.
"""

# unit: 'g' | 'ml' | 'unit'
# macros are per 100g (or per unit where unit=='unit')
ITEMS = {
    # --- carbs / staples ---
    "pasta":      dict(name="Penne pasta",        unit="g", pack=500,  aldi=0.45, tesco=0.55, kcal=352, protein=12.0, aisle="Pasta & rice"),
    "rice":       dict(name="Long grain rice",    unit="g", pack=1000, aldi=0.75, tesco=0.90, kcal=349, protein=7.0,  aisle="Pasta & rice"),
    "noodles":    dict(name="Egg noodles",        unit="g", pack=375,  aldi=0.75, tesco=0.90, kcal=360, protein=12.0, aisle="Pasta & rice"),
    "oats":       dict(name="Porridge oats",      unit="g", pack=1000, aldi=0.90, tesco=1.15, kcal=356, protein=11.0, aisle="Cereals"),
    "bread":      dict(name="Wholemeal loaf",     unit="g", pack=800,  aldi=0.75, tesco=0.95, kcal=236, protein=9.5,  aisle="Bakery"),
    "potato":     dict(name="White potatoes",     unit="g", pack=2500, aldi=1.65, tesco=1.95, kcal=77,  protein=2.0,  aisle="Fresh produce"),
    "tortilla":   dict(name="Tortilla wraps x8",  unit="g", pack=448,  aldi=0.85, tesco=1.10, kcal=300, protein=8.5,  aisle="Bakery"),

    # --- protein ---
    "chicken":    dict(name="Chicken thigh fillets", unit="g", pack=650, aldi=3.29, tesco=3.95, kcal=177, protein=19.0, aisle="Meat & fish"),
    "mince":      dict(name="Beef mince 20%",     unit="g", pack=500,  aldi=2.79, tesco=3.35, kcal=250, protein=18.0, aisle="Meat & fish"),
    "eggs":       dict(name="Eggs (large)",       unit="unit", pack=15, aldi=1.99, tesco=2.45, kcal=78, protein=6.5,  aisle="Dairy & eggs"),
    "tuna":       dict(name="Tuna chunks 145g",   unit="g", pack=145,  aldi=0.85, tesco=1.05, kcal=99,  protein=23.5, aisle="Tins"),
    "lentils":    dict(name="Red split lentils",  unit="g", pack=500,  aldi=0.99, tesco=1.25, kcal=352, protein=24.0, aisle="Tins & pulses"),
    "chickpeas":  dict(name="Chickpeas 400g tin", unit="g", pack=400,  aldi=0.39, tesco=0.49, kcal=115, protein=7.0,  aisle="Tins & pulses"),
    "kidney":     dict(name="Kidney beans 400g",  unit="g", pack=400,  aldi=0.39, tesco=0.49, kcal=100, protein=6.9,  aisle="Tins & pulses"),
    "beans":      dict(name="Baked beans 410g",   unit="g", pack=410,  aldi=0.35, tesco=0.45, kcal=82,  protein=4.7,  aisle="Tins & pulses"),
    "cheese":     dict(name="Mature cheddar",     unit="g", pack=400,  aldi=2.69, tesco=3.25, kcal=416, protein=25.0, aisle="Dairy & eggs"),
    "pb":         dict(name="Peanut butter",      unit="g", pack=340,  aldi=1.39, tesco=1.70, kcal=600, protein=25.0, aisle="Spreads"),
    "milk":       dict(name="Semi-skimmed milk",  unit="ml", pack=2272, aldi=1.45, tesco=1.55, kcal=50, protein=3.6,  aisle="Dairy & eggs"),
    "yoghurt":    dict(name="Natural yoghurt 1kg",unit="g", pack=1000, aldi=1.15, tesco=1.40, kcal=60,  protein=5.5,  aisle="Dairy & eggs"),

    # --- veg / flavour ---
    "toms":       dict(name="Chopped tomatoes",   unit="g", pack=400,  aldi=0.39, tesco=0.47, kcal=20,  protein=1.2,  aisle="Tins"),
    "onion":      dict(name="Brown onions",       unit="g", pack=1000, aldi=0.95, tesco=1.15, kcal=40,  protein=1.1,  aisle="Fresh produce"),
    "carrot":     dict(name="Carrots",            unit="g", pack=1000, aldi=0.55, tesco=0.70, kcal=41,  protein=0.9,  aisle="Fresh produce"),
    "frozveg":    dict(name="Frozen mixed veg",   unit="g", pack=1000, aldi=1.29, tesco=1.50, kcal=45,  protein=2.8,  aisle="Frozen"),
    "peas":       dict(name="Frozen peas",        unit="g", pack=900,  aldi=1.09, tesco=1.30, kcal=77,  protein=5.4,  aisle="Frozen"),
    "banana":     dict(name="Bananas (each)",     unit="unit", pack=5, aldi=0.79, tesco=0.95, kcal=95, protein=1.2,  aisle="Fresh produce"),
    "oil":        dict(name="Vegetable oil 1L",   unit="ml", pack=1000, aldi=1.85, tesco=2.15, kcal=884, protein=0.0, aisle="Cooking"),
    "curry":      dict(name="Curry powder",       unit="g", pack=100,  aldi=0.79, tesco=0.95, kcal=325, protein=12.0, aisle="Cooking"),
    "stock":      dict(name="Stock cubes x10",    unit="unit", pack=10, aldi=0.55, tesco=0.70, kcal=20, protein=1.0,  aisle="Cooking"),
}

# Recipes: quantities are PER SERVING, in the item's unit.
RECIPES = {
    "dahl":       dict(name="Red lentil dahl + rice",        mins=30, ing={"lentils":100,"rice":75,"onion":80,"toms":150,"curry":6,"oil":10,"stock":1}),
    "chilli":     dict(name="Beef chilli + rice",            mins=35, ing={"mince":110,"kidney":120,"toms":150,"onion":70,"rice":75,"oil":8,"stock":1}),
    "bolognese":  dict(name="Lentil bolognese + pasta",      mins=30, ing={"lentils":70,"toms":180,"onion":70,"carrot":60,"pasta":100,"oil":8,"stock":1}),
    "chickcurry": dict(name="Chickpea curry + rice",         mins=25, ing={"chickpeas":200,"toms":150,"onion":70,"curry":6,"rice":75,"oil":10}),
    "traybake":   dict(name="Chicken & veg traybake + rice", mins=40, ing={"chicken":150,"frozveg":150,"rice":75,"oil":10,"stock":1}),
    "stirfry":    dict(name="Chicken noodle stir-fry",       mins=20, ing={"chicken":130,"noodles":90,"frozveg":150,"oil":12}),
    "friedrice":  dict(name="Egg fried rice with peas",      mins=20, ing={"eggs":2,"rice":90,"peas":120,"onion":50,"oil":12}),
    "tunapasta":  dict(name="Tuna pasta bake",               mins=30, ing={"tuna":145,"pasta":110,"toms":120,"cheese":35,"onion":50}),
    "jacket":     dict(name="Jacket potato, beans & cheese", mins=55, ing={"potato":350,"beans":205,"cheese":30}),
    "omelette":   dict(name="Cheese omelette + toast",       mins=12, ing={"eggs":3,"cheese":30,"bread":80,"oil":8}),
    "wrap":       dict(name="Chicken & salad wrap",          mins=15, ing={"chicken":120,"tortilla":112,"carrot":60,"yoghurt":40}),
    "soup":       dict(name="Carrot, lentil & onion soup",   mins=35, ing={"lentils":70,"carrot":200,"onion":80,"stock":1,"bread":80,"oil":8}),
    # breakfasts
    "porridge":   dict(name="Porridge, banana & PB",         mins=8,  ing={"oats":80,"milk":250,"banana":1,"pb":20}, meal="breakfast"),
    "eggstoast":  dict(name="Scrambled eggs on toast",       mins=10, ing={"eggs":3,"bread":80,"milk":30,"oil":6},   meal="breakfast"),
    "yogpb":      dict(name="Yoghurt, oats & peanut butter", mins=3,  ing={"yoghurt":200,"oats":50,"pb":25,"banana":1}, meal="breakfast"),
}


def price(item_id, store):
    return ITEMS[item_id][store]


def serving_macros(rid):
    """kcal and protein for one serving of a recipe."""
    kcal = protein = 0.0
    for iid, qty in RECIPES[rid]["ing"].items():
        it = ITEMS[iid]
        mult = qty if it["unit"] == "unit" else qty / 100.0
        kcal += it["kcal"] * mult
        protein += it["protein"] * mult
    return kcal, protein
