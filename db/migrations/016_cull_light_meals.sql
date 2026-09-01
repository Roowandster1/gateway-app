-- 016 — cull the breakfasts nobody would eat, and add the bowls
--
-- The owner's complaint, verbatim: "beans on toast and yoghurt on toast
-- that's not a good breakfast at all". He was right, and yoghurt on toast was
-- the least of it — the enumeration had also produced yoghurt on a jacket
-- potato, tinned tomatoes with cheese at 7am, and a bowl of beans and oil
-- called "Bean". Every one of them clears the calorie band and the protein
-- floor, because those rules describe nutrition and say nothing about whether
-- the plate is breakfast.
--
-- generate_recipes.py now carries a shape rule for the light meals: a
-- breakfast is built on one of five bases — porridge, a yoghurt bowl, toast, a
-- wrap, eggs — and carries only what that base takes. This migration applies
-- that rule to what migration 013 already inserted.
--
-- Only 'g-%' slugs are touched. The hand-written recipes are not candidates for
-- deletion and every one of them passes the new rules.
--
-- 20 deleted, 4 added.

BEGIN;

DELETE FROM recipe_ingredient WHERE recipe_id IN (
  SELECT id FROM recipe WHERE slug IN (
    'g-banana-bread-eggs',
    'g-banana-bread-yoghurt',
    'g-banana-eggs',
    'g-banana-eggs-tortilla',
    'g-banana-tortilla-yoghurt',
    'g-beans-oil',
    'g-beans-potato',
    'g-beans-rice-toms',
    'g-beans-toms',
    'g-bread-yoghurt',
    'g-cheese-oil',
    'g-cheese-potato',
    'g-cheese-rice',
    'g-cheese-toms',
    'g-eggs-rice',
    'g-potato-toms-yoghurt',
    'g-potato-yoghurt',
    'g-rice-toms-yoghurt',
    'g-toms-yoghurt',
    'g-tortilla-yoghurt'
  ));

DELETE FROM recipe WHERE slug IN (
    'g-banana-bread-eggs',
    'g-banana-bread-yoghurt',
    'g-banana-eggs',
    'g-banana-eggs-tortilla',
    'g-banana-tortilla-yoghurt',
    'g-beans-oil',
    'g-beans-potato',
    'g-beans-rice-toms',
    'g-beans-toms',
    'g-bread-yoghurt',
    'g-cheese-oil',
    'g-cheese-potato',
    'g-cheese-rice',
    'g-cheese-toms',
    'g-eggs-rice',
    'g-potato-toms-yoghurt',
    'g-potato-yoghurt',
    'g-rice-toms-yoghurt',
    'g-toms-yoghurt',
    'g-tortilla-yoghurt'
  );

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-banana-pb-yoghurt', 'Peanut butter & banana yoghurt', 4, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-banana-pb-yoghurt'), (SELECT id FROM item WHERE slug='banana'), 1.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-pb-yoghurt'), (SELECT id FROM item WHERE slug='pb'), 30.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-pb-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-bread-toms', 'Bean & tomato toast', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-bread-toms'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-bread-toms'), (SELECT id FROM item WHERE slug='bread'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-bread-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-cheese-toms', 'Cheese & tomato toast', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-cheese-toms'), (SELECT id FROM item WHERE slug='bread'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-cheese-toms'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-cheese-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-pb-yoghurt', 'Peanut butter yoghurt', 4, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-pb-yoghurt'), (SELECT id FROM item WHERE slug='pb'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-pb-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 180.0)
  ON CONFLICT DO NOTHING;

COMMIT;
