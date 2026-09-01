"""
Enumerate every plausible recipe the priced catalogue can actually make.

WHY THIS IS NOT AN LLM CALL
---------------------------
CLAUDE.md rule 1 keeps language models out of selection, pricing and quantities.
A recipe's ingredient list and per-serving grams are quantities, so they are
produced here by arithmetic over the item table: combinations are enumerated,
portions are solved to hit a calorie target, and macros are then *computed from
the items* rather than asserted by anything. A model that hallucinated "70g of
lentils is 40g of protein" would corrupt the nutrition constraints, so nothing
is ever asked.

Naming and cooking steps are the one thing rule 1 does allow a model to do, and
they stay out of this file — `generate_methods.py` owns the steps, and the names
here come from a template so the generator can run with no network at all.

WHAT "INFINITE" ACTUALLY MEANS
------------------------------
It does not. A recipe is a set of rows pointing at *priced items*, so the recipe
space is bounded by the catalogue: 28 items cannot make ten thousand genuinely
different dinners, only ten thousand rearrangements of lentils and rice. The
honest ceiling is roughly what this script finds. To go past it you add priced
items, and CLAUDE.md rule 3 means those need real observed prices — which is a
shopping trip, not a script.

The good news, which the 24 hand-written recipes hid: 23 of the 28 items are
gluten-free and 25 are dairy-free. The reason there was no gluten-free breakfast
was that nobody had written one, not that the ingredients were missing.
"""
from __future__ import annotations

import argparse
import itertools
import pathlib
import sys
from dataclasses import dataclass

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from app.catalogue import load  # noqa: E402
from app.domain import Item  # noqa: E402

# ---------------------------------------------------------------------------
# Roles. Hand-authored, small, and checked against the 24 existing recipes: if a
# rule here rejects a recipe a person already wrote, the rule is wrong.
# ---------------------------------------------------------------------------
BASES = {
    # No rice: no shape in LIGHT_ON takes it, so enumerating rice breakfasts
    # only to reject every one of them is work nobody reads.
    #
    # Eggs are here as well as in PROTEINS because a recipe gets exactly one
    # protein, and "scrambled eggs with cheese" needs two. LIGHT_ON already
    # says eggs may carry cheese, tomatoes, potato and milk; without eggs as a
    # base the enumeration could not build a single one of those, which is how
    # gluten-free breakfast ended up with three recipes for a fortnight.
    "breakfast": ["oats", "bread", "tortilla", "potato", "yoghurt", "eggs"],
    "main": ["rice", "pasta", "noodles", "potato", "bread", "tortilla"],
    "snack": ["bread", "oats", "tortilla"],
}
PROTEINS = {
    "breakfast": ["eggs", "beans", "pb", "yoghurt", "cheese"],
    "main": ["chicken", "mince", "tuna", "eggs", "lentils", "chickpeas",
             "kidney", "beans", "cheese"],
    # Not tuna and not beans: "tuna & tomato" turned up twelve times in a week
    # as a snack, which is nutritionally fine and nobody's afternoon.
    "snack": ["eggs", "pb", "cheese", "yoghurt"],
}
VEG = {
    "breakfast": ["banana", "toms"],
    "main": ["toms", "onion", "carrot", "frozveg", "peas"],
    "snack": ["banana", "toms"],
}
FLAVOUR = {
    "breakfast": ["milk", "oil"],
    "main": ["oil", "stock", "curry"],
    "snack": [],
}

# A sweet item and a savoury item never share a plate. One rule kills banana
# with chicken, peanut butter with onion, and several hundred other combinations
# that no validator could sensibly score.
SWEET_ONLY = {"banana", "pb"}
SAVOURY_ONLY = {"onion", "carrot", "toms", "frozveg", "peas", "kidney",
                "chickpeas", "lentils", "tuna", "chicken", "mince", "beans",
                "stock", "curry", "cheese", "noodles", "pasta"}
# Everything else (eggs, potato, rice, bread, tortilla, oats, oil, milk,
# yoghurt) is at home in either.

MEAT_AND_FISH = {"chicken", "mince", "tuna"}
# Pairs a rule about sweetness cannot catch.
NEVER_TOGETHER = [
    {"yoghurt", "mince"}, {"yoghurt", "tuna"}, {"yoghurt", "kidney"},
    {"yoghurt", "beans"}, {"milk", "toms"}, {"milk", "onion"},
    {"oats", "toms"}, {"oats", "onion"}, {"oats", "cheese"},
    {"eggs", "banana"},
]

