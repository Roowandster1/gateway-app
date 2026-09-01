"""
Write cooking steps for the generated recipes, without a model.

`generate_methods.py` writes better prose, but it needs an Anthropic API key and
it writes one recipe at a time. There are 198 generated recipes, and a meal plan
you cannot cook is not a meal plan — so this fills them in deterministically from
what the generator already knows: which item is the base, which is the protein,
which is the vegetable and which is the seasoning.

Nothing here is a model call, so CLAUDE.md rule 1 is not even in play. Every step
still goes through `app.method_check`, which rejects copy that states a quantity
or names an ingredient the shopper did not buy — the same gate the model's output
passes through. Amounts stay the solver's and live in the shopping list.

The prose is plainer than the hand-written 24. That is the trade: plain steps for
every dish beats good steps for a tenth of them. Run `generate_methods.py` over
these later to replace a template with something better written.

Usage:
    python scripts/template_methods.py            # report only
    python scripts/template_methods.py --write    # emit 014_template_methods.sql
"""
from __future__ import annotations

import argparse
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

import psycopg  # noqa: E402

from app import config  # noqa: E402
from app.method_check import check_method  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parents[3]

# How each item behaves in a pan, in the order a cook would reach for it.
BOIL = {"rice": "rice", "pasta": "pasta", "noodles": "noodles"}
TOAST = {"bread": "bread", "tortilla": "wraps"}
AROMATIC = {"onion": "onion"}
HARD_VEG = {"carrot": "carrot"}
SOFT_VEG = {"peas": "peas", "frozveg": "mixed veg"}
BROWN = {"chicken": "chicken", "mince": "beef mince"}
STIR_IN = {"lentils": "lentils", "chickpeas": "chickpeas", "kidney": "kidney beans",
           "beans": "beans", "tuna": "tuna"}
NAMES = {**BOIL, **TOAST, **AROMATIC, **HARD_VEG, **SOFT_VEG, **BROWN, **STIR_IN,
         "eggs": "eggs", "cheese": "cheese", "yoghurt": "yoghurt", "pb": "peanut butter",
         "banana": "banana", "oats": "oats", "milk": "milk", "potato": "potatoes",
         "toms": "tomatoes", "oil": "oil", "stock": "stock cube", "curry": "curry powder"}


