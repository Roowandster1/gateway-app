-- 014 — cooking steps for the generated recipes
--
-- Written by services/solver/scripts/template_methods.py: composed from
-- each recipe's own ingredient list, with no model involved, and every
-- one validated by app.method_check exactly as the model's copy is.
-- Plainer than the hand-written 24; a plan you can cook beats a plan you
-- cannot. Re-runnable — it only touches recipes with no method.

BEGIN;

UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Beat the eggs and scramble them softly in a hot dry pan.
3. Slice the banana over the top.
4. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-banana-bread-eggs' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Spoon the yoghurt over at the end, off the heat.
3. Slice the banana over the top.
4. Season, and serve. About 4 minutes start to finish.'
  WHERE slug = 'g-banana-bread-yoghurt' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Beat the eggs and scramble them softly in a hot dry pan.
2. Slice the banana over the top.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-banana-eggs' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Beat the eggs and scramble them softly in a hot dry pan.
3. Slice the banana over the top.
4. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-banana-eggs-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Swirl through the peanut butter.
3. Slice the banana over the top.
4. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-banana-pb-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Spoon the yoghurt over at the end, off the heat.
3. Slice the banana over the top.
4. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-banana-tortilla-yoghurt' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — banana and yoghurt in a bowl.

1. Put the banana in a bowl.
2. Add the yoghurt and stir.
3. Eat.'
  WHERE slug = 'g-banana-yoghurt' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Toast the bread.
2. Add the beans with a splash of water and simmer until it thickens.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-beans-bread' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Toast the bread.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Add the beans with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-bread-curry' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Toast the bread.
2. Add the beans with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-bread-frozveg' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the beans with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-carrot-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Add the beans with a splash of water and simmer until it thickens.
4. Throw in the mixed veg near the end so they keep their colour.
5. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-curry-frozveg-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Add the beans with a splash of water and simmer until it thickens.
4. Throw in the peas near the end so they keep their colour.
5. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-curry-noodles-peas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the beans with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-frozveg-oil-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the beans with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-frozveg-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Add the beans with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-noodles-peas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — beans and oil in a bowl.

1. Put the beans in a bowl.
2. Add the oil and stir.
3. Eat.'
  WHERE slug = 'g-beans-oil' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the beans with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-oil-pasta-peas-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the beans with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-pasta-peas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the beans with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-peas-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Add the beans with a splash of water and simmer until it thickens.
3. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-beans-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Pour in the tomatoes and bring it to a simmer.
3. Add the beans and simmer until it thickens.
4. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-beans-rice-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — beans and tomatoes in a bowl.

1. Put the beans in a bowl.
2. Add the tomatoes and stir.
3. Eat.'
  WHERE slug = 'g-beans-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the beans with a splash of water and simmer until it thickens.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-beans-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain bean dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the beans with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-beans-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Stir in the carrot and give it a few minutes'' head start.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-carrot-cheese' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Toast the bread.
2. Cook the chicken in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-bread-carrot-chicken' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Toast the bread.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the chickpeas with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-carrot-chickpeas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Stir in the carrot and give it a few minutes'' head start.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-carrot-eggs' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Toast the bread.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the kidney beans with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-carrot-kidney' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Toast the bread.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-carrot-lentils' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Toast the bread.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-bread-carrot-mince' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Toast the bread.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the tuna with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-carrot-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-cheese-curry' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Toast the bread.
2. Cook the chicken in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-bread-chicken' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Toast the bread.
2. Heat the oil in a pan over a medium heat.
3. Add the chicken and brown it all over.
4. Throw in the peas near the end so they keep their colour.
5. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-bread-chicken-oil-peas-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Toast the bread.
2. Add the chickpeas with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-chickpeas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-curry-eggs' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Toast the bread.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-frozveg-lentils-oil-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Toast the bread.
2. Cook the beef mince in a hot pan until browned all over.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-bread-frozveg-mince-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Toast the bread.
2. Add the kidney beans with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-kidney' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Toast the bread.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-lentils' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Toast the bread.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-lentils-oil-peas-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Toast the bread.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-bread-mince' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Toast the bread.
2. Heat the oil in a pan over a medium heat.
3. Add the beef mince and brown it all over.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-bread-mince-oil-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Swirl through the peanut butter.
3. Season, and serve. About 4 minutes start to finish.'
  WHERE slug = 'g-bread-pb' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Toast the bread.