# A bulk day is 3300 kcal across three meals, so a main has to be able to reach
# about 1100. Capping mains at 950 made bulk-plus-gluten-free infeasible on
# calories alone — a real answer, but one caused by the generator's ceiling
# rather than by the food.
SLOT_BAND = {"breakfast": (330.0, 850.0), "main": (450.0, 1150.0),
             "snack": (140.0, 400.0)}
MIN_PROTEIN_G = {"breakfast": 14.0, "main": 22.0, "snack": 7.0}

# What one serving of each item actually is: (typical, min, max) in the item's
# own unit. Hand-authored cooking knowledge, and the part of this script most
# worth arguing with — these are the numbers that decide whether a generated
# recipe is a meal or a spreadsheet row.
#
# Deriving portions from a share of the calorie target instead produced 235g of
# onion in a bolognese, because onion is 36 kcal per 100g and a twelfth of 680
# calories is a lot of onion. Calories are the wrong axis for a vegetable.
SERVE: dict[str, tuple[float, float, float]] = {
    # bases, dry weights where dry
    "rice": (65, 50, 130), "pasta": (75, 60, 150), "noodles": (65, 50, 130),
    "bread": (80, 40, 140),
    # 448g of wraps is 8 wraps, so a serving is 56g each — NOT "2", which is
    # what a serving looks like until you check that this item is priced by
    # weight. The self-check below exists because of this line.
    "tortilla": (112, 56, 224), "potato": (280, 180, 550),
    "oats": (50, 35, 110),
    # proteins
    "eggs": (2, 1, 5), "mince": (110, 80, 250), "chicken": (130, 90, 280),
    "tuna": (100, 70, 145), "lentils": (70, 50, 150), "chickpeas": (150, 100, 320),
    "kidney": (150, 100, 320), "beans": (200, 120, 410), "pb": (30, 15, 70),
    "cheese": (40, 20, 100), "yoghurt": (150, 100, 330),
    # veg and fruit — fixed, never scaled
    "toms": (200, 200, 200), "onion": (80, 80, 80), "carrot": (80, 80, 80),
    "frozveg": (120, 120, 120), "peas": (100, 100, 100), "banana": (1, 1, 1),
    # flavour — fixed
    "oil": (10, 10, 10), "stock": (1, 1, 1), "curry": (6, 6, 6),
    "milk": (150, 150, 150),
}
SCALES = ("base", "protein")   # the only roles a serving may be scaled on

# Bananas go with breakfast things. Without this, "yoghurt & banana potatoes"
# passes the sweet/savoury rule, because a potato is at home in either.
BANANA_OK = {"oats", "bread", "tortilla", "yoghurt", "pb", "milk", "eggs"}
# And porridge is a sweet dish. Without this the generator produced "tuna
# porridge", which passes every nutritional check ever written. Eggs and oil are
# in the list because a pancake is oats too; what separates the two is the shape
# rule below, not this one.
OATS_OK = {"banana", "pb", "yoghurt", "milk", "eggs", "oil"}

# ---------------------------------------------------------------------------
# What a breakfast — or a snack — actually is
# ---------------------------------------------------------------------------
# The rules above are about whether two ingredients belong on a plate. They say
# nothing about whether the plate is breakfast, and the enumeration exploited
# that: yoghurt spread on toast, yoghurt on a jacket potato, tinned tomatoes
# with cheese at 7am, a bowl of beans and oil called "Bean". Every one clears
# the calorie band and the protein floor. Not one is breakfast.
#
# So breakfast gets a shape rule instead of another list of forbidden pairs. A
# breakfast is built on ONE base and carries only what that base takes. Read the
# table downwards and it is five dishes: porridge, a yoghurt bowl, something on
# toast, a wrap, and eggs.
#
# Order matters — the first base found is the dish. Yoghurt outranks bread, so
# yoghurt and bread together is a bowl that has been handed a slice of toast,
# which is not one of the five, rather than toast with a yoghurt topping.
#
# Snacks are the same vocabulary with the base made optional: peanut butter and
# a banana is a snack and is not built on anything. What a snack may not do is
# put tomatoes in the yoghurt, so when a base IS present the table still binds.
LIGHT_BASES = ("oats", "yoghurt", "bread", "tortilla", "eggs")
LIGHT_ON: dict[str, set[str]] = {
    "oats":     {"milk", "yoghurt", "banana", "pb", "eggs", "oil"},
    "yoghurt":  {"oats", "banana", "pb", "milk"},
    "bread":    {"eggs", "beans", "cheese", "pb", "banana", "toms", "oil", "milk"},
    "tortilla": {"eggs", "beans", "cheese", "pb", "banana", "oil", "milk"},
    "eggs":     {"potato", "cheese", "toms", "oil", "milk"},
}


