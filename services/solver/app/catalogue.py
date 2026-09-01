"""
Load the catalogue out of Postgres.

Only items with a current, sourced price at the requested store are returned.
CLAUDE.md rule 3: an item without a price is excluded from planning, never
guessed at. Recipes needing an excluded item are dropped with it, and the drop
is reported rather than swallowed.
"""
import psycopg

from . import config
from .domain import Item, Recipe

ITEM_SQL = """
SELECT i.slug, i.name, i.unit::text, i.aisle, i.kcal_per_100, i.protein_per_100,
       i.keeps::text, i.shelf_life_days, i.category::text, p.pack_size, p.price,
       coalesce((SELECT array_agg(a.allergen ORDER BY a.allergen)
                 FROM item_allergen a WHERE a.item_id = i.id), '{}')
FROM item i
JOIN item_price p ON p.item_id = i.id AND p.is_current
JOIN store s      ON s.id = p.store_id
WHERE s.slug = %s
"""

TAG_SQL = "SELECT r.slug, t.tag FROM recipe_tag t JOIN recipe r ON r.id = t.recipe_id"

RECIPE_SQL = """
SELECT r.slug, r.name, r.minutes, r.meal_slot::text, r.image_url,
       i.slug, ri.qty_per_serving
FROM recipe r
JOIN recipe_ingredient ri ON ri.recipe_id = r.id
JOIN item i               ON i.id = ri.item_id
ORDER BY r.slug
"""


def load(store: str, dsn: str | None = None
         ) -> tuple[dict[str, Item], dict[str, Recipe], list[str]]:
    """Returns (items, recipes, dropped_recipe_slugs)."""
    with psycopg.connect(dsn or config.DATABASE_URL) as conn:
        items = {
            row[0]: Item(
                slug=row[0], name=row[1], unit=row[2], aisle=row[3],
                kcal_per_100=float(row[4]), protein_per_100=float(row[5]),
                keeps=row[6], shelf_life_days=row[7], category=row[8],
                pack_size=float(row[9]), price=float(row[10]),
                allergens=frozenset(row[11]),
            )
            for row in conn.execute(ITEM_SQL, (store,))
        }
        if not items:
            raise ValueError(f"no priced items for store {store!r}")

        raw: dict[str, dict] = {}
        for slug, name, minutes, slot, image, item_slug, qty in conn.execute(RECIPE_SQL):
            r = raw.setdefault(slug, dict(name=name, minutes=minutes,
                                          slot=slot, image=image, ing={}))
            r["ing"][item_slug] = float(qty)

        tags: dict[str, set[str]] = {}
        for slug, tag in conn.execute(TAG_SQL):
            tags.setdefault(slug, set()).add(tag)

    recipes, dropped = {}, []
    for slug, r in raw.items():
        missing = set(r["ing"]) - set(items)
        if missing:
            dropped.append(f"{slug} (unpriced: {', '.join(sorted(missing))})")
            continue
        recipes[slug] = Recipe(slug=slug, name=r["name"], minutes=r["minutes"],
                               meal_slot=r["slot"], ingredients=r["ing"],
                               image_url=r["image"],
                               tags=frozenset(tags.get(slug, ())))
    return items, recipes, dropped