2. Add the tuna with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-bread-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Toast the bread.
2. Spoon the yoghurt over at the end, off the heat.
3. Season, and serve. About 4 minutes start to finish.'
  WHERE slug = 'g-bread-yoghurt' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-cheese-noodles-oil-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the rice until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-cheese-oil-rice-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Stir in the carrot and give it a few minutes'' head start.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-cheese-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Cook the chicken in a hot pan until browned all over.
2. Stir in the carrot and give it a few minutes'' head start.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-chicken' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-chicken-noodles' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-chicken-noodles-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-chicken-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-chicken-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Cook the chicken in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-carrot-chicken-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-chicken-rice' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Cook the chicken in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-chicken-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Cook the chicken in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-chicken-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the chickpeas with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-chickpeas-oil-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the chickpeas with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-chickpeas-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-eggs-noodles' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-eggs-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Stir in the carrot and give it a few minutes'' head start.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-eggs-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the kidney beans with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-kidney-noodles' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the kidney beans with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-kidney-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — carrot and lentils in a bowl.

1. Put the carrot in a bowl.
2. Add the lentils and stir.
3. Eat.'
  WHERE slug = 'g-carrot-lentils' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-lentils-noodles' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-lentils-noodles-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-lentils-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-lentils-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-carrot-lentils-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-lentils-rice' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-lentils-rice-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-lentils-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-lentils-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Cook the beef mince in a hot pan until browned all over.
2. Stir in the carrot and give it a few minutes'' head start.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-mince' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-mince-noodles' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-mince-noodles-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-mince-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-mince-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-carrot-mince-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-carrot-mince-potato-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-mince-rice' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-mince-rice-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-mince-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Cook the beef mince in a hot pan until browned all over.
3. Stir in the carrot and give it a few minutes'' head start.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-carrot-mince-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the tuna with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-noodles-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the tuna with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-pasta-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the tuna with a splash of water and simmer until it thickens.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-carrot-potato-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the tuna with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-rice-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Stir in the carrot and give it a few minutes'' head start.
3. Add the tuna with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-carrot-tortilla-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — cheese and mixed veg in a bowl.

1. Put the cheese in a bowl.
2. Add the mixed veg and stir.
3. Eat.'
  WHERE slug = 'g-cheese-frozveg' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Throw in the mixed veg near the end so they keep their colour.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-frozveg-noodles-oil-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the rice until just tender, then drain.
2. Throw in the mixed veg near the end so they keep their colour.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-frozveg-oil-rice-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Throw in the mixed veg near the end so they keep their colour.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-frozveg-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Throw in the mixed veg near the end so they keep their colour.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-frozveg-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Throw in the mixed veg near the end so they keep their colour.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-frozveg-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Throw in the peas near the end so they keep their colour.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-noodles-peas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Pour in the tomatoes and bring it to a simmer.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-noodles-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — cheese and oil in a bowl.

1. Put the cheese in a bowl.
2. Add the oil and stir.
3. Eat.'
  WHERE slug = 'g-cheese-oil' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Grate the cheese over while everything is still hot.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-oil-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Throw in the peas near the end so they keep their colour.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-cheese-oil-peas-potato-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Throw in the peas near the end so they keep their colour.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-pasta-peas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — cheese and peas in a bowl.

1. Put the cheese in a bowl.
2. Add the peas and stir.
3. Eat.'
  WHERE slug = 'g-cheese-peas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Crumble in the stock cube with a splash of water.
3. Throw in the peas near the end so they keep their colour.
4. Grate the cheese over while everything is still hot.
5. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-cheese-peas-potato-stock' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Throw in the peas near the end so they keep their colour.
3. Grate the cheese over while everything is still hot.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-peas-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Grate the cheese over while everything is still hot.
3. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-cheese-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the rice until just tender, then drain.
2. Grate the cheese over while everything is still hot.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-cheese-rice' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — cheese and tomatoes in a bowl.

