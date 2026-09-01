-- 013 — generated recipes
--
-- Produced by services/solver/scripts/generate_recipes.py: deterministic
-- enumeration over the priced catalogue, portions solved to a calorie
-- target, macros computed from the item table. No model was asked for an
-- ingredient or a quantity — CLAUDE.md rule 1. Cooking steps are written
-- separately by generate_methods.py, which is the one thing rule 1 allows
-- a model to do, and every step goes through method_check.py.
--
-- Re-runnable: ON CONFLICT DO NOTHING, so the hand-written 24 are never
-- touched and a second run adds only what is new.

BEGIN;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-banana-bread-eggs', 'Egg & banana toast', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-banana-bread-eggs'), (SELECT id FROM item WHERE slug='banana'), 1.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-bread-eggs'), (SELECT id FROM item WHERE slug='bread'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-bread-eggs'), (SELECT id FROM item WHERE slug='eggs'), 2)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-banana-bread-yoghurt', 'Yoghurt & banana toast', 4, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-banana-bread-yoghurt'), (SELECT id FROM item WHERE slug='banana'), 1.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-bread-yoghurt'), (SELECT id FROM item WHERE slug='bread'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-bread-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-banana-eggs-tortilla', 'Egg & banana wrap', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-banana-eggs-tortilla'), (SELECT id FROM item WHERE slug='banana'), 1.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-eggs-tortilla'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-banana-eggs-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-banana-pb-tortilla', 'Peanut butter & banana wrap', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-banana-pb-tortilla'), (SELECT id FROM item WHERE slug='banana'), 1.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-pb-tortilla'), (SELECT id FROM item WHERE slug='pb'), 30.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-pb-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-banana-tortilla-yoghurt', 'Yoghurt & banana wrap', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-banana-tortilla-yoghurt'), (SELECT id FROM item WHERE slug='banana'), 1.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-tortilla-yoghurt'), (SELECT id FROM item WHERE slug='tortilla'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-tortilla-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-bread', 'Bean toast', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-bread'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-bread'), (SELECT id FROM item WHERE slug='bread'), 80.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-oil', 'Bean', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-oil'), (SELECT id FROM item WHERE slug='beans'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-oil'), (SELECT id FROM item WHERE slug='oil'), 10.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-potato', 'Bean potatoes', 45, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-potato'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-potato'), (SELECT id FROM item WHERE slug='potato'), 280.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-rice-toms', 'Bean & tomato rice', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-rice-toms'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-rice-toms'), (SELECT id FROM item WHERE slug='rice'), 65.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-rice-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-toms', 'Bean & tomato', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-toms'), (SELECT id FROM item WHERE slug='beans'), 385.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-tortilla', 'Bean wrap', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-tortilla'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-pb', 'Peanut butter toast', 4, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-pb'), (SELECT id FROM item WHERE slug='bread'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-pb'), (SELECT id FROM item WHERE slug='pb'), 30.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-yoghurt', 'Yoghurt toast', 4, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-yoghurt'), (SELECT id FROM item WHERE slug='bread'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 180.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-oil', 'Cheese', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-oil'), (SELECT id FROM item WHERE slug='cheese'), 60.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-oil'), (SELECT id FROM item WHERE slug='oil'), 10.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-potato', 'Cheese potatoes', 45, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-potato'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-potato'), (SELECT id FROM item WHERE slug='potato'), 280.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-rice', 'Cheese rice', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-rice'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-rice'), (SELECT id FROM item WHERE slug='rice'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-toms', 'Cheese & tomato', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-toms'), (SELECT id FROM item WHERE slug='cheese'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-tortilla', 'Cheese wrap', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-tortilla'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-potato', 'Egg potatoes', 45, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-potato'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-potato'), (SELECT id FROM item WHERE slug='potato'), 280.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-rice', 'Egg rice', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-rice'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-rice'), (SELECT id FROM item WHERE slug='rice'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-tortilla', 'Egg wrap', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-tortilla'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-milk-oats-pb', 'Peanut butter porridge', 4, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-milk-oats-pb'), (SELECT id FROM item WHERE slug='milk'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-milk-oats-pb'), (SELECT id FROM item WHERE slug='oats'), 50.0),
  ((SELECT id FROM recipe WHERE slug='g-milk-oats-pb'), (SELECT id FROM item WHERE slug='pb'), 30.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-oats-yoghurt', 'Yoghurt porridge', 4, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-oats-yoghurt'), (SELECT id FROM item WHERE slug='oats'), 65.0),
  ((SELECT id FROM recipe WHERE slug='g-oats-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-pb-tortilla', 'Peanut butter wrap', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-pb-tortilla'), (SELECT id FROM item WHERE slug='pb'), 30.0),
  ((SELECT id FROM recipe WHERE slug='g-pb-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-potato-toms-yoghurt', 'Yoghurt & tomato potatoes', 45, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-potato-toms-yoghurt'), (SELECT id FROM item WHERE slug='potato'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-potato-toms-yoghurt'), (SELECT id FROM item WHERE slug='toms'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-potato-toms-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-potato-yoghurt', 'Yoghurt potatoes', 45, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-potato-yoghurt'), (SELECT id FROM item WHERE slug='potato'), 310.0),
  ((SELECT id FROM recipe WHERE slug='g-potato-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 165.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-rice-toms-yoghurt', 'Yoghurt & tomato rice', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-rice-toms-yoghurt'), (SELECT id FROM item WHERE slug='rice'), 65.0),
  ((SELECT id FROM recipe WHERE slug='g-rice-toms-yoghurt'), (SELECT id FROM item WHERE slug='toms'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-rice-toms-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-tortilla-yoghurt', 'Yoghurt wrap', 8, 'breakfast', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-tortilla-yoghurt'), (SELECT id FROM item WHERE slug='tortilla'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-tortilla-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-bread-curry', 'Bean curry with toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-bread-curry'), (SELECT id FROM item WHERE slug='beans'), 265.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-bread-curry'), (SELECT id FROM item WHERE slug='bread'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-bread-curry'), (SELECT id FROM item WHERE slug='curry'), 5.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-bread-frozveg', 'Bean & veg toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-bread-frozveg'), (SELECT id FROM item WHERE slug='beans'), 240.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-bread-frozveg'), (SELECT id FROM item WHERE slug='bread'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-bread-frozveg'), (SELECT id FROM item WHERE slug='frozveg'), 120.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-carrot-tortilla-big', 'Bean & carrot wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-carrot-tortilla-big'), (SELECT id FROM item WHERE slug='beans'), 385.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-carrot-tortilla-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-carrot-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 215.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-curry-frozveg-pasta', 'Bean curry with pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-curry-frozveg-pasta'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-curry-frozveg-pasta'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-curry-frozveg-pasta'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-curry-frozveg-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-curry-noodles-peas', 'Bean curry with noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-curry-noodles-peas'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-curry-noodles-peas'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-curry-noodles-peas'), (SELECT id FROM item WHERE slug='noodles'), 65.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-curry-noodles-peas'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-frozveg-oil-pasta-big', 'Bean & veg pasta (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-frozveg-oil-pasta-big'), (SELECT id FROM item WHERE slug='beans'), 410.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-frozveg-oil-pasta-big'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-frozveg-oil-pasta-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-frozveg-oil-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-frozveg-tortilla', 'Bean & veg wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-frozveg-tortilla'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-frozveg-tortilla'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-frozveg-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-noodles-peas', 'Bean & pea noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-noodles-peas'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-noodles-peas'), (SELECT id FROM item WHERE slug='noodles'), 65.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-noodles-peas'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-oil-pasta-peas-big', 'Bean & pea pasta (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-oil-pasta-peas-big'), (SELECT id FROM item WHERE slug='beans'), 385.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-oil-pasta-peas-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-oil-pasta-peas-big'), (SELECT id FROM item WHERE slug='pasta'), 145.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-oil-pasta-peas-big'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-pasta-peas', 'Bean & pea pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-pasta-peas'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-pasta-peas'), (SELECT id FROM item WHERE slug='pasta'), 75.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-pasta-peas'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-peas-tortilla', 'Bean & pea wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-peas-tortilla'), (SELECT id FROM item WHERE slug='beans'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-peas-tortilla'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-peas-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-beans-tortilla-big', 'Bean wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-beans-tortilla-big'), (SELECT id FROM item WHERE slug='beans'), 410.0),
  ((SELECT id FROM recipe WHERE slug='g-beans-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 225.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-carrot-cheese', 'Cheese & carrot toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-cheese'), (SELECT id FROM item WHERE slug='bread'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-cheese'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-cheese'), (SELECT id FROM item WHERE slug='cheese'), 50.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-carrot-chicken', 'Chicken & carrot toast', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-chicken'), (SELECT id FROM item WHERE slug='bread'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-chicken'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-chicken'), (SELECT id FROM item WHERE slug='chicken'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-carrot-chickpeas', 'Chickpea & carrot toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-chickpeas'), (SELECT id FROM item WHERE slug='bread'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-chickpeas'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-chickpeas'), (SELECT id FROM item WHERE slug='chickpeas'), 180.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-carrot-eggs', 'Egg & carrot toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-eggs'), (SELECT id FROM item WHERE slug='bread'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-eggs'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-eggs'), (SELECT id FROM item WHERE slug='eggs'), 2)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-carrot-kidney', 'Kidney bean & carrot toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-kidney'), (SELECT id FROM item WHERE slug='bread'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-kidney'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-kidney'), (SELECT id FROM item WHERE slug='kidney'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-carrot-lentils', 'Lentil & carrot toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-lentils'), (SELECT id FROM item WHERE slug='bread'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-lentils'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-lentils'), (SELECT id FROM item WHERE slug='lentils'), 70.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-carrot-mince', 'Beef & carrot toast', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-mince'), (SELECT id FROM item WHERE slug='bread'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-mince'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-mince'), (SELECT id FROM item WHERE slug='mince'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-carrot-tuna', 'Tuna & carrot toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-tuna'), (SELECT id FROM item WHERE slug='bread'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-tuna'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-carrot-tuna'), (SELECT id FROM item WHERE slug='tuna'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-cheese-curry', 'Cheese curry with toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-cheese-curry'), (SELECT id FROM item WHERE slug='bread'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-cheese-curry'), (SELECT id FROM item WHERE slug='cheese'), 50.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-cheese-curry'), (SELECT id FROM item WHERE slug='curry'), 5.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-chicken', 'Chicken toast', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-chicken'), (SELECT id FROM item WHERE slug='bread'), 90.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-chicken'), (SELECT id FROM item WHERE slug='chicken'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-chicken-oil-peas-big', 'Chicken & pea toast (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-chicken-oil-peas-big'), (SELECT id FROM item WHERE slug='bread'), 140.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-chicken-oil-peas-big'), (SELECT id FROM item WHERE slug='chicken'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-chicken-oil-peas-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-chicken-oil-peas-big'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-chickpeas', 'Chickpea toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-chickpeas'), (SELECT id FROM item WHERE slug='bread'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-chickpeas'), (SELECT id FROM item WHERE slug='chickpeas'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-curry-eggs', 'Egg curry with toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-curry-eggs'), (SELECT id FROM item WHERE slug='bread'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-curry-eggs'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-curry-eggs'), (SELECT id FROM item WHERE slug='eggs'), 2)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-frozveg-lentils-oil-big', 'Lentil & veg toast (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-frozveg-lentils-oil-big'), (SELECT id FROM item WHERE slug='bread'), 140.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-frozveg-lentils-oil-big'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-frozveg-lentils-oil-big'), (SELECT id FROM item WHERE slug='lentils'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-frozveg-lentils-oil-big'), (SELECT id FROM item WHERE slug='oil'), 10.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-frozveg-mince-big', 'Beef & veg toast (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-frozveg-mince-big'), (SELECT id FROM item WHERE slug='bread'), 140.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-frozveg-mince-big'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-frozveg-mince-big'), (SELECT id FROM item WHERE slug='mince'), 250.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-kidney', 'Kidney bean toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-kidney'), (SELECT id FROM item WHERE slug='bread'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-kidney'), (SELECT id FROM item WHERE slug='kidney'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-lentils', 'Lentil toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-lentils'), (SELECT id FROM item WHERE slug='bread'), 90.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-lentils'), (SELECT id FROM item WHERE slug='lentils'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-lentils-oil-peas-big', 'Lentil & pea toast (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-lentils-oil-peas-big'), (SELECT id FROM item WHERE slug='bread'), 140.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-lentils-oil-peas-big'), (SELECT id FROM item WHERE slug='lentils'), 145.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-lentils-oil-peas-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-lentils-oil-peas-big'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-mince', 'Beef toast', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-mince'), (SELECT id FROM item WHERE slug='bread'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-mince'), (SELECT id FROM item WHERE slug='mince'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-mince-oil-big', 'Beef toast (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-mince-oil-big'), (SELECT id FROM item WHERE slug='bread'), 140.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-mince-oil-big'), (SELECT id FROM item WHERE slug='mince'), 235.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-mince-oil-big'), (SELECT id FROM item WHERE slug='oil'), 10.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-bread-tuna', 'Tuna toast', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-bread-tuna'), (SELECT id FROM item WHERE slug='bread'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-bread-tuna'), (SELECT id FROM item WHERE slug='tuna'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-cheese-noodles-oil-big', 'Cheese & carrot noodles (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-noodles-oil-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-noodles-oil-big'), (SELECT id FROM item WHERE slug='cheese'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-noodles-oil-big'), (SELECT id FROM item WHERE slug='noodles'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-noodles-oil-big'), (SELECT id FROM item WHERE slug='oil'), 10.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-cheese-oil-rice-big', 'Cheese & carrot rice (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-oil-rice-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-oil-rice-big'), (SELECT id FROM item WHERE slug='cheese'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-oil-rice-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-oil-rice-big'), (SELECT id FROM item WHERE slug='rice'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-cheese-tortilla-big', 'Cheese & carrot wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-tortilla-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-tortilla-big'), (SELECT id FROM item WHERE slug='cheese'), 75.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-cheese-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 215.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chicken', 'Chicken & carrot', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken'), (SELECT id FROM item WHERE slug='chicken'), 260.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chicken-noodles', 'Chicken & carrot noodles', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-noodles'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-noodles'), (SELECT id FROM item WHERE slug='chicken'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-noodles'), (SELECT id FROM item WHERE slug='noodles'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chicken-noodles-big', 'Chicken & carrot noodles (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-noodles-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-noodles-big'), (SELECT id FROM item WHERE slug='chicken'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-noodles-big'), (SELECT id FROM item WHERE slug='noodles'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chicken-pasta', 'Chicken & carrot pasta', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-pasta'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-pasta'), (SELECT id FROM item WHERE slug='chicken'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chicken-pasta-big', 'Chicken & carrot pasta (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-pasta-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-pasta-big'), (SELECT id FROM item WHERE slug='chicken'), 260.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chicken-potato', 'Chicken & carrot potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-potato'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-potato'), (SELECT id FROM item WHERE slug='chicken'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-potato'), (SELECT id FROM item WHERE slug='potato'), 280.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chicken-rice', 'Chicken & carrot rice', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-rice'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-rice'), (SELECT id FROM item WHERE slug='chicken'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-rice'), (SELECT id FROM item WHERE slug='rice'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chicken-tortilla', 'Chicken & carrot wrap', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-tortilla'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-tortilla'), (SELECT id FROM item WHERE slug='chicken'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chicken-tortilla-big', 'Chicken & carrot wrap (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-tortilla-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-tortilla-big'), (SELECT id FROM item WHERE slug='chicken'), 235.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chicken-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 195.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chickpeas-oil-pasta-big', 'Chickpea & carrot pasta (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chickpeas-oil-pasta-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chickpeas-oil-pasta-big'), (SELECT id FROM item WHERE slug='chickpeas'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chickpeas-oil-pasta-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chickpeas-oil-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-chickpeas-tortilla-big', 'Chickpea & carrot wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-chickpeas-tortilla-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chickpeas-tortilla-big'), (SELECT id FROM item WHERE slug='chickpeas'), 290.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-chickpeas-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 215.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-eggs-noodles', 'Egg & carrot noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-eggs-noodles'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-eggs-noodles'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-carrot-eggs-noodles'), (SELECT id FROM item WHERE slug='noodles'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-eggs-pasta', 'Egg & carrot pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-eggs-pasta'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-eggs-pasta'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-carrot-eggs-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-eggs-tortilla', 'Egg & carrot wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-eggs-tortilla'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-eggs-tortilla'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-carrot-eggs-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-kidney-noodles', 'Kidney bean & carrot noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-kidney-noodles'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-kidney-noodles'), (SELECT id FROM item WHERE slug='kidney'), 180.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-kidney-noodles'), (SELECT id FROM item WHERE slug='noodles'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-kidney-tortilla-big', 'Kidney bean & carrot wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-kidney-tortilla-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-kidney-tortilla-big'), (SELECT id FROM item WHERE slug='kidney'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-kidney-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 225.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-lentils', 'Lentil & carrot', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils'), (SELECT id FROM item WHERE slug='lentils'), 120.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-lentils-noodles', 'Lentil & carrot noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-noodles'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-noodles'), (SELECT id FROM item WHERE slug='lentils'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-noodles'), (SELECT id FROM item WHERE slug='noodles'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-lentils-noodles-big', 'Lentil & carrot noodles (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-noodles-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-noodles-big'), (SELECT id FROM item WHERE slug='lentils'), 145.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-noodles-big'), (SELECT id FROM item WHERE slug='noodles'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-lentils-pasta', 'Lentil & carrot pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-pasta'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-pasta'), (SELECT id FROM item WHERE slug='lentils'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-lentils-pasta-big', 'Lentil & carrot pasta (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-pasta-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-pasta-big'), (SELECT id FROM item WHERE slug='lentils'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-lentils-potato', 'Lentil & carrot potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-potato'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-potato'), (SELECT id FROM item WHERE slug='lentils'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-potato'), (SELECT id FROM item WHERE slug='potato'), 280.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-lentils-rice', 'Lentil & carrot rice', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-rice'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-rice'), (SELECT id FROM item WHERE slug='lentils'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-rice'), (SELECT id FROM item WHERE slug='rice'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-lentils-rice-big', 'Lentil & carrot rice (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-rice-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-rice-big'), (SELECT id FROM item WHERE slug='lentils'), 145.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-rice-big'), (SELECT id FROM item WHERE slug='rice'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-lentils-tortilla', 'Lentil & carrot wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-tortilla'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-tortilla'), (SELECT id FROM item WHERE slug='lentils'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-lentils-tortilla-big', 'Lentil & carrot wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-tortilla-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-tortilla-big'), (SELECT id FROM item WHERE slug='lentils'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-lentils-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 195.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince', 'Beef & carrot', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince'), (SELECT id FROM item WHERE slug='mince'), 175.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince-noodles', 'Beef & carrot noodles', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-noodles'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-noodles'), (SELECT id FROM item WHERE slug='mince'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-noodles'), (SELECT id FROM item WHERE slug='noodles'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince-noodles-big', 'Beef & carrot noodles (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-noodles-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-noodles-big'), (SELECT id FROM item WHERE slug='mince'), 215.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-noodles-big'), (SELECT id FROM item WHERE slug='noodles'), 120.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince-pasta', 'Beef & carrot pasta', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-pasta'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-pasta'), (SELECT id FROM item WHERE slug='mince'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince-pasta-big', 'Beef & carrot pasta (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-pasta-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-pasta-big'), (SELECT id FROM item WHERE slug='mince'), 215.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince-potato', 'Beef & carrot potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-potato'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-potato'), (SELECT id FROM item WHERE slug='mince'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-potato'), (SELECT id FROM item WHERE slug='potato'), 280.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince-potato-big', 'Beef & carrot potatoes (big portion)', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-potato-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-potato-big'), (SELECT id FROM item WHERE slug='mince'), 215.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-potato-big'), (SELECT id FROM item WHERE slug='potato'), 550.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince-rice', 'Beef & carrot rice', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-rice'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-rice'), (SELECT id FROM item WHERE slug='mince'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-rice'), (SELECT id FROM item WHERE slug='rice'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince-rice-big', 'Beef & carrot rice (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-rice-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-rice-big'), (SELECT id FROM item WHERE slug='mince'), 215.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-rice-big'), (SELECT id FROM item WHERE slug='rice'), 120.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince-tortilla', 'Beef & carrot wrap', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-tortilla'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-tortilla'), (SELECT id FROM item WHERE slug='mince'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-mince-tortilla-big', 'Beef & carrot wrap (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-tortilla-big'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-tortilla-big'), (SELECT id FROM item WHERE slug='mince'), 175.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-mince-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 175.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-noodles-tuna', 'Tuna & carrot noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-noodles-tuna'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-noodles-tuna'), (SELECT id FROM item WHERE slug='noodles'), 90.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-noodles-tuna'), (SELECT id FROM item WHERE slug='tuna'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-pasta-tuna', 'Tuna & carrot pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-pasta-tuna'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-pasta-tuna'), (SELECT id FROM item WHERE slug='pasta'), 90.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-pasta-tuna'), (SELECT id FROM item WHERE slug='tuna'), 120.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-potato-tuna', 'Tuna & carrot potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-potato-tuna'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-potato-tuna'), (SELECT id FROM item WHERE slug='potato'), 375.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-potato-tuna'), (SELECT id FROM item WHERE slug='tuna'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-rice-tuna', 'Tuna & carrot rice', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-rice-tuna'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-rice-tuna'), (SELECT id FROM item WHERE slug='rice'), 90.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-rice-tuna'), (SELECT id FROM item WHERE slug='tuna'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-carrot-tortilla-tuna', 'Tuna & carrot wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-carrot-tortilla-tuna'), (SELECT id FROM item WHERE slug='carrot'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-tortilla-tuna'), (SELECT id FROM item WHERE slug='tortilla'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-carrot-tortilla-tuna'), (SELECT id FROM item WHERE slug='tuna'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-frozveg', 'Cheese & veg', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg'), (SELECT id FROM item WHERE slug='cheese'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg'), (SELECT id FROM item WHERE slug='frozveg'), 120.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-frozveg-noodles-oil-big', 'Cheese noodle stir-fry (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-noodles-oil-big'), (SELECT id FROM item WHERE slug='cheese'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-noodles-oil-big'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-noodles-oil-big'), (SELECT id FROM item WHERE slug='noodles'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-noodles-oil-big'), (SELECT id FROM item WHERE slug='oil'), 10.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-frozveg-oil-rice-big', 'Cheese & veg rice (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-oil-rice-big'), (SELECT id FROM item WHERE slug='cheese'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-oil-rice-big'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-oil-rice-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-oil-rice-big'), (SELECT id FROM item WHERE slug='rice'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-frozveg-pasta', 'Cheese & veg pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-pasta'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-pasta'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-frozveg-pasta-big', 'Cheese & veg pasta (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-pasta-big'), (SELECT id FROM item WHERE slug='cheese'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-pasta-big'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-frozveg-tortilla', 'Cheese & veg wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-tortilla'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-tortilla'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-frozveg-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-noodles-peas', 'Cheese & pea noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-noodles-peas'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-noodles-peas'), (SELECT id FROM item WHERE slug='noodles'), 65.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-noodles-peas'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-noodles-toms', 'Cheese & tomato noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-noodles-toms'), (SELECT id FROM item WHERE slug='cheese'), 45.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-noodles-toms'), (SELECT id FROM item WHERE slug='noodles'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-noodles-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-oil-pasta-big', 'Cheese pasta (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-oil-pasta-big'), (SELECT id FROM item WHERE slug='cheese'), 90.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-oil-pasta-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-oil-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-oil-peas-potato-big', 'Cheese & pea potatoes (big portion)', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-oil-peas-potato-big'), (SELECT id FROM item WHERE slug='cheese'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-oil-peas-potato-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-oil-peas-potato-big'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-oil-peas-potato-big'), (SELECT id FROM item WHERE slug='potato'), 550.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-pasta-peas', 'Cheese & pea pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-pasta-peas'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-pasta-peas'), (SELECT id FROM item WHERE slug='pasta'), 75.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-pasta-peas'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-peas', 'Cheese & pea', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-peas'), (SELECT id FROM item WHERE slug='cheese'), 90.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-peas'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-peas-potato-stock', 'Cheese & pea potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-peas-potato-stock'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-peas-potato-stock'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-peas-potato-stock'), (SELECT id FROM item WHERE slug='potato'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-peas-potato-stock'), (SELECT id FROM item WHERE slug='stock'), 1.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-peas-tortilla', 'Cheese & pea wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-peas-tortilla'), (SELECT id FROM item WHERE slug='cheese'), 40.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-peas-tortilla'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-peas-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-cheese-tortilla-big', 'Cheese wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-cheese-tortilla-big'), (SELECT id FROM item WHERE slug='cheese'), 80.0),
  ((SELECT id FROM recipe WHERE slug='g-cheese-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 225.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-curry', 'Chicken curry', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-curry'), (SELECT id FROM item WHERE slug='chicken'), 260.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-curry'), (SELECT id FROM item WHERE slug='curry'), 5.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-frozveg-noodles-big', 'Chicken noodle stir-fry (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-frozveg-noodles-big'), (SELECT id FROM item WHERE slug='chicken'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-frozveg-noodles-big'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-frozveg-noodles-big'), (SELECT id FROM item WHERE slug='noodles'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-frozveg-rice-big', 'Chicken & veg rice (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-frozveg-rice-big'), (SELECT id FROM item WHERE slug='chicken'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-frozveg-rice-big'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-frozveg-rice-big'), (SELECT id FROM item WHERE slug='rice'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-noodles', 'Chicken noodles', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-noodles'), (SELECT id FROM item WHERE slug='chicken'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-noodles'), (SELECT id FROM item WHERE slug='noodles'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-oil-potato-big', 'Chicken potatoes (big portion)', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-oil-potato-big'), (SELECT id FROM item WHERE slug='chicken'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-oil-potato-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-oil-potato-big'), (SELECT id FROM item WHERE slug='potato'), 550.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-oil-rice-big', 'Chicken rice (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-oil-rice-big'), (SELECT id FROM item WHERE slug='chicken'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-oil-rice-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-oil-rice-big'), (SELECT id FROM item WHERE slug='rice'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-pasta', 'Chicken pasta', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-pasta'), (SELECT id FROM item WHERE slug='chicken'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-pasta-big', 'Chicken pasta (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-pasta-big'), (SELECT id FROM item WHERE slug='chicken'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-peas-potato-big', 'Chicken & pea potatoes (big portion)', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-peas-potato-big'), (SELECT id FROM item WHERE slug='chicken'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-peas-potato-big'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-peas-potato-big'), (SELECT id FROM item WHERE slug='potato'), 550.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-potato', 'Chicken potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-potato'), (SELECT id FROM item WHERE slug='chicken'), 145.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-potato'), (SELECT id FROM item WHERE slug='potato'), 310.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-rice', 'Chicken rice', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-rice'), (SELECT id FROM item WHERE slug='chicken'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-rice'), (SELECT id FROM item WHERE slug='rice'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-tortilla', 'Chicken wrap', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-tortilla'), (SELECT id FROM item WHERE slug='chicken'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chicken-tortilla-big', 'Chicken wrap (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chicken-tortilla-big'), (SELECT id FROM item WHERE slug='chicken'), 235.0),
  ((SELECT id FROM recipe WHERE slug='g-chicken-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 195.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-curry-pasta-peas-big', 'Chickpea curry with pasta (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-pasta-peas-big'), (SELECT id FROM item WHERE slug='chickpeas'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-pasta-peas-big'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-pasta-peas-big'), (SELECT id FROM item WHERE slug='pasta'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-pasta-peas-big'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-curry-peas', 'Chickpea curry', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-peas'), (SELECT id FROM item WHERE slug='chickpeas'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-peas'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-peas'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-curry-peas-potato', 'Chickpea curry with potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-peas-potato'), (SELECT id FROM item WHERE slug='chickpeas'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-peas-potato'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-peas-potato'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-curry-peas-potato'), (SELECT id FROM item WHERE slug='potato'), 280.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-frozveg-pasta', 'Chickpea & veg pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-frozveg-pasta'), (SELECT id FROM item WHERE slug='chickpeas'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-frozveg-pasta'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-frozveg-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-frozveg-tortilla', 'Chickpea & veg wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-frozveg-tortilla'), (SELECT id FROM item WHERE slug='chickpeas'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-frozveg-tortilla'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-frozveg-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-noodles-oil-peas-big', 'Chickpea & pea noodles (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-noodles-oil-peas-big'), (SELECT id FROM item WHERE slug='chickpeas'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-noodles-oil-peas-big'), (SELECT id FROM item WHERE slug='noodles'), 130.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-noodles-oil-peas-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-noodles-oil-peas-big'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-noodles-peas', 'Chickpea & pea noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-noodles-peas'), (SELECT id FROM item WHERE slug='chickpeas'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-noodles-peas'), (SELECT id FROM item WHERE slug='noodles'), 65.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-noodles-peas'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-noodles-toms', 'Chickpea & tomato noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-noodles-toms'), (SELECT id FROM item WHERE slug='chickpeas'), 165.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-noodles-toms'), (SELECT id FROM item WHERE slug='noodles'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-noodles-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-oil', 'Chickpea', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-oil'), (SELECT id FROM item WHERE slug='chickpeas'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-oil'), (SELECT id FROM item WHERE slug='oil'), 10.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-pasta-peas', 'Chickpea & pea pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-pasta-peas'), (SELECT id FROM item WHERE slug='chickpeas'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-pasta-peas'), (SELECT id FROM item WHERE slug='pasta'), 75.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-pasta-peas'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-peas-potato-stock', 'Chickpea & pea potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-peas-potato-stock'), (SELECT id FROM item WHERE slug='chickpeas'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-peas-potato-stock'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-peas-potato-stock'), (SELECT id FROM item WHERE slug='potato'), 280.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-peas-potato-stock'), (SELECT id FROM item WHERE slug='stock'), 1.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-peas-tortilla', 'Chickpea & pea wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-peas-tortilla'), (SELECT id FROM item WHERE slug='chickpeas'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-peas-tortilla'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-peas-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-chickpeas-tortilla-big', 'Chickpea wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-tortilla-big'), (SELECT id FROM item WHERE slug='chickpeas'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-chickpeas-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 225.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-curry-eggs-peas-rice', 'Egg curry with rice', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-curry-eggs-peas-rice'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-curry-eggs-peas-rice'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-curry-eggs-peas-rice'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-curry-eggs-peas-rice'), (SELECT id FROM item WHERE slug='rice'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-curry-eggs-tortilla', 'Egg curry with wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-curry-eggs-tortilla'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-curry-eggs-tortilla'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-curry-eggs-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-curry-kidney-noodles', 'Kidney bean curry with noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-curry-kidney-noodles'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-curry-kidney-noodles'), (SELECT id FROM item WHERE slug='kidney'), 180.0),
  ((SELECT id FROM recipe WHERE slug='g-curry-kidney-noodles'), (SELECT id FROM item WHERE slug='noodles'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-curry-lentils', 'Lentil curry', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-curry-lentils'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-curry-lentils'), (SELECT id FROM item WHERE slug='lentils'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-curry-lentils-rice-big', 'Lentil curry with rice (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-curry-lentils-rice-big'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-curry-lentils-rice-big'), (SELECT id FROM item WHERE slug='lentils'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-curry-lentils-rice-big'), (SELECT id FROM item WHERE slug='rice'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-curry-mince', 'Beef curry', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-curry-mince'), (SELECT id FROM item WHERE slug='curry'), 5.0),
  ((SELECT id FROM recipe WHERE slug='g-curry-mince'), (SELECT id FROM item WHERE slug='mince'), 175.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-frozveg-potato', 'Egg & veg potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-frozveg-potato'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-frozveg-potato'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-eggs-frozveg-potato'), (SELECT id FROM item WHERE slug='potato'), 340.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-noodles', 'Egg noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-noodles'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-noodles'), (SELECT id FROM item WHERE slug='noodles'), 90.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-oil-peas-tortilla-big', 'Egg & pea wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-oil-peas-tortilla-big'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-oil-peas-tortilla-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-eggs-oil-peas-tortilla-big'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-eggs-oil-peas-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 225.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-pasta', 'Egg pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-pasta'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-pasta'), (SELECT id FROM item WHERE slug='pasta'), 90.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-peas-potato', 'Egg & pea potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-peas-potato'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-peas-potato'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-eggs-peas-potato'), (SELECT id FROM item WHERE slug='potato'), 310.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-peas-rice', 'Egg & pea rice', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-peas-rice'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-peas-rice'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-eggs-peas-rice'), (SELECT id FROM item WHERE slug='rice'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-frozveg-kidney-oil', 'Kidney bean & veg', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-oil'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-oil'), (SELECT id FROM item WHERE slug='kidney'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-oil'), (SELECT id FROM item WHERE slug='oil'), 10.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-frozveg-kidney-oil-pasta-big', 'Kidney bean & veg pasta (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-oil-pasta-big'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-oil-pasta-big'), (SELECT id FROM item WHERE slug='kidney'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-oil-pasta-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-oil-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-frozveg-kidney-pasta', 'Kidney bean & veg pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-pasta'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-pasta'), (SELECT id FROM item WHERE slug='kidney'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-frozveg-kidney-tortilla', 'Kidney bean & veg wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-tortilla'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-tortilla'), (SELECT id FROM item WHERE slug='kidney'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-kidney-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-frozveg-lentils-potato-big', 'Lentil & veg potatoes (big portion)', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-frozveg-lentils-potato-big'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-lentils-potato-big'), (SELECT id FROM item WHERE slug='lentils'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-lentils-potato-big'), (SELECT id FROM item WHERE slug='potato'), 550.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-frozveg-lentils-rice', 'Lentil & veg rice', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-frozveg-lentils-rice'), (SELECT id FROM item WHERE slug='frozveg'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-lentils-rice'), (SELECT id FROM item WHERE slug='lentils'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-frozveg-lentils-rice'), (SELECT id FROM item WHERE slug='rice'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-kidney-oil-pasta-peas-big', 'Kidney bean & pea pasta (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-kidney-oil-pasta-peas-big'), (SELECT id FROM item WHERE slug='kidney'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-oil-pasta-peas-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-oil-pasta-peas-big'), (SELECT id FROM item WHERE slug='pasta'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-oil-pasta-peas-big'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-kidney-oil-peas', 'Kidney bean & pea', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-kidney-oil-peas'), (SELECT id FROM item WHERE slug='kidney'), 290.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-oil-peas'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-oil-peas'), (SELECT id FROM item WHERE slug='peas'), 100.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-kidney-pasta', 'Kidney bean pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-kidney-pasta'), (SELECT id FROM item WHERE slug='kidney'), 180.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-pasta'), (SELECT id FROM item WHERE slug='pasta'), 90.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-kidney-peas-potato', 'Kidney bean & pea potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-kidney-peas-potato'), (SELECT id FROM item WHERE slug='kidney'), 165.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-peas-potato'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-peas-potato'), (SELECT id FROM item WHERE slug='potato'), 310.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-kidney-peas-tortilla', 'Kidney bean & pea wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-kidney-peas-tortilla'), (SELECT id FROM item WHERE slug='kidney'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-peas-tortilla'), (SELECT id FROM item WHERE slug='peas'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-peas-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-kidney-tortilla-big', 'Kidney bean wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-kidney-tortilla-big'), (SELECT id FROM item WHERE slug='kidney'), 320.0),
  ((SELECT id FROM recipe WHERE slug='g-kidney-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 225.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-lentils-noodles', 'Lentil noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-lentils-noodles'), (SELECT id FROM item WHERE slug='lentils'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-lentils-noodles'), (SELECT id FROM item WHERE slug='noodles'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-lentils-noodles-big', 'Lentil noodles (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-lentils-noodles-big'), (SELECT id FROM item WHERE slug='lentils'), 150.0),
  ((SELECT id FROM recipe WHERE slug='g-lentils-noodles-big'), (SELECT id FROM item WHERE slug='noodles'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-lentils-oil-potato-big', 'Lentil potatoes (big portion)', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-lentils-oil-potato-big'), (SELECT id FROM item WHERE slug='lentils'), 145.0),
  ((SELECT id FROM recipe WHERE slug='g-lentils-oil-potato-big'), (SELECT id FROM item WHERE slug='oil'), 10.0),
  ((SELECT id FROM recipe WHERE slug='g-lentils-oil-potato-big'), (SELECT id FROM item WHERE slug='potato'), 550.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-lentils-pasta', 'Lentil pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-lentils-pasta'), (SELECT id FROM item WHERE slug='lentils'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-lentils-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-lentils-pasta-big', 'Lentil pasta (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-lentils-pasta-big'), (SELECT id FROM item WHERE slug='lentils'), 145.0),
  ((SELECT id FROM recipe WHERE slug='g-lentils-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-lentils-potato', 'Lentil potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-lentils-potato'), (SELECT id FROM item WHERE slug='lentils'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-lentils-potato'), (SELECT id FROM item WHERE slug='potato'), 280.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-lentils-tortilla', 'Lentil wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-lentils-tortilla'), (SELECT id FROM item WHERE slug='lentils'), 70.0),
  ((SELECT id FROM recipe WHERE slug='g-lentils-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-lentils-tortilla-big', 'Lentil wrap (big portion)', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-lentils-tortilla-big'), (SELECT id FROM item WHERE slug='lentils'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-lentils-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 195.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-mince-noodles', 'Beef noodles', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-mince-noodles'), (SELECT id FROM item WHERE slug='mince'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-mince-noodles'), (SELECT id FROM item WHERE slug='noodles'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-mince-noodles-big', 'Beef noodles (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-mince-noodles-big'), (SELECT id FROM item WHERE slug='mince'), 235.0),
  ((SELECT id FROM recipe WHERE slug='g-mince-noodles-big'), (SELECT id FROM item WHERE slug='noodles'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-mince-pasta', 'Beef pasta', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-mince-pasta'), (SELECT id FROM item WHERE slug='mince'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-mince-pasta'), (SELECT id FROM item WHERE slug='pasta'), 75.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-mince-pasta-big', 'Beef pasta (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-mince-pasta-big'), (SELECT id FROM item WHERE slug='mince'), 215.0),
  ((SELECT id FROM recipe WHERE slug='g-mince-pasta-big'), (SELECT id FROM item WHERE slug='pasta'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-mince-potato', 'Beef potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-mince-potato'), (SELECT id FROM item WHERE slug='mince'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-mince-potato'), (SELECT id FROM item WHERE slug='potato'), 280.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-mince-potato-big', 'Beef potatoes (big portion)', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-mince-potato-big'), (SELECT id FROM item WHERE slug='mince'), 235.0),
  ((SELECT id FROM recipe WHERE slug='g-mince-potato-big'), (SELECT id FROM item WHERE slug='potato'), 550.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-mince-rice', 'Beef rice', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-mince-rice'), (SELECT id FROM item WHERE slug='mince'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-mince-rice'), (SELECT id FROM item WHERE slug='rice'), 65.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-mince-rice-big', 'Beef rice (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-mince-rice-big'), (SELECT id FROM item WHERE slug='mince'), 235.0),
  ((SELECT id FROM recipe WHERE slug='g-mince-rice-big'), (SELECT id FROM item WHERE slug='rice'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-mince-tortilla', 'Beef wrap', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-mince-tortilla'), (SELECT id FROM item WHERE slug='mince'), 110.0),
  ((SELECT id FROM recipe WHERE slug='g-mince-tortilla'), (SELECT id FROM item WHERE slug='tortilla'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-mince-tortilla-big', 'Beef wrap (big portion)', 25, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-mince-tortilla-big'), (SELECT id FROM item WHERE slug='mince'), 195.0),
  ((SELECT id FROM recipe WHERE slug='g-mince-tortilla-big'), (SELECT id FROM item WHERE slug='tortilla'), 195.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-noodles-tuna', 'Tuna noodles', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-noodles-tuna'), (SELECT id FROM item WHERE slug='noodles'), 90.0),
  ((SELECT id FROM recipe WHERE slug='g-noodles-tuna'), (SELECT id FROM item WHERE slug='tuna'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-pasta-tuna', 'Tuna pasta', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-pasta-tuna'), (SELECT id FROM item WHERE slug='pasta'), 100.0),
  ((SELECT id FROM recipe WHERE slug='g-pasta-tuna'), (SELECT id FROM item WHERE slug='tuna'), 130.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-potato-tuna', 'Tuna potatoes', 45, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-potato-tuna'), (SELECT id FROM item WHERE slug='potato'), 415.0),
  ((SELECT id FROM recipe WHERE slug='g-potato-tuna'), (SELECT id FROM item WHERE slug='tuna'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-rice-tuna', 'Tuna rice', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-rice-tuna'), (SELECT id FROM item WHERE slug='rice'), 90.0),
  ((SELECT id FROM recipe WHERE slug='g-rice-tuna'), (SELECT id FROM item WHERE slug='tuna'), 145.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-tortilla-tuna', 'Tuna wrap', 18, 'main', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-tortilla-tuna'), (SELECT id FROM item WHERE slug='tortilla'), 120.0),
  ((SELECT id FROM recipe WHERE slug='g-tortilla-tuna'), (SELECT id FROM item WHERE slug='tuna'), 110.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-banana-eggs', 'Egg & banana', 8, 'snack', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-banana-eggs'), (SELECT id FROM item WHERE slug='banana'), 1.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-eggs'), (SELECT id FROM item WHERE slug='eggs'), 2)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-banana-yoghurt', 'Yoghurt & banana', 4, 'snack', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-banana-yoghurt'), (SELECT id FROM item WHERE slug='banana'), 1.0),
  ((SELECT id FROM recipe WHERE slug='g-banana-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 150.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-eggs-toms', 'Egg & tomato', 8, 'snack', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-eggs-toms'), (SELECT id FROM item WHERE slug='eggs'), 2),
  ((SELECT id FROM recipe WHERE slug='g-eggs-toms'), (SELECT id FROM item WHERE slug='toms'), 200.0)
  ON CONFLICT DO NOTHING;

INSERT INTO recipe (slug, name, minutes, meal_slot, serves_base) VALUES
  ('g-toms-yoghurt', 'Yoghurt & tomato', 8, 'snack', 1)
  ON CONFLICT (slug) DO NOTHING;
INSERT INTO recipe_ingredient (recipe_id, item_id, qty_per_serving) VALUES
  ((SELECT id FROM recipe WHERE slug='g-toms-yoghurt'), (SELECT id FROM item WHERE slug='toms'), 200.0),
  ((SELECT id FROM recipe WHERE slug='g-toms-yoghurt'), (SELECT id FROM item WHERE slug='yoghurt'), 180.0)
  ON CONFLICT DO NOTHING;

COMMIT;
