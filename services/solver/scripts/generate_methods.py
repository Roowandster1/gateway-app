"""
Write cooking steps for every recipe that has none, using Claude.

CLAUDE.md rule 1: a model may write copy — descriptions, cooking steps, tone —
and must stay out of selection, pricing and quantities. This script sits on the
right side of that line by construction:

  * It runs OFFLINE and writes to the database. Nothing here is in the request
    path, and no plan ever waits on a model.
  * The prompt is built from the recipe's own ingredient list, read from the
    database. The model is told the ingredients and is forbidden from naming
    amounts — quantities stay the solver's and are rendered by the app.
  * Every result is checked by app.method_check before it is written. Copy that
    states a quantity, or names an ingredient the shopper did not buy, is
    rejected and retried once, then skipped. Nothing unvalidated is published.

Usage:
    export ANTHROPIC_API_KEY=sk-ant-...
    python scripts/generate_methods.py            # writes db/migrations/007_recipe_methods.sql
    python scripts/generate_methods.py --only dahl,chilli
"""
import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import anthropic                                            # noqa: E402
import psycopg                                              # noqa: E402
from pydantic import BaseModel, Field                       # noqa: E402

from app import config                                      # noqa: E402
from app.method_check import PANTRY_BASICS, check_method    # noqa: E402

MODEL = "claude-opus-5"
ROOT = Path(__file__).resolve().parents[3]
MIGRATION = ROOT / "db" / "migrations" / "007_recipe_methods.sql"

RECIPE_SQL = """
SELECT r.slug, r.name, r.minutes, r.meal_slot::text, r.method_md,
       string_agg(i.name || '|' || i.slug, ';' ORDER BY i.name)
FROM recipe r
JOIN recipe_ingredient ri ON ri.recipe_id = r.id
JOIN item i ON i.id = ri.item_id
GROUP BY r.id ORDER BY r.slug
"""

SYSTEM = f"""You write cooking steps for a UK budget meal-planning app.

The app computes exact quantities itself and prints them next to your steps, so
your steps must never state an amount. This is the rule that matters most.

Hard constraints:
1. NEVER state a quantity or a pack count. Not "200g of lentils", not "a tin of
   tomatoes", not "two eggs". Write "the lentils", "the tomatoes", "the eggs".
   Cooking times and oven temperatures ARE allowed and encouraged.
2. Use ONLY the ingredients listed for the recipe. You may additionally assume
   {", ".join(PANTRY_BASICS[:3])}. Nothing else — the shopper bought exactly the
   listed items and nothing more.
3. Write for someone cooking a cheap weeknight meal in a small kitchen: plain
   British English, imperative, no flourish, no chef vocabulary.
4. Each step is one sentence ending in a full stop. Between 3 and 6 steps.
5. The summary is one short sentence describing the finished dish."""


class RecipeMethod(BaseModel):
    summary: str = Field(description="One short sentence describing the dish.")
    steps: list[str] = Field(description="3-6 imperative steps, no quantities.")


def prompt_for(name, minutes, slot, ingredients):
    listing = "\n".join(f"  - {n}" for n, _ in ingredients)
    return (f"Recipe: {name}\n"
            f"Served as: {slot}\n"
            f"Total time: about {minutes} minutes\n"
            f"Ingredients the shopper has bought:\n{listing}\n\n"
            f"Write the summary and steps.")


def generate(client, recipe, feedback=None):
    messages = [{"role": "user", "content": prompt_for(
        recipe["name"], recipe["minutes"], recipe["slot"], recipe["ingredients"])}]
    if feedback:
        messages.append({"role": "assistant", "content": "(previous attempt)"})
        messages.append({"role": "user", "content":
                         "That attempt was rejected by the validator:\n"
                         + "\n".join(f"  - {p}" for p in feedback)
                         + "\n\nRewrite it so none of those apply."})
    response = client.messages.parse(
        model=MODEL,
        max_tokens=16000,
        system=SYSTEM,
        thinking={"type": "adaptive"},
        messages=messages,
        output_format=RecipeMethod,
    )
    # Fable/Opus-class models can decline with HTTP 200 and stop_reason "refusal".
    if getattr(response, "stop_reason", None) == "refusal":
        return None
    return response.parsed_output


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", help="comma-separated recipe slugs")
    ap.add_argument("--all", action="store_true",
                    help="regenerate recipes that already have steps")
    args = ap.parse_args()
    wanted = set(args.only.split(",")) if args.only else None

    with psycopg.connect(config.DATABASE_URL) as conn:
        rows = conn.execute(RECIPE_SQL).fetchall()

    recipes = []
    for slug, name, minutes, slot, method, ing in rows:
        if wanted and slug not in wanted:
            continue
        if method and not args.all:
            continue
        pairs = [tuple(p.split("|")) for p in ing.split(";")]
        recipes.append(dict(slug=slug, name=name, minutes=minutes, slot=slot,
                            ingredients=pairs))

    if not recipes:
        print("Nothing to do — every recipe already has steps. Use --all to redo them.")
        return

    client = anthropic.Anthropic()
    written, skipped, basics = {}, [], set()

    for r in recipes:
        slugs = {s for _, s in r["ingredients"]}
        feedback = None
        for attempt in (1, 2):
            out = generate(client, r, feedback)
            if out is None:
                feedback = ["the model declined to answer"]
                continue
            problems, used = check_method(r["slug"], r["name"], slugs,
                                          out.summary, out.steps)
            if not problems:
                written[r["slug"]] = out
                basics |= used
                print(f"  ok    {r['slug']:<12} {len(out.steps)} steps")
                break
            print(f"  retry {r['slug']:<12} {problems[0]}" if attempt == 1
                  else f"  SKIP  {r['slug']:<12} {problems[0]}")
            feedback = problems
        else:
            skipped.append((r["slug"], feedback))

    if written:
        write_migration(written)
    print(f"\n{len(written)} written, {len(skipped)} skipped")
    if basics:
        print(f"Assumed store-cupboard basics: {', '.join(sorted(basics))} — "
              f"these are NOT priced catalogue items. Catalogue gap.")
    for slug, problems in skipped:
        print(f"  {slug}: {problems}")


def write_migration(written):
    def q(s):
        return "'" + str(s).replace("'", "''") + "'"

    lines = ["-- GENERATED by services/solver/scripts/generate_methods.py",
             "-- Cooking copy written by Claude, validated by app.method_check:",
             "-- no quantities, no ingredient outside each recipe's own list.",
             "-- CLAUDE.md rule 1 — copy only; selection, pricing and quantities",
             "-- remain the solver's.\n", "BEGIN;\n"]
    for slug, m in sorted(written.items()):
        body = m.summary + "\n\n" + "\n".join(
            f"{i}. {s}" for i, s in enumerate(m.steps, 1))
        lines.append(f"UPDATE recipe SET method_md = {q(body)} WHERE slug = {q(slug)};")
    lines.append("\nCOMMIT;\n")
    MIGRATION.write_text("\n".join(lines))
    print(f"\nwrote {MIGRATION}")


if __name__ == "__main__":
    main()