1. Put the cheese in a bowl.
2. Add the tomatoes and stir.
3. Eat.'
  WHERE slug = 'g-cheese-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Grate the cheese over while everything is still hot.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-cheese-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Grate the cheese over while everything is still hot.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-cheese-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Cook the chicken in a hot pan until browned all over.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-chicken-curry' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-chicken-frozveg-noodles-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-chicken-frozveg-rice-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-chicken-noodles' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Heat the oil in a pan over a medium heat.
3. Add the chicken and brown it all over.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-chicken-oil-potato-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Heat the oil in a pan over a medium heat.
3. Add the chicken and brown it all over.
4. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-chicken-oil-rice-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-chicken-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-chicken-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Cook the chicken in a hot pan until browned all over.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-chicken-peas-potato-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Cook the chicken in a hot pan until browned all over.
3. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-chicken-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Cook the chicken in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-chicken-rice' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Cook the chicken in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-chicken-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chicken dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Cook the chicken in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-chicken-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Add the chickpeas with a splash of water and simmer until it thickens.
4. Throw in the peas near the end so they keep their colour.
5. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-chickpeas-curry-pasta-peas-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — chickpeas and curry powder in a bowl.

1. Put the chickpeas in a bowl.
2. Add the curry powder and peas and stir.
3. Eat.'
  WHERE slug = 'g-chickpeas-curry-peas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Add the chickpeas with a splash of water and simmer until it thickens.
4. Throw in the peas near the end so they keep their colour.
5. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-chickpeas-curry-peas-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the chickpeas with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-chickpeas-frozveg-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the chickpeas with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-chickpeas-frozveg-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Add the chickpeas with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-chickpeas-noodles-oil-peas-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Add the chickpeas with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-chickpeas-noodles-peas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Pour in the tomatoes and bring it to a simmer.
3. Add the chickpeas and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-chickpeas-noodles-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — chickpeas and oil in a bowl.

1. Put the chickpeas in a bowl.
2. Add the oil and stir.
3. Eat.'
  WHERE slug = 'g-chickpeas-oil' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the chickpeas with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-chickpeas-pasta-peas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Crumble in the stock cube with a splash of water.
3. Add the chickpeas and simmer until it thickens.
4. Throw in the peas near the end so they keep their colour.
5. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-chickpeas-peas-potato-stock' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the chickpeas with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-chickpeas-peas-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain chickpea dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the chickpeas with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-chickpeas-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the rice until just tender, then drain.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Throw in the peas near the end so they keep their colour.
4. Beat the eggs and scramble them softly in a hot dry pan.
5. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-curry-eggs-peas-rice' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-curry-eggs-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Add the kidney beans with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-curry-kidney-noodles' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — curry powder and lentils in a bowl.

1. Put the curry powder in a bowl.
2. Add the lentils and stir.
3. Eat.'
  WHERE slug = 'g-curry-lentils' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Add the lentils with a splash of water and simmer until it thickens.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-curry-lentils-rice-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Cook the beef mince in a hot pan until browned all over.
2. Stir in the curry powder and let it toast until it smells of itself.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-curry-mince' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Throw in the mixed veg near the end so they keep their colour.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-eggs-frozveg-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Beat the eggs and scramble them softly in a hot dry pan.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-eggs-noodles' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Heat the oil in a pan over a medium heat.
3. Throw in the peas near the end so they keep their colour.
4. Beat the eggs and scramble them softly in the pan.
5. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-eggs-oil-peas-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Beat the eggs and scramble them softly in a hot dry pan.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-eggs-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Throw in the peas near the end so they keep their colour.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-eggs-peas-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the rice until just tender, then drain.
2. Throw in the peas near the end so they keep their colour.
3. Beat the eggs and scramble them softly in a hot dry pan.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-eggs-peas-rice' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Beat the eggs and scramble them softly in a hot dry pan.
3. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-eggs-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the rice until just tender, then drain.
2. Beat the eggs and scramble them softly in a hot dry pan.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-eggs-rice' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Pour in the tomatoes and bring it to a simmer.
2. Beat the eggs and scramble them softly in a hot dry pan.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-eggs-toms' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Beat the eggs and scramble them softly in a hot dry pan.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-eggs-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — mixed veg and kidney beans in a bowl.

