-- 017 — cooking steps for the four light meals added by 016
--
-- Written by services/solver/scripts/template_methods.py: composed from
-- each recipe's own ingredient list, with no model involved, and every
-- one validated by app.method_check exactly as the model's copy is.
-- Plainer than the hand-written 24; a plan you can cook beats a plan you
-- cannot. Re-runnable — it only touches recipes with no method.

BEGIN;

UPDATE recipe SET method_md = 'No cooking — banana and peanut butter in a bowl.

1. Put the banana in a bowl.
2. Add the peanut butter and yoghurt and stir.
3. Eat.'
  WHERE slug = 'g-banana-pb-yoghurt' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Toast the bread.
2. Pour in the tomatoes and bring it to a simmer.
3. Add the beans and simmer until it thickens.
4. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-beans-bread-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Pour in the tomatoes and bring it to a simmer.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-bread-cheese-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — peanut butter and yoghurt in a bowl.

1. Put the peanut butter in a bowl.
2. Add the yoghurt and stir.
3. Eat.'
  WHERE slug = 'g-pb-yoghurt' AND method_md IS NULL;

COMMIT;