def light_shape(slugs: set[str], *, base_required: bool) -> bool:
    base = next((b for b in LIGHT_BASES if b in slugs), None)
    if base is None:
        # Beans and oil. Cheese and tinned tomatoes. Food, in the sense that you
        # could eat it; not a breakfast, and not something to hand someone at
        # seven in the morning as one of their three meals. A snack is allowed
        # to be two ingredients and no base, so it stops here instead.
        return not base_required
    if not (slugs - {base}) <= LIGHT_ON[base]:
        return False
    # Oats and eggs together is a pancake, which is a batter you fry, so it has
    # to bring the fat and the liquid with it. Without this clause the same two
    # items are "egg porridge" — which is why OATS_OK could not simply be
    # widened to let the hand-written pancake recipe through.
    if {"oats", "eggs"} <= slugs and not {"oil", "milk"} <= slugs:
        return False
    return True


def check_servings(items: dict[str, Item]) -> list[str]:
    """
    A serving must be a plausible amount of the thing in the unit it is priced
    in. Tortilla wraps are sold by the 448g pack, so a serving written as "2"
    is two grams of wrap — six calories — and the generator happily built meals
    around it. Anything carrying under 30 kcal cannot be a base or a protein.
    """
    problems = []
    for slug, (typical, lo, hi) in SERVE.items():
        item = items.get(slug)
        if item is None:
            problems.append(f"{slug}: not in the priced catalogue")
            continue
        if not (lo <= typical <= hi):
            problems.append(f"{slug}: typical {typical} outside {lo}-{hi}")
        kcal, _ = item.macros_for(typical)
        is_seasoning = slug in {"oil", "stock", "curry", "milk"}
        if kcal < 30 and not is_seasoning:
            problems.append(
                f"{slug}: a serving of {typical}{item.unit} is only {kcal:.0f} kcal "
                f"— wrong unit?")
    return problems


@dataclass(frozen=True)
class Draft:
    slug: str
    name: str
    slot: str
    minutes: int
    ingredients: tuple[tuple[str, float], ...]
    kcal: float
    protein: float
    big: bool = False

    @property
    def item_set(self) -> frozenset[str]:
        return frozenset(s for s, _ in self.ingredients)

    @property
    def key(self) -> tuple[frozenset[str], bool]:
        """The same ingredients at two portion sizes are two different meals."""
        return (self.item_set, self.big)


def round_qty(item: Item, qty: float) -> float:
    """An item sold by the each is priced per each: 1.4 eggs is not a portion."""
    if item.unit == "unit":
        return max(1.0, round(qty))
    return round(qty / 5.0) * 5.0


def macros(items: dict[str, Item], ing: list[tuple[str, float]]) -> tuple[float, float]:
    kcal = prot = 0.0
    for slug, qty in ing:
        k, p = items[slug].macros_for(qty)
        kcal += k
        prot += p
    return kcal, prot


def plausible(slugs: set[str], slot: str = "main") -> bool:
    if slot in ("breakfast", "snack") and not light_shape(
            slugs, base_required=slot == "breakfast"):
        return False
    if SWEET_ONLY & slugs and SAVOURY_ONLY & slugs:
        return False
    if len(MEAT_AND_FISH & slugs) > 1:
        return False
    # Milk belongs in porridge and scrambled eggs. Everywhere else it was
    # turning up as 165ml poured over a bean wrap.
    if "milk" in slugs and not ({"oats", "eggs"} & slugs):
        return False
    if "banana" in slugs and not (slugs - {"banana"}) <= BANANA_OK:
        return False
    if "oats" in slugs and not (slugs - {"oats"}) <= OATS_OK:
        return False
    return not any(pair <= slugs for pair in NEVER_TOGETHER)