1. Put the mixed veg in a bowl.
2. Add the kidney beans and oil and stir.
3. Eat.'
  WHERE slug = 'g-frozveg-kidney-oil' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the kidney beans with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-frozveg-kidney-oil-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the kidney beans with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-frozveg-kidney-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the kidney beans with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-frozveg-kidney-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-frozveg-lentils-potato-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Throw in the mixed veg near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-frozveg-lentils-rice' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the kidney beans with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-kidney-oil-pasta-peas-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — kidney beans and oil in a bowl.

1. Put the kidney beans in a bowl.
2. Add the oil and peas and stir.
3. Eat.'
  WHERE slug = 'g-kidney-oil-peas' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the kidney beans with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-kidney-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Add the kidney beans with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-kidney-peas-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the kidney beans with a splash of water and simmer until it thickens.
3. Throw in the peas near the end so they keep their colour.
4. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-kidney-peas-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain kidney bean dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the kidney beans with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-kidney-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-lentils-noodles' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-lentils-noodles-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-lentils-oil-potato-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-lentils-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-lentils-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-lentils-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-lentils-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain lentil dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the lentils with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-lentils-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Simmer the oats with the milk, stirring, until thick.
2. Swirl through the peanut butter.
3. Season, and serve. About 4 minutes start to finish.'
  WHERE slug = 'g-milk-oats-pb' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-mince-noodles' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-mince-noodles-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-mince-pasta' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-mince-pasta-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-mince-potato' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-mince-potato-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-mince-rice' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-mince-rice-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-mince-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain beef dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Cook the beef mince in a hot pan until browned all over.
3. Season, and serve. About 25 minutes start to finish.'
  WHERE slug = 'g-mince-tortilla-big' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Boil the noodles until just tender, then drain.
2. Add the tuna with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-noodles-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Simmer the oats with water, stirring, until thick.
2. Spoon the yoghurt over at the end, off the heat.
3. Season, and serve. About 4 minutes start to finish.'
  WHERE slug = 'g-oats-yoghurt' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Boil the pasta until just tender, then drain.
2. Add the tuna with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-pasta-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Swirl through the peanut butter.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-pb-tortilla' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Pour in the tomatoes and bring it to a simmer.
3. Spoon the yoghurt over at the end, off the heat.
4. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-potato-toms-yoghurt' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Add the tuna with a splash of water and simmer until it thickens.
3. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-potato-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Bake the potatoes until the skins crisp and the middles give.
2. Spoon the yoghurt over at the end, off the heat.
3. Season, and serve. About 45 minutes start to finish.'
  WHERE slug = 'g-potato-yoghurt' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Boil the rice until just tender, then drain.
2. Pour in the tomatoes and bring it to a simmer.
3. Spoon the yoghurt over at the end, off the heat.
4. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-rice-toms-yoghurt' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Boil the rice until just tender, then drain.
2. Add the tuna with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-rice-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'No cooking — tomatoes and yoghurt in a bowl.

1. Put the tomatoes in a bowl.
2. Add the yoghurt and stir.
3. Eat.'
  WHERE slug = 'g-toms-yoghurt' AND method_md IS NULL;
UPDATE recipe SET method_md = 'A plain tuna dish, cooked in one go.

1. Warm the wraps in a dry pan.
2. Add the tuna with a splash of water and simmer until it thickens.
3. Season, and serve. About 18 minutes start to finish.'
  WHERE slug = 'g-tortilla-tuna' AND method_md IS NULL;
UPDATE recipe SET method_md = 'Plain, quick, and cooked in one go.

1. Warm the wraps in a dry pan.
2. Spoon the yoghurt over at the end, off the heat.
3. Season, and serve. About 8 minutes start to finish.'
  WHERE slug = 'g-tortilla-yoghurt' AND method_md IS NULL;

COMMIT;
