-- GENERATED from db/seed/recipe_images.py — do not edit by hand.
-- Recipe photography. Decoration only: nothing here feeds the optimiser,
-- and a missing image degrades to no image (CLAUDE.md rule 1).

BEGIN;

ALTER TABLE recipe ADD COLUMN IF NOT EXISTS image_url text;

COMMENT ON COLUMN recipe.image_url IS
  'Generated dish photography. Decorative, never part of a plan''s data.';

UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232034_f8df27e1-2623-49c7-a87f-f34e0be5f95e.png' WHERE slug = 'beanstoast';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232254_1659a328-963e-4f63-a3f9-388f13a92b2f.png' WHERE slug = 'boiledeggs';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232102_3a4c3d99-dc78-4d33-85ec-1e59d711f01b.png' WHERE slug = 'bolognese';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232254_b1d9af41-db93-48c8-92f2-16ca96fe79ef.png' WHERE slug = 'cheesetoast';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232102_1e3d5e8d-0f15-4724-8fbd-6254fb0a62ef.png' WHERE slug = 'chickcurry';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232004_b7adc310-51e4-42af-84ea-8fc0a5db5b20.png' WHERE slug = 'chilli';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232004_d8a092a4-18d0-434b-ac9f-96e8d74838cc.png' WHERE slug = 'dahl';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232004_29e7c5d3-3abb-4b9d-b22a-384641a63d68.png' WHERE slug = 'eggstoast';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232004_8558a7a9-3272-455a-858f-cd35b219a003.png' WHERE slug = 'eggwrap';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232225_e2ff0299-6a0c-45f7-ba9b-7d4705523c0e.png' WHERE slug = 'friedrice';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232225_f8a68e92-958e-4250-afde-2c6813b028e8.png' WHERE slug = 'jacket';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232034_edb7e6ca-f922-41c2-b2be-be9a763f22a9.png' WHERE slug = 'oatpancake';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232321_3a324697-ff92-413d-b3ef-7779b7390b02.png' WHERE slug = 'oatpb';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232130_b384b379-8760-4e7d-b4a7-52a5d2dc2b50.png' WHERE slug = 'omelette';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232321_3daafaaf-6109-4b37-803c-9d23871c548a.png' WHERE slug = 'pbbanana';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232102_3749768b-de9c-4b52-b1e8-a2d39604f5e1.png' WHERE slug = 'pbtoast';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232004_176c353a-2e6e-4e75-9330-88c8c943e4cc.png' WHERE slug = 'porridge';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232131_dd2d68ca-63b3-4050-b713-f192a7e49a33.png' WHERE slug = 'soup';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232225_214b905c-7583-4ac3-b9e5-428d3a5c0870.png' WHERE slug = 'stirfry';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232225_b6410f6c-c073-4fc5-bc41-dcc67bac0097.png' WHERE slug = 'traybake';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232255_c30b316d-ffaf-4a79-9d86-9aea26e64995.png' WHERE slug = 'tunapasta';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232254_3b4b2d76-8b3a-49c3-b2d6-0e18189c2aad.png' WHERE slug = 'wrap';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232321_995f7fe1-19ab-4695-a192-fd6f61bdb3fb.png' WHERE slug = 'yogbanana';
UPDATE recipe SET image_url = 'https://d8j0ntlcm91z4.cloudfront.net/user_3IhVUYdoKadNMtnzdIMahdlsd10/hf_20260831_232102_587a51fc-99cc-4f62-9bc6-1a2daf1ab8b5.png' WHERE slug = 'yogpb';

COMMIT;
