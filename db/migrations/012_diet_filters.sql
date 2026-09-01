-- 012 — dietary, appliance and style filters
--
-- Adds the data three new onboarding screens need. Everything here is derived
-- from what the catalogue actually contains; nothing is invented.
--
-- ALLERGENS ARE NAME-DERIVED, NOT LABEL-DERIVED. They come from what the product
-- plainly is ("Egg noodles" contains egg), not from a scanned ingredients panel.
-- That is enough to filter a meal plan and NOT enough for someone with a real
-- allergy to rely on, which is why the UI says so out loud. Items whose allergen
-- status depends on the specific brand — stock cubes and wheat, oats and
-- cross-contamination is handled, but soy in stock is not knowable from the name
-- — are left untagged rather than guessed. Guessing a price costs money; guessing
-- an allergen costs more.

BEGIN;

CREATE TABLE item_allergen (
  item_id  integer NOT NULL REFERENCES item(id) ON DELETE CASCADE,
  allergen text    NOT NULL,
  PRIMARY KEY (item_id, allergen)
);

COMMENT ON TABLE item_allergen IS
  'Name-derived allergen groups. Not label data; not safe for a real allergy.';

INSERT INTO item_allergen (item_id, allergen)
SELECT i.id, a.allergen
FROM item i
JOIN (VALUES
  ('bread',    'gluten'),
  ('tortilla', 'gluten'),
  ('oats',     'gluten'),   -- UK oats are not gluten-free unless certified
  ('pasta',    'gluten'),
  ('noodles',  'gluten'),
  ('noodles',  'egg'),      -- they are egg noodles
  ('cheese',   'dairy'),
  ('milk',     'dairy'),
  ('yoghurt',  'dairy'),
  ('eggs',     'egg'),
  ('tuna',     'fish'),
  ('pb',       'peanut')
) AS a(slug, allergen) ON a.slug = i.slug;

-- ---------------------------------------------------------------------------
-- Appliances. A recipe names every appliance that can cook it; the solver keeps
-- a recipe when the user owns at least one of them. A recipe with no appliance
-- tag needs no appliance at all (the no-cook snacks).
--
-- Only two recipes need anything but a hob. An air fryer genuinely roasts a
-- traybake and bakes a jacket potato, and a microwave genuinely bakes a jacket,
-- so those alternatives are real rather than padding out the screen.
-- ---------------------------------------------------------------------------
INSERT INTO recipe_tag (recipe_id, tag)
SELECT r.id, t.tag
FROM recipe r
JOIN (VALUES
  ('jacket',     'app:oven'),
  ('jacket',     'app:airfryer'),
  ('jacket',     'app:microwave'),
  ('traybake',   'app:oven'),
  ('traybake',   'app:airfryer'),
  -- everything else that needs heat needs a hob
  ('beanstoast', 'app:hob'), ('eggstoast', 'app:hob'), ('eggwrap',    'app:hob'),
  ('oatpancake', 'app:hob'), ('pbtoast',   'app:hob'), ('porridge',   'app:hob'),
  ('bolognese',  'app:hob'), ('chickcurry','app:hob'), ('chilli',     'app:hob'),
  ('dahl',       'app:hob'), ('friedrice', 'app:hob'), ('omelette',   'app:hob'),
  ('soup',       'app:hob'), ('stirfry',   'app:hob'), ('tunapasta',  'app:hob'),
  ('wrap',       'app:hob'), ('boiledeggs','app:hob'), ('cheesetoast','app:hob')
  -- yogpb, oatpb, pbbanana, yogbanana need nothing: no tag
) AS t(slug, tag) ON t.slug = r.slug;

-- ---------------------------------------------------------------------------
-- Proteins, so "I don't eat X" can be honoured. The catalogue has beef, chicken,
-- fish and eggs; it has NO pork, so no pork option is offered anywhere.
-- ---------------------------------------------------------------------------
INSERT INTO recipe_tag (recipe_id, tag)
SELECT DISTINCT r.id, 'pro:' || p.protein
FROM recipe r
JOIN recipe_ingredient ri ON ri.recipe_id = r.id
JOIN item i ON i.id = ri.item_id
JOIN (VALUES
  ('mince',   'beef'),
  ('chicken', 'chicken'),
  ('tuna',    'fish'),
  ('eggs',    'egg'),
  ('noodles', 'egg')
) AS p(slug, protein) ON p.slug = i.slug;

-- ---------------------------------------------------------------------------
-- Style tags. Only ones the data supports: speed is a column, one-pot is a
-- property of the method, veg is already tagged. No "family favourite" or
-- "gut friendly" — those would be a language model's opinion dressed as data.
-- ---------------------------------------------------------------------------
INSERT INTO recipe_tag (recipe_id, tag)
SELECT r.id, 'sty:speedy' FROM recipe r WHERE r.minutes <= 15;

INSERT INTO recipe_tag (recipe_id, tag)
SELECT r.id, 'sty:onepot'
FROM recipe r
WHERE r.slug IN ('bolognese','chickcurry','chilli','dahl','friedrice','soup',
                 'stirfry','traybake','tunapasta');

COMMIT;
