"""
The checker is the only thing standing between generated prose and a plan the
shopper cannot actually cook, so it is tested adversarially rather than happily.
"""
import pytest

from app.method_check import check_method

DAHL = dict(recipe_slug="dahl", recipe_name="Red lentil dahl + rice",
            ingredient_slugs={"lentils", "rice", "onion", "toms", "curry", "oil", "stock"})


def run(summary, steps, **over):
    args = dict(DAHL); args.update(over)
    return check_method(args["recipe_slug"], args["recipe_name"],
                        args["ingredient_slugs"], summary, steps)


GOOD = ["Heat the oil in a large pan and soften the onion.",
        "Stir in the curry powder and cook until fragrant.",
        "Add the lentils, tomatoes and stock, then simmer for 20 minutes.",
        "Cook the rice and serve alongside."]


def test_clean_method_passes():
    problems, basics = run("A thick, gently spiced lentil dahl served with rice.", GOOD)
    assert problems == []


def test_times_and_temperatures_are_not_quantities():
    problems, _ = run("Simmered slowly.",
                      ["Roast at 200C for 40 minutes.",
                       "Simmer for 1 hour, stirring now and then.",
                       "Rest for 5 minutes before serving."])
    assert problems == []


@pytest.mark.parametrize("bad", [
    "Stir in 200g of the lentils.",
    "Add 1.5 litres of stock.",
    "Season with 2 tbsp of curry powder.",
    "Pour in 400 ml of water.",
])
def test_quantities_are_rejected(bad):
    problems, _ = run("A dahl.", [bad] + GOOD[:3])
    assert any("quantity" in p for p in problems), problems


@pytest.mark.parametrize("bad", [
    "Open a tin of tomatoes and pour it in.",
    "Drain two tins of the tomatoes.",
    "Use 3 stock cubes for a deeper flavour.",
])
def test_pack_counts_are_rejected(bad):
    problems, _ = run("A dahl.", [bad] + GOOD[:3])
    assert any("pack count" in p or "quantity" in p for p in problems), problems


def test_ingredient_not_in_the_recipe_is_rejected():
    problems, _ = run("A dahl.",
                      ["Heat the oil and soften the onion.",
                       "Brown the chicken in the same pan.",
                       "Add the lentils and tomatoes and simmer.",
                       "Serve with the rice."])
    assert any("chicken" in p for p in problems), problems


def test_dairy_sneaking_in_is_rejected():
    problems, _ = run("A dahl.",
                      ["Heat the oil and soften the onion.",
                       "Stir a spoonful of yoghurt through at the end.",
                       "Add the lentils and simmer.",
                       "Serve with the rice."])
    assert any("yoghurt" in p for p in problems), problems


def test_pantry_basics_are_allowed_but_reported():
    problems, basics = run("A dahl.",
                           ["Heat the oil and soften the onion.",
                            "Add the lentils, tomatoes and stock.",
                            "Season with salt and pepper to taste.",
                            "Boil the rice in salted water and serve."])
    assert problems == []
    assert "salt" in basics and "water" in basics


def test_verbs_that_look_like_ingredients_do_not_false_positive():
    """'toast' and 'wrap' are verbs; a checker that flags them is unusable."""
    problems, _ = run("A dahl.",
                      ["Toast the curry powder in the dry pan first.",
                       "Heat the oil and soften the onion.",
                       "Add the lentils, tomatoes and stock, then simmer.",
                       "Serve with the rice."])
    assert problems == []


def test_peanut_does_not_trip_the_pea_alias():
    problems, _ = run("A dahl.", GOOD, ingredient_slugs=DAHL["ingredient_slugs"] | {"pb"})
    assert problems == []


def test_structural_failures_are_caught():
    problems, _ = run("A dahl.", ["Too few.", "Only two steps."])
    assert any("steps" in p for p in problems)
    problems, _ = run("A dahl.", GOOD[:3] + ["no full stop here"])
    assert any("full stop" in p for p in problems)
