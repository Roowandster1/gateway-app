-- 019 — cooking steps for the seven light meals added by 018
--
-- Written by services/solver/scripts/template_methods.py: composed from
-- each recipe's own ingredient list, with no model involved, and every
-- one validated by app.method_check exactly as the model's copy is.
-- Plainer than the hand-written 24; a plan you can cook beats a plan you
-- cannot. Re-runnable — it only touches recipes with no method.

BEGIN;

UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Slice the banana over the top.
3. Season, and serve. About 4 minutes start to finish.'
  WHERE slug = 'g-banana-bread' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Slice the banana over the top.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-banana-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Pour in the tomatoes and bring it to a simmer.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-bread-eggs-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Pour in the tomatoes and bring it to a simmer.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-bread-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Beat the eggs and scramble them softly in a hot dry pan.
2. Grate the cheese over while everything is still hot.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-cheese-eggs' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Pour in the tomatoes and bring it to a simmer.
2. Beat the eggs and scramble them softly in a hot dry pan.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-cheese-eggs-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Pour in the tomatoes and bring it to a simmer.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-eggs-potato-toms' AND method_md IS NULL;

COMMIT;
