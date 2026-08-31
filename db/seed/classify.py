"""
Staple / perishable classification — the one judgement call in the P0 port.

REVIEW GATE: this table is human judgement, not data from the prototype.
It decides whether a leftover is an asset (carry-over) or dead money (waste),
which drives the objective function in SPEC §3(d). Getting it wrong makes the
headline numbers lie in exactly the way CLAUDE.md warns about.

shelf_life_days is for an UNOPENED pack, UK, normal kitchen storage.

The `carries` column below is not stored — it is shown here because it is the
thing that actually matters, and it is *not* the same as keeps == 'staple'.
Six perishables comfortably outlive a 7-day plan horizon. See PROGRESS.md
"Open decision 1".
"""

# slug: (keeps, shelf_life_days, category)
CLASSIFICATION = {
    # --- carbs -------------------------------------------------------------
    "pasta":     ("staple",     None, "carb"),
    "rice":      ("staple",     None, "carb"),
    "noodles":   ("staple",     None, "carb"),
    "oats":      ("staple",     None, "carb"),
    "bread":     ("perishable",    5, "carb"),     # goes mouldy; freezable, not modelled
    "potato":    ("perishable",   21, "carb"),     # cool dark place; outlives the week
    "tortilla":  ("perishable",   14, "carb"),     # long ambient date

    # --- protein -----------------------------------------------------------
    "chicken":   ("perishable",    3, "protein"),  # genuine waste risk
    "mince":     ("perishable",    3, "protein"),  # genuine waste risk
    "eggs":      ("perishable",   21, "protein"),  # outlives the week comfortably
    "tuna":      ("staple",     None, "protein"),  # tin
    "lentils":   ("staple",     None, "protein"),  # dry
    "chickpeas": ("staple",     None, "protein"),  # tin
    "kidney":    ("staple",     None, "protein"),  # tin
    "beans":     ("staple",     None, "protein"),  # tin
    "pb":        ("staple",     None, "protein"),  # 25g protein/100g — not a flavour

    # --- dairy -------------------------------------------------------------
    "cheese":    ("perishable",   21, "dairy"),    # unopened block; outlives the week
    "milk":      ("perishable",    7, "dairy"),    # BORDERLINE: dated ~= plan horizon
    "yoghurt":   ("perishable",   10, "dairy"),

    # --- veg ---------------------------------------------------------------
    "toms":      ("staple",     None, "veg"),      # tin
    "onion":     ("perishable",   30, "veg"),      # outlives the week comfortably
    "carrot":    ("perishable",   14, "veg"),      # outlives the week
    "frozveg":   ("staple",     None, "veg"),      # FROZEN — leftover is never waste
    "peas":      ("staple",     None, "veg"),      # FROZEN — leftover is never waste
    "banana":    ("perishable",    5, "veg"),      # genuine waste risk

    # --- flavour -----------------------------------------------------------
    "oil":       ("staple",     None, "flavour"),
    "curry":     ("staple",     None, "flavour"),
    "stock":     ("staple",     None, "flavour"),
}

# Recipes that need an oven. Everything else is hob/kettle only.
NEEDS_OVEN = {"traybake", "jacket"}

# Items that make a recipe non-vegetarian.
MEAT_FISH = {"chicken", "mince", "tuna"}