def steps_for(slugs: set[str], minutes: int) -> tuple[str, list[str]]:
    """A summary and an ordered method, from the ingredients alone."""
    steps: list[str] = []
    has = lambda *k: [s for s in k if s in slugs]  # noqa: E731

    # No-cook assemblies come first: nothing below applies to them.
    if not (slugs & set(BOIL) | slugs & set(TOAST) | slugs & set(BROWN)
            | {"potato", "eggs", "oats"} & slugs):
        parts = [NAMES.get(s, s) for s in sorted(slugs)]
        return (f"No cooking — {' and '.join(parts[:2])} in a bowl.",
                [f"Put the {parts[0]} in a bowl.",
                 f"Add the {' and '.join(parts[1:]) or 'rest'} and stir.",
                 "Eat."])

    if "oats" in slugs:
        with_milk = " with the milk" if "milk" in slugs else " with water"
        steps.append(f"Simmer the oats{with_milk}, stirring, until thick.")
    if "potato" in slugs:
        steps.append("Bake the potatoes until the skins crisp and the middles give.")
    for s in has(*BOIL):
        steps.append(f"Boil the {NAMES[s]} until just tender, then drain.")
    for s in has(*TOAST):
        steps.append("Toast the bread." if s == "bread" else "Warm the wraps in a dry pan.")
    # The pan has to exist before anything goes in it. Without this, a recipe
    # with no oil read "boil the pasta, add the chicken" — to what?
    oiled = "oil" in slugs and (slugs & set(AROMATIC) or slugs & set(BROWN)
                                or "eggs" in slugs)
    if oiled:
        steps.append("Heat the oil in a pan over a medium heat.")
    for s in has(*AROMATIC):
        steps.append(f"Soften the {NAMES[s]} until it turns translucent."
                     if oiled else
                     f"Sweat the {NAMES[s]} in a hot dry pan until it softens.")
        oiled = True
    for s in has(*BROWN):
        steps.append(f"Add the {NAMES[s]} and brown it all over." if oiled else
                     f"Cook the {NAMES[s]} in a hot pan until browned all over.")
        oiled = True
    for s in has(*HARD_VEG):
        steps.append(f"Stir in the {NAMES[s]} and give it a few minutes' head start.")
    if "curry" in slugs:
        steps.append("Stir in the curry powder and let it toast until it smells of itself.")
    if "toms" in slugs:
        steps.append("Pour in the tomatoes and bring it to a simmer.")
    if "stock" in slugs:
        steps.append("Crumble in the stock cube with a splash of water.")
    # Something has to be simmering. Tinned tomatoes, stock or milk provide it;
    # otherwise the step has to bring its own liquid.
    wet = bool(slugs & {"toms", "stock", "milk"})
    for s in has(*STIR_IN):
        steps.append(f"Add the {NAMES[s]} and simmer until it thickens." if wet else
                     f"Add the {NAMES[s]} with a splash of water and simmer until "
                     f"it thickens.")
        wet = True
    for s in has(*SOFT_VEG):
        steps.append(f"Throw in the {NAMES[s]} near the end so they keep their colour.")
    if "eggs" in slugs:
        steps.append("Beat the eggs and scramble them softly in the pan." if oiled else
                     "Beat the eggs and scramble them softly in a hot dry pan.")
    if "yoghurt" in slugs:
        steps.append("Spoon the yoghurt over at the end, off the heat.")
    if "pb" in slugs:
        steps.append("Swirl through the peanut butter.")
    if "banana" in slugs:
        steps.append("Slice the banana over the top.")
    if "cheese" in slugs:
        steps.append("Grate the cheese over while everything is still hot.")

    steps.append(f"Season, and serve. About {minutes} minutes start to finish.")

    # "A plain lentils dish" — the plural reads wrong as an adjective.
    ADJECTIVE = {"lentils": "lentil", "chickpeas": "chickpea", "kidney": "kidney bean",
                 "beans": "bean", "mince": "beef", "chicken": "chicken", "tuna": "tuna"}
    head = next(iter(sorted(slugs & set(BROWN) | slugs & set(STIR_IN))), "")
    summary = (f"A plain {ADJECTIVE.get(head, head)} dish, cooked in one go."
               if head else "Plain, quick, and cooked in one go.")
    return summary, steps


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()

    with psycopg.connect(config.DATABASE_URL) as conn:
        rows = conn.execute("""
            SELECT r.slug, r.name, r.minutes,
                   array_agg(i.slug ORDER BY i.slug)
            FROM recipe r
            JOIN recipe_ingredient ri ON ri.recipe_id = r.id
            JOIN item i ON i.id = ri.item_id
            WHERE r.method_md IS NULL
            GROUP BY r.slug, r.name, r.minutes
            ORDER BY r.slug
        """).fetchall()

    written, rejected = [], []
    for slug, name, minutes, ings in rows:
        summary, steps = steps_for(set(ings), minutes)
        problems, _ = check_method(slug, name, ings, summary, steps)
        if problems:
            rejected.append((slug, problems[:2]))
            continue
        body = summary + "\n\n" + "\n".join(
            f"{i}. {s}" for i, s in enumerate(steps, 1))
        written.append((slug, body))

    print(f"{len(rows)} recipes without steps")
    print(f"  {len(written)} pass method_check")
    print(f"  {len(rejected)} rejected")
    for slug, why in rejected[:8]:
        print(f"    {slug}: {why}")

    if args.write:
        dest = ROOT / "db" / "migrations" / "014_template_methods.sql"
        out = [
            "-- 014 — cooking steps for the generated recipes",
            "--",
            "-- Written by services/solver/scripts/template_methods.py: composed from",
            "-- each recipe's own ingredient list, with no model involved, and every",
            "-- one validated by app.method_check exactly as the model's copy is.",
            "-- Plainer than the hand-written 24; a plan you can cook beats a plan you",
            "-- cannot. Re-runnable — it only touches recipes with no method.",
            "",
            "BEGIN;",
            "",
        ]
        for slug, body in written:
            esc = body.replace("'", "''")
            out.append(f"UPDATE recipe SET method_md = '{esc}'\n"
                       f"  WHERE slug = '{slug}' AND method_md IS NULL;")
        out.append("\nCOMMIT;")
        dest.write_text("\n".join(out) + "\n")
        print(f"\nwrote {dest} ({len(written)} recipes)")


if __name__ == "__main__":
    main()
