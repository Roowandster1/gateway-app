-- 018 — the gluten-free breakfasts the generator could not reach
--
-- Migration 016 culled eighteen breakfasts nobody would eat. Seven of them
-- were the rice-and-potato ones, which happened to be the gluten-free ones,
-- and the export afterwards showed the damage: eight combinations that used
-- to have a feasible plan had none, all gluten-free at fourteen days, at both
-- stores. The solver named it exactly — "there are not enough breakfast
-- recipes to fill that many days" — because oats are gluten-bearing in this
-- catalogue, which left three gluten-free breakfasts against a max_repeat of
-- three.
--
-- The answer is not to put the yoghurt-on-a-jacket-potato back. It is that the
-- generator could not build the gluten-free breakfasts its own rules allow.
-- Three faults, all in generate_recipes.py:
--
--   * eggs were only a protein, and a recipe gets one protein, so "eggs and
--     cheese" could not be expressed at all;
--   * shape_of read eggs as both base and protein, collapsing every egg
--     breakfast into one shape where the cap kept three of twelve;
--   * the cap ran before the name dedupe, so all three slots of a shape went
--     to variants that render as the same name and the dedupe then collapsed
--     them to one.
--
-- Gluten-free breakfasts: 3 -> 6. 7 recipes added here.

BEGIN;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-eggs-toms', 'Egg & tomato toast', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-eggs-toms'), (SELECT id FROM item WHERE slug='bread'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-eggs-toms'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-bread-eggs-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-toms', 'Toast & tomato', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-toms'), (SELECT id FROM item WHERE slug='bread'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-eggs', 'Cheese egg', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-eggs'), (SELECT id FROM item WHERE slug='cheese'), 45.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-eggs'), (SELECT id FROM item WHERE slug='eggs'), 2)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-eggs-toms', 'Cheese & tomato egg', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-eggs-toms'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-eggs-toms'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-cheese-eggs-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-potato-toms', 'Egg & tomato potatoes', 45, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-potato-toms'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-potato-toms'), (SELECT id FROM item WHERE slug='potato'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-eggs-potato-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-banana-bread', 'Toast & banana', 4, 'snack', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-banana-bread'), (SELECT id FROM item WHERE slug='banana'), 1.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-bread'), (SELECT id FROM item WHERE slug='bread'), 80.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-banana-tortilla', 'Wrap & banana', 8, 'snack', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-banana-tortilla'), (SELECT id FROM item WHERE slug='banana'), 1.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 100.0)
  ON CONFLICT DO NOTHING;

COMMIT;
