-- Point recipe photography at files this repo owns.
--
-- Migration 010 stored Higgsfield CDN URLs, because the sandbox that
-- generated the images could not download them. The owner supplied the files
-- instead, so they now live in apps/web/public/recipes and the app serves
-- them itself. No expiring links, no third-party dependency, and the images
-- can be embedded in the static demo — which its CSP would never allow for
-- external URLs.

BEGIN;

UPDATE recipe SET image_url = '/recipes/beanstoast.webp' WHERE slug = 'beanstoast';
UPDATE recipe SET image_url = '/recipes/boiledeggs.webp' WHERE slug = 'boiledeggs';
UPDATE recipe SET image_url = '/recipes/bolognese.webp' WHERE slug = 'bolognese';
UPDATE recipe SET image_url = '/recipes/cheesetoast.webp' WHERE slug = 'cheesetoast';
UPDATE recipe SET image_url = '/recipes/chickcurry.webp' WHERE slug = 'chickcurry';
UPDATE recipe SET image_url = '/recipes/chilli.webp' WHERE slug = 'chilli';
UPDATE recipe SET image_url = '/recipes/dahl.webp' WHERE slug = 'dahl';
UPDATE recipe SET image_url = '/recipes/eggstoast.webp' WHERE slug = 'eggstoast';
UPDATE recipe SET image_url = '/recipes/eggwrap.webp' WHERE slug = 'eggwrap';
UPDATE recipe SET image_url = '/recipes/friedrice.webp' WHERE slug = 'friedrice';
UPDATE recipe SET image_url = '/recipes/jacket.webp' WHERE slug = 'jacket';
UPDATE recipe SET image_url = '/recipes/oatpancake.webp' WHERE slug = 'oatpancake';
UPDATE recipe SET image_url = '/recipes/oatpb.webp' WHERE slug = 'oatpb';
UPDATE recipe SET image_url = '/recipes/omelette.webp' WHERE slug = 'omelette';
UPDATE recipe SET image_url = '/recipes/pbbanana.webp' WHERE slug = 'pbbanana';
UPDATE recipe SET image_url = '/recipes/pbtoast.webp' WHERE slug = 'pbtoast';
UPDATE recipe SET image_url = '/recipes/porridge.webp' WHERE slug = 'porridge';
UPDATE recipe SET image_url = '/recipes/soup.webp' WHERE slug = 'soup';
UPDATE recipe SET image_url = '/recipes/stirfry.webp' WHERE slug = 'stirfry';
UPDATE recipe SET image_url = '/recipes/traybake.webp' WHERE slug = 'traybake';
UPDATE recipe SET image_url = '/recipes/tunapasta.webp' WHERE slug = 'tunapasta';
UPDATE recipe SET image_url = '/recipes/wrap.webp' WHERE slug = 'wrap';
UPDATE recipe SET image_url = '/recipes/yogbanana.webp' WHERE slug = 'yogbanana';
UPDATE recipe SET image_url = '/recipes/yogpb.webp' WHERE slug = 'yogpb';

-- Every recipe must end up with a local path; a CDN leftover means a slug drifted.
DO $$
DECLARE stragglers int;
BEGIN
  SELECT count(*) INTO stragglers
  FROM recipe WHERE image_url IS NULL OR image_url NOT LIKE '/recipes/%';
  IF stragglers > 0 THEN
    RAISE EXCEPTION '% recipe(s) still lack a local image path', stragglers;
  END IF;
END $$;

COMMIT;
