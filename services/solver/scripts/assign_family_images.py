"""
Give every photo-less recipe a picture of its dish *type*.

There are 198 generated recipes and no budget to photograph each one, so
thirteen images cover them by shape: a rice bowl, a pasta bowl, a wrap, a jacket
potato, and so on. A recipe gets the family image its ingredients match.

BE CLEAR ABOUT WHAT THIS IS. The original 24 photographs are of the dish they
sit next to. A family image is not: "Chicken & carrot pasta" shows a photograph
of chicken pasta, which is the right *kind* of food and not that exact plate.
Recipe apps do this with stock photography constantly, and the honest version of
it is to say so rather than to let the picture imply a precision the catalogue
does not have — so `image_is_family` marks them and the UI can too.

The rules run in order and the first match wins, which is why the specific ones
come before the general ones: a chickpea curry with rice is a curry, not a rice
bowl.

Usage:
    python scripts/assign_family_images.py            # report only
    python scripts/assign_family_images.py --write    # emit 015_family_images.sql
"""
from __future__ import annotations

import argparse
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

import psycopg  # noqa: E402

from app import config  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parents[3]

# (family, needs-all, needs-any, must-not-have). First match wins.
RULES: list[tuple[str, set[str], set[str], set[str]]] = [
    ("yoghurt",     {"yoghurt"},   set(),                      set()),
    ("porridge",    {"oats"},      set(),                      {"yoghurt"}),
    ("jacket",      {"potato"},    set(),                      set()),
    ("wrap",        {"tortilla"},  set(),                      set()),
    ("soup",        {"stock"},     set(),                      {"rice", "pasta", "noodles",
                                                                "bread", "potato", "tortilla"}),
    ("curry",       {"curry"},     set(),                      set()),
    ("noodles",     {"noodles"},   set(),                      set()),
    ("pasta",       {"pasta"},     set(),                      set()),
    ("rice-meat",   {"rice"},      {"chicken", "mince", "tuna"}, set()),
    ("rice-pulse",  {"rice"},      set(),                      set()),
    ("beans-toast", {"bread"},     {"beans", "cheese", "toms"}, set()),
    ("eggs",        {"eggs"},      set(),                      set()),
    ("beans-toast", {"bread"},     set(),                      set()),
    # Anything with no carb base at all: beans and tomatoes, carrot and chicken.
    # A bowl of stirred-together stuff, which is exactly what they are.
    ("bowl",        set(),         set(),                      set()),
]

# What the thirteen files are called. The upload has to use exactly these names.
FILES = {
    "rice-meat": "family-rice-meat", "curry": "family-curry", "pasta": "family-pasta",
    "noodles": "family-noodles", "jacket": "family-jacket", "wrap": "family-wrap",
    "beans-toast": "family-beans-toast", "porridge": "family-porridge",
    "eggs": "family-eggs", "soup": "family-soup", "rice-pulse": "family-rice-pulse",
    "yoghurt": "family-yoghurt", "bowl": "family-bowl",
}


def family_for(slugs: set[str]) -> str | None:
    for name, need_all, need_any, forbid in RULES:
        if need_all <= slugs and not (forbid & slugs) and (
                not need_any or need_any & slugs):
            return name
    return None


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()

    with psycopg.connect(config.DATABASE_URL) as conn:
        rows = conn.execute("""
            SELECT r.slug, array_agg(i.slug ORDER BY i.slug)
            FROM recipe r
            JOIN recipe_ingredient ri ON ri.recipe_id = r.id
            JOIN item i ON i.id = ri.item_id
            WHERE r.image_url IS NULL
            GROUP BY r.slug ORDER BY r.slug
        """).fetchall()

    assigned: dict[str, list[str]] = {}
    unmatched = []
    for slug, ings in rows:
        fam = family_for(set(ings))
        if fam is None:
            unmatched.append((slug, ings))
        else:
            assigned.setdefault(fam, []).append(slug)

    print(f"{len(rows)} recipes without a photograph")
    for fam in sorted(assigned, key=lambda f: -len(assigned[f])):
        print(f"  {FILES[fam]:<22} {len(assigned[fam]):>3} recipes")
    print(f"  unmatched              {len(unmatched):>3}")
    for slug, ings in unmatched[:8]:
        print(f"    {slug}: {', '.join(ings)}")

    if args.write:
        dest = ROOT / "db" / "migrations" / "015_family_images.sql"
        out = [
            "-- 015 — dish-type photographs for the generated recipes",
            "--",
            "-- Twelve images covering 198 recipes by shape. A family image is a",
            "-- photograph of the KIND of food, not of that exact plate — the",
            "-- original 24 are the real thing, these are not, and image_is_family",
            "-- marks the difference so the UI can be honest about it.",
            "--",
            "-- Written by services/solver/scripts/assign_family_images.py.",
            "",
            "BEGIN;",
            "",
            "ALTER TABLE recipe ADD COLUMN IF NOT EXISTS image_is_family boolean "
            "NOT NULL DEFAULT false;",
            "",
        ]
        for fam, slugs in sorted(assigned.items()):
            names = ", ".join(f"'{s}'" for s in sorted(slugs))
            out.append(
                f"UPDATE recipe SET image_url = '/recipes/{FILES[fam]}.webp',\n"
                f"                  image_is_family = true\n"
                f"  WHERE image_url IS NULL AND slug IN ({names});")
        out.append("\nCOMMIT;")
        dest.write_text("\n".join(out) + "\n")
        print(f"\nwrote {dest}")


if __name__ == "__main__":
    main()