def build(items: dict[str, Item], slot: str, base: str | None, protein: str,
          veg: str | None, flavour: str | None, big: bool = False) -> Draft | None:
    parts = [(base, "base"), (protein, "protein"), (veg, "veg"),
             (flavour, "flavour")]
    chosen = [(s, role) for s, role in parts if s]
    slugs = {s for s, _ in chosen}
    # An item may fill one role, not two. Yoghurt is both a breakfast base and a
    # breakfast protein, and without this it turned up as both at once —
    # "Yoghurt & banana yoghurt", with yoghurt in the ingredient list twice.
    if len(slugs) != len(chosen):
        return None
    if len(slugs) < 2 or not plausible(slugs, slot):
        return None

    if any(s not in SERVE for s in slugs):
        return None

    # Start every ingredient at a real serving, then scale only the base and the
    # protein — the two things a cook actually puts more or less of — until the
    # plate lands inside the slot's calorie band. Veg and seasoning stay put.
    #
    # A `big` build aims at the top of the band instead of the middle. Without
    # it every recipe clusters near the typical serving, and a bulk day of 3300
    # kcal has nothing dense enough to reach it — gluten-free bulk came back
    # infeasible by 513 kcal a day purely because no large portion existed.
    lo, hi = SLOT_BAND[slot]
    if big:
        lo = hi * 0.86
    ing = [(s, round_qty(items[s], SERVE[s][0])) for s, _ in chosen]
    roles = dict(chosen)

    for _ in range(24):
        kcal, protein_g = macros(items, ing)
        if lo <= kcal <= hi:
            break
        step = 1.10 if kcal < lo else 0.92
        moved = False
        scaled = []
        for slug, qty in ing:
            if roles[slug] not in SCALES:
                scaled.append((slug, qty))
                continue
            _, qmin, qmax = SERVE[slug]
            want = round_qty(items[slug], min(qmax, max(qmin, qty * step)))
            moved = moved or want != qty
            scaled.append((slug, want))
        ing = scaled
        if not moved:
            break   # both scalable roles are pinned at their limit

    kcal, protein_g = macros(items, ing)
    if not (lo <= kcal <= hi) or protein_g < MIN_PROTEIN_G[slot]:
        return None

    name = name_for(items, slot, base, protein, veg, flavour)
    return Draft(slug=slug_for(ing) + ("-big" if big else ""),
                 name=f"{name} (big portion)" if big else name,
                 slot=slot, minutes=minutes_for(slugs, slot),
                 ingredients=tuple(sorted(ing)), kcal=kcal, protein=protein_g,
                 big=big)


def slug_for(ing: list[tuple[str, float]]) -> str:
    return "g-" + "-".join(sorted(s for s, _ in ing))


NICE = {
    "oats": "porridge", "bread": "toast", "tortilla": "wrap", "rice": "rice",
    "pasta": "pasta", "noodles": "noodles", "potato": "potatoes",
    "eggs": "egg", "beans": "bean", "pb": "peanut butter", "yoghurt": "yoghurt",
    "cheese": "cheese", "chicken": "chicken", "mince": "beef", "tuna": "tuna",
    "lentils": "lentil", "chickpeas": "chickpea", "kidney": "kidney bean",
    "banana": "banana", "toms": "tomato", "onion": "onion", "carrot": "carrot",
    "frozveg": "veg", "peas": "pea", "milk": "milk", "oil": "", "stock": "",
    "curry": "curry",
}


def name_for(items, slot, base, protein, veg, flavour) -> str:
    # A light meal can have no separate protein — scrambled eggs, yoghurt and a
    # banana — in which case the base is what the dish is called after.
    if protein is None:
        protein, base = base, None
    p = NICE.get(protein, protein)
    b = NICE.get(base, "") if base else ""
    v = NICE.get(veg, "") if veg else ""
    if flavour == "curry":
        head = f"{p.capitalize()} curry"
        return f"{head} with {b}" if b else head
    if base == "noodles" and veg == "frozveg":
        return f"{p.capitalize()} noodle stir-fry"
    if flavour == "stock" and not base:
        return f"{p.capitalize()} and {v} soup" if v else f"{p.capitalize()} soup"
    bits = [p]
    if v:
        bits.append(f"& {v}")
    head = " ".join(bits).capitalize()
    return f"{head} {b}".strip() if b else head


