-- 015 — dish-type photographs for the generated recipes
--
-- Twelve images covering 198 recipes by shape. A family image is a
-- photograph of the KIND of food, not of that exact plate — the
-- original 24 are the real thing, these are not, and image_is_family
-- marks the difference so the UI can be honest about it.
--
-- Written by services/solver/scripts/assign_family_images.py.

BEGIN;

ALTER TABLE recipe ADD COLUMN IF NOT EXISTS image_is_family boolean NOT NULL DEFAULT false;

UPDATE recipe SET image_url = '/recipes/family-beans-toast.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-beans-bread', 'g-beans-bread-frozveg', 'g-bread-carrot-cheese', 'g-bread-carrot-chicken', 'g-bread-carrot-chickpeas', 'g-bread-carrot-kidney', 'g-bread-carrot-lentils', 'g-bread-carrot-mince', 'g-bread-carrot-tuna', 'g-bread-chicken', 'g-bread-chicken-oil-peas-big', 'g-bread-chickpeas', 'g-bread-frozveg-lentils-oil-big', 'g-bread-frozveg-mince-big', 'g-bread-kidney', 'g-bread-lentils', 'g-bread-lentils-oil-peas-big', 'g-bread-mince', 'g-bread-mince-oil-big', 'g-bread-pb', 'g-bread-tuna');
UPDATE recipe SET image_url = '/recipes/family-bowl.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-beans-oil', 'g-beans-toms', 'g-carrot-chicken', 'g-carrot-lentils', 'g-carrot-mince', 'g-cheese-frozveg', 'g-cheese-oil', 'g-cheese-peas', 'g-cheese-toms', 'g-chickpeas-oil', 'g-frozveg-kidney-oil', 'g-kidney-oil-peas');
UPDATE recipe SET image_url = '/recipes/family-curry.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-beans-bread-curry', 'g-beans-curry-frozveg-pasta', 'g-beans-curry-noodles-peas', 'g-bread-cheese-curry', 'g-bread-curry-eggs', 'g-chicken-curry', 'g-chickpeas-curry-pasta-peas-big', 'g-chickpeas-curry-peas', 'g-curry-eggs-peas-rice', 'g-curry-kidney-noodles', 'g-curry-lentils', 'g-curry-lentils-rice-big', 'g-curry-mince');
UPDATE recipe SET image_url = '/recipes/family-eggs.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-banana-bread-eggs', 'g-banana-eggs', 'g-bread-carrot-eggs', 'g-eggs-toms');
UPDATE recipe SET image_url = '/recipes/family-jacket.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-beans-potato', 'g-carrot-chicken-potato', 'g-carrot-lentils-potato', 'g-carrot-mince-potato', 'g-carrot-mince-potato-big', 'g-carrot-potato-tuna', 'g-cheese-oil-peas-potato-big', 'g-cheese-peas-potato-stock', 'g-cheese-potato', 'g-chicken-oil-potato-big', 'g-chicken-peas-potato-big', 'g-chicken-potato', 'g-chickpeas-curry-peas-potato', 'g-chickpeas-peas-potato-stock', 'g-eggs-frozveg-potato', 'g-eggs-peas-potato', 'g-eggs-potato', 'g-frozveg-lentils-potato-big', 'g-kidney-peas-potato', 'g-lentils-oil-potato-big', 'g-lentils-potato', 'g-mince-potato', 'g-mince-potato-big', 'g-potato-tuna');
UPDATE recipe SET image_url = '/recipes/family-noodles.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-beans-noodles-peas', 'g-carrot-cheese-noodles-oil-big', 'g-carrot-chicken-noodles', 'g-carrot-chicken-noodles-big', 'g-carrot-eggs-noodles', 'g-carrot-kidney-noodles', 'g-carrot-lentils-noodles', 'g-carrot-lentils-noodles-big', 'g-carrot-mince-noodles', 'g-carrot-mince-noodles-big', 'g-carrot-noodles-tuna', 'g-cheese-frozveg-noodles-oil-big', 'g-cheese-noodles-peas', 'g-cheese-noodles-toms', 'g-chicken-frozveg-noodles-big', 'g-chicken-noodles', 'g-chickpeas-noodles-oil-peas-big', 'g-chickpeas-noodles-peas', 'g-chickpeas-noodles-toms', 'g-eggs-noodles', 'g-lentils-noodles', 'g-lentils-noodles-big', 'g-mince-noodles', 'g-mince-noodles-big', 'g-noodles-tuna');
UPDATE recipe SET image_url = '/recipes/family-pasta.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-beans-frozveg-oil-pasta-big', 'g-beans-oil-pasta-peas-big', 'g-beans-pasta-peas', 'g-carrot-chicken-pasta', 'g-carrot-chicken-pasta-big', 'g-carrot-chickpeas-oil-pasta-big', 'g-carrot-eggs-pasta', 'g-carrot-lentils-pasta', 'g-carrot-lentils-pasta-big', 'g-carrot-mince-pasta', 'g-carrot-mince-pasta-big', 'g-carrot-pasta-tuna', 'g-cheese-frozveg-pasta', 'g-cheese-frozveg-pasta-big', 'g-cheese-oil-pasta-big', 'g-cheese-pasta-peas', 'g-chicken-pasta', 'g-chicken-pasta-big', 'g-chickpeas-frozveg-pasta', 'g-chickpeas-pasta-peas', 'g-eggs-pasta', 'g-frozveg-kidney-oil-pasta-big', 'g-frozveg-kidney-pasta', 'g-kidney-oil-pasta-peas-big', 'g-kidney-pasta', 'g-lentils-pasta', 'g-lentils-pasta-big', 'g-mince-pasta', 'g-mince-pasta-big', 'g-pasta-tuna');
UPDATE recipe SET image_url = '/recipes/family-porridge.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-milk-oats-pb');
UPDATE recipe SET image_url = '/recipes/family-rice-meat.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-carrot-chicken-rice', 'g-carrot-mince-rice', 'g-carrot-mince-rice-big', 'g-carrot-rice-tuna', 'g-chicken-frozveg-rice-big', 'g-chicken-oil-rice-big', 'g-chicken-rice', 'g-mince-rice', 'g-mince-rice-big', 'g-rice-tuna');
UPDATE recipe SET image_url = '/recipes/family-rice-pulse.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-beans-rice-toms', 'g-carrot-cheese-oil-rice-big', 'g-carrot-lentils-rice', 'g-carrot-lentils-rice-big', 'g-cheese-frozveg-oil-rice-big', 'g-cheese-rice', 'g-eggs-peas-rice', 'g-eggs-rice', 'g-frozveg-lentils-rice');
UPDATE recipe SET image_url = '/recipes/family-wrap.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-banana-eggs-tortilla', 'g-banana-pb-tortilla', 'g-beans-carrot-tortilla-big', 'g-beans-frozveg-tortilla', 'g-beans-peas-tortilla', 'g-beans-tortilla', 'g-beans-tortilla-big', 'g-carrot-cheese-tortilla-big', 'g-carrot-chicken-tortilla', 'g-carrot-chicken-tortilla-big', 'g-carrot-chickpeas-tortilla-big', 'g-carrot-eggs-tortilla', 'g-carrot-kidney-tortilla-big', 'g-carrot-lentils-tortilla', 'g-carrot-lentils-tortilla-big', 'g-carrot-mince-tortilla', 'g-carrot-mince-tortilla-big', 'g-carrot-tortilla-tuna', 'g-cheese-frozveg-tortilla', 'g-cheese-peas-tortilla', 'g-cheese-tortilla', 'g-cheese-tortilla-big', 'g-chicken-tortilla', 'g-chicken-tortilla-big', 'g-chickpeas-frozveg-tortilla', 'g-chickpeas-peas-tortilla', 'g-chickpeas-tortilla-big', 'g-curry-eggs-tortilla', 'g-eggs-oil-peas-tortilla-big', 'g-eggs-tortilla', 'g-frozveg-kidney-tortilla', 'g-kidney-peas-tortilla', 'g-kidney-tortilla-big', 'g-lentils-tortilla', 'g-lentils-tortilla-big', 'g-mince-tortilla', 'g-mince-tortilla-big', 'g-pb-tortilla', 'g-tortilla-tuna');
UPDATE recipe SET image_url = '/recipes/family-yoghurt.webp',
                  image_is_family = true
  WHERE image_url IS NULL AND slug IN ('g-banana-bread-yoghurt', 'g-banana-tortilla-yoghurt', 'g-banana-yoghurt', 'g-bread-yoghurt', 'g-oats-yoghurt', 'g-potato-toms-yoghurt', 'g-potato-yoghurt', 'g-rice-toms-yoghurt', 'g-toms-yoghurt', 'g-tortilla-yoghurt');

COMMIT;
