"""
Validation for generated cooking copy.

CLAUDE.md rule 1 allows a model to write *copy* — descriptions, cooking steps,
tone — and forbids it anywhere near selection, pricing or quantities. That line
is easy to state and easy to cross by accident: a plausible-sounding step like
"stir in 200g of red lentils" puts a quantity the solver did not choose in front
of the user, and "season with a knob of butter" adds an ingredient nobody bought,
which breaks rule 4 — the plan must be executable from the basket.

So generated copy is not trusted. It is checked here, mechanically, and anything
that fails is rejected rather than published. Two rules:

  1. NO QUANTITIES. Amounts belong to the solver and are rendered from the
     database. Steps say "the lentils", never "200g of lentils". Times and oven
     temperatures are fine — they are method, not quantity.
  2. NO INGREDIENT THE RECIPE DOES NOT HAVE. Mentioning anything outside the
     recipe's own ingredient list means the basket no longer covers the cooking.

`PANTRY_BASICS` is the one deliberate exception, and it is a known gap rather
than a free pass: water, salt and pepper are assumed present and are not priced
items. They should be added to the catalogue.
"""
import re

# Words that identify a catalogue item in prose. Deliberately explicit rather
# than derived from item names — "wrap" and "toast" are also verbs, and a
# checker that flags "toast the spices" would be worse than useless.
ALIASES = {
    "pasta":     ["pasta", "penne"],
    "rice":      ["rice"],
    "noodles":   ["noodle", "noodles"],
    "oats":      ["oat", "oats", "porridge"],
    "bread":     ["bread", "loaf"],
    "potato":    ["potato", "potatoes"],
    "tortilla":  ["tortilla"],
    "chicken":   ["chicken"],
    "mince":     ["mince", "beef"],
    "eggs":      ["egg", "eggs"],
    "tuna":      ["tuna"],
    "lentils":   ["lentil", "lentils"],
    "chickpeas": ["chickpea", "chickpeas"],
    "kidney":    ["kidney bean", "kidney beans"],
    "beans":     ["baked bean", "baked beans"],
    "cheese":    ["cheese", "cheddar"],
    "pb":        ["peanut butter"],
    "milk":      ["milk"],
    "yoghurt":   ["yoghurt", "yogurt"],
    "toms":      ["tomato", "tomatoes"],
    "onion":     ["onion", "onions"],
    "carrot":    ["carrot", "carrots"],
    "frozveg":   ["mixed veg", "frozen veg", "mixed vegetables"],
    "peas":      ["pea", "peas"],
    "banana":    ["banana", "bananas"],
    "oil":       ["oil"],
    "curry":     ["curry powder"],
    "stock":     ["stock cube", "stock"],
}

PANTRY_BASICS = ["water", "salt", "pepper", "seasoning"]

_NUM = r"(?:\d+(?:[.,]\d+)?|[½¼¾])"
_MASS = r"(?:g|kg|ml|l|litres?|liters?|tbsp|tsp|tablespoons?|teaspoons?|cups?|oz|lb)"
_COUNT = r"(?:tins?|cans?|packs?|packets?|bags?|jars?|slices?|eggs?|cubes?|fillets?)"
_WORDNUM = r"(?:one|two|three|four|five|six|seven|eight|nine|ten|a|an|half)"

# "200g", "1.5 kg", "2 tbsp" — but not "30 minutes" or "180C".
QUANTITY_RE = re.compile(rf"\b{_NUM}\s*{_MASS}\b", re.I)
# "a tin of", "two slices", "3 stock cubes" — pack counts are the solver's
# business. One optional word may sit between the number and the unit, which
# catches "3 stock cubes" without swallowing "5 minutes before the eggs".
PACKCOUNT_RE = re.compile(rf"\b(?:{_NUM}|{_WORDNUM})\s+(?:\w+\s+)?{_COUNT}\b", re.I)

MIN_STEPS, MAX_STEPS = 3, 8
MAX_STEP_CHARS = 240


def check_method(recipe_slug, recipe_name, ingredient_slugs, summary, steps):
    """
    Returns (problems, basics_used). A non-empty `problems` list means the copy
    must not be published.
    """
    problems, basics = [], set()
    ingredient_slugs = set(ingredient_slugs)

    if not (MIN_STEPS <= len(steps) <= MAX_STEPS):
        problems.append(f"{len(steps)} steps; expected {MIN_STEPS}-{MAX_STEPS}")
    if not summary or len(summary) > 160:
        problems.append("summary missing or over 160 characters")

    for i, step in enumerate(steps, 1):
        s = step.strip()
        if not s:
            problems.append(f"step {i} is empty")
            continue
        if len(s) > MAX_STEP_CHARS:
            problems.append(f"step {i} is {len(s)} characters, over {MAX_STEP_CHARS}")
        if not s.endswith((".", "!")):
            problems.append(f"step {i} does not end in a full stop")
        if re.search(r"^[#*\-]|\|", s):
            problems.append(f"step {i} contains markup")

    blob = " ".join([summary] + list(steps))
    for m in QUANTITY_RE.finditer(blob):
        problems.append(f"states a quantity: {m.group(0)!r} — amounts come from the solver")
    for m in PACKCOUNT_RE.finditer(blob):
        problems.append(f"states a pack count: {m.group(0)!r} — pack counts come from the solver")

    # Strip what this recipe legitimately contains, then anything remaining that
    # names a catalogue item is an ingredient the shopper never bought.
    residue = " " + blob.lower() + " "
    residue = residue.replace(recipe_name.lower(), " ")
    for slug in ingredient_slugs:
        for alias in sorted(ALIASES.get(slug, []), key=len, reverse=True):
            residue = re.sub(rf"\b{re.escape(alias)}\b", " ", residue)

    for slug, aliases in ALIASES.items():
        if slug in ingredient_slugs:
            continue
        for alias in aliases:
            if re.search(rf"\b{re.escape(alias)}\b", residue):
                problems.append(
                    f"mentions {alias!r}, which is not in {recipe_slug} — the basket "
                    f"would not cover it")
                break

    for basic in PANTRY_BASICS:
        if re.search(rf"\b{basic}\b", blob, re.I):
            basics.add(basic)

    return problems, basics