def minutes_for(slugs: set[str], slot: str) -> int:
    if slugs <= {"banana", "pb", "yoghurt", "oats", "milk", "bread"}:
        return 4
    if "potato" in slugs:
        return 45
    if {"lentils", "chickpeas", "kidney"} & slugs and "stock" in slugs:
        return 30
    if {"chicken", "mince"} & slugs:
        return 25
    return 8 if slot != "main" else 18


def generate(items: dict[str, Item], cap: int = 3) -> list[Draft]:
    """
    Enumerate, then keep at most `cap` variants of each (slot, base, protein).

    Uncapped this produces 910 mains, which is not variety — it is the same
    dozen dishes with a different vegetable in each. It also costs real time:
    a fortnight's plan went from 2 seconds to 20, and the floor probe from 3 to
    17, because every extra recipe is another integer variable. A 14-day plan
    uses eight or nine distinct mains, so a few hundred candidates is already
    far more choice than the solver can spend.

    The cap is deterministic — same catalogue, same recipes — and picks by
    ingredient count then slug, so the survivors spread across the veg and
    seasoning options rather than clustering on one.
    """
    seen: dict[tuple[frozenset[str], bool], Draft] = {}
    for slot in ("breakfast", "main", "snack"):
        bases = [None] + [b for b in BASES[slot] if b in items]
        proteins = [p for p in PROTEINS[slot] if p in items]
        # A light meal may have no separate protein: scrambled eggs are eggs,
        # milk and a pan, and yoghurt with banana is yoghurt and a banana. Both
        # are the base carrying itself, which the one-role-per-item rule now
        # forbids expressing as base=eggs, protein=eggs. Mains keep a required
        # protein — a dinner of pasta and a carrot is not a dinner — and the
        # slot's protein floor still rejects anything too thin to be a meal.
        if slot in ("breakfast", "snack"):
            proteins = [None] + proteins
        vegs = [None] + [v for v in VEG[slot] if v in items]
        flavours = [None] + [f for f in FLAVOUR[slot] if f in items]
        for base, prot, veg, flav in itertools.product(bases, proteins, vegs, flavours):
            regular = build(items, slot, base, prot, veg, flav)
            # One recipe per ingredient set: two shapes that land on the same
            # items are the same dish written twice.
            if regular is not None and regular.key not in seen:
                seen[regular.key] = regular
            if slot == "main":
                large = build(items, slot, base, prot, veg, flav, big=True)
                # Only worth a second recipe if it is meaningfully bigger.
                if (large is not None and large.key not in seen
                        and (regular is None or large.kcal >= regular.kcal * 1.25)):
                    seen[large.key] = large

    # Two recipes with the same name are one recipe as far as anyone reading a
    # meal plan is concerned. The name template drops oil and stock, so
    # oats+eggs and oats+eggs+oil both come out as "Egg porridge".
    #
    # This has to happen BEFORE the cap, not after. Capping first filled all
    # three slots of the eggs-and-cheese shape with {cheese,eggs},
    # {cheese,eggs,oil} and {cheese,eggs,milk} — three drafts that all render as
    # "Cheese egg" — and the dedupe then collapsed them to one, so a cap of
    # three yielded a single dish and "Cheese & tomato egg" never survived at
    # all. Deduplicate first and the cap spends its three slots on three
    # different dishes.
    by_name: dict[str, Draft] = {}
    for d in sorted(seen.values(), key=lambda d: (d.slot, len(d.ingredients), d.slug)):
        by_name.setdefault(d.name, d)

    shapes: dict[tuple[str, str, str, bool], list[Draft]] = {}
    for d in by_name.values():
        shapes.setdefault(shape_of(d), []).append(d)
    kept: list[Draft] = []
    for group in shapes.values():
        group.sort(key=lambda d: (len(d.ingredients), d.slug))
        kept.extend(group[:cap])
    return sorted(kept, key=lambda d: (d.slot, d.slug))


def shape_of(d: Draft) -> tuple[str, str, str, bool]:
    items_ = d.item_set
    base = next((b for b in BASES[d.slot] if b in items_), "-")
    # The protein cannot be the item already counted as the base. Eggs are both
    # a breakfast base and a breakfast protein, and reading them as both put
    # every egg breakfast — eggs and cheese, eggs and tomato, eggs and potato —
    # into a single shape, where the cap kept three of twelve. That is how
    # gluten-free breakfast came out with three recipes for a fortnight.
    prot = next((p for p in PROTEINS[d.slot] if p in items_ and p != base), "-")
    return (d.slot, base, prot, d.big)


def sql(drafts: list[Draft]) -> str:
    out = [
        "-- 013 — generated recipes",
        "--",
        "-- Produced by services/solver/scripts/generate_recipes.py: deterministic",
        "-- enumeration over the priced catalogue, portions solved to a calorie",
        "-- target, macros computed from the item table. No model was asked for an",
        "-- ingredient or a quantity — CLAUDE.md rule 1. Cooking steps are written",
        "-- separately by generate_methods.py, which is the one thing rule 1 allows",
        "-- a model to do, and every step goes through method_check.py.",
        "--",
        "-- Re-runnable: ON CONFLICT DO NOTHING, so the hand-written 24 are never",
        "-- touched and a second run adds only what is new.",
        "",
        "BEGIN;",
        "",
    ]
    for d in drafts:
        out.append(
            f"INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES\n"
            f"  ('{d.slug}', {pgstr(d.name)}, {d.minutes}, '{d.slot}', 1)\n"
            f"  ON CONFLICT (slug) DO NOTHING;"
        )
        values = ",\n".join(
            f"  ((SELECT id FROM recipe WHERE slug='{d.slug}'),"
            f" (SELECT id FROM item WHERE slug='{s}'), {q})"
            for s, q in d.ingredients
        )
        out.append(
            "INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES\n"
            f"{values}\n  ON CONFLICT DO NOTHING;\n"
        )
    out.append("COMMIT;")
    return "\n".join(out) + "\n"


def pgstr(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--store", default="aldi")
    ap.add_argument("--cap", type=int, default=3,
                    help="most variants to keep per (slot, base, protein)")
    ap.add_argument("--write", metavar="PATH", help="emit a migration")
    args = ap.parse_args()

    items, existing, _ = load(args.store)

    problems = check_servings(items)
    if problems:
        print("SERVING TABLE IS WRONG:")
        for p in problems:
            print("  " + p)
        raise SystemExit(1)

    drafts = generate(items, cap=args.cap)

    # Every hand-written recipe must survive the plausibility rules. If one does
    # not, a rule is wrong and the generator would be quietly discarding food a
    # person already decided was fine.
    rejected = [slug for slug, r in existing.items()
                if not r.slug.startswith("g-")
                and not plausible(set(r.ingredients), r.meal_slot)]
    print(f"hand-written recipes rejected by the rules: {rejected or 'none'}")

    have = {frozenset(r.ingredients) for r in existing.values()}
    fresh = [d for d in drafts if d.item_set not in have]
    print(f"\n{len(drafts)} plausible recipes enumerated, "
          f"{len(fresh)} of them new (catalogue has {len(existing)})")
    for slot in ("breakfast", "main", "snack"):
        n = sum(1 for d in fresh if d.slot == slot)
        old = sum(1 for r in existing.values() if r.meal_slot == slot)
        print(f"  {slot:10s} {old:>3} -> {old + n:>3}")

    gf = {s for s, i in items.items() if "gluten" not in i.allergens}
    df = {s for s, i in items.items() if "dairy" not in i.allergens}
    print("\nWhat that unlocks, by meal slot:")
    for label, ok in (("gluten free", gf), ("dairy free", df)):
        for slot in ("breakfast", "main"):
            before = sum(1 for r in existing.values()
                         if r.meal_slot == slot and set(r.ingredients) <= ok)
            after = before + sum(1 for d in fresh
                                 if d.slot == slot and d.item_set <= ok)
            print(f"  {label:12s} {slot:10s} {before:>3} -> {after:>3}")

    if args.write:
        pathlib.Path(args.write).write_text(sql(fresh))
        print(f"\nwrote {args.write} ({len(fresh)} recipes)")


if __name__ == "__main__":
    main()
