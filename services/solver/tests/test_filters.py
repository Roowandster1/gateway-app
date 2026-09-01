"""
Filters remove recipes; they never score them.

The interesting cases are the ones where a filter, not money, is the blocker.
Those must say so — SPEC §2's whole point is that an infeasible answer names the
constraint that actually bound, and "your budget is too low" for a catalogue
with no gluten-free breakfast names the wrong one.
"""
import pytest

from app import filters
from app.catalogue import load


@pytest.fixture(scope="module")
def cat():
    return load("aldi")[:2]


def report_for(cat, **kw):
    items, recipes = cat
    return filters.apply(items, recipes, filters.Diet.of(**kw))


def test_no_answers_removes_nothing(cat):
    r = report_for(cat)
    assert r.excluded == set()
    assert r.total_remaining == len(cat[1])


def test_empty_appliances_means_everything(cat):
    """A caller that never asks the question must not get a narrower plan."""
    assert report_for(cat, appliances=()).excluded == set()


def test_gluten_free_has_breakfasts(cat):
    """
    It did not, and that was the gap that prompted generating recipes: bread and
    oats were the only breakfast carbs anyone had written a recipe around, while
    23 of the 28 items are gluten-free the whole time. If this ever returns to
    zero the generator has regressed, not the catalogue.
    """
    r = report_for(cat, allergens=["gluten"])
    assert r.remaining_by_slot["breakfast"] > 0
    assert r.remaining_by_slot["main"] > 0
    assert filters.blocked_reason(r, filters.Diet.of(allergens=["gluten"]),
                                  cat[1]) is None


def test_peanut_free_leaves_breakfast(cat):
    r = report_for(cat, allergens=["peanut"])
    assert r.remaining_by_slot["breakfast"] > 0
    assert filters.blocked_reason(r, filters.Diet.of(allergens=["peanut"])) is None


def test_hob_only_drops_just_the_oven_recipes(cat):
    r = report_for(cat, appliances=["hob"])
    assert r.excluded == {"jacket", "traybake"}


def test_microwave_keeps_the_jacket(cat):
    """The alternative appliances are real, not padding: a microwave bakes a jacket."""
    r = report_for(cat, appliances=["hob", "microwave"])
    assert "jacket" not in r.excluded
    assert "traybake" in r.excluded


def test_no_cook_snacks_survive_an_empty_kitchen(cat):
    """A recipe needing no appliance is available to someone who owns none."""
    r = report_for(cat, appliances=["oven"])
    survivors = set(cat[1]) - r.excluded
    assert {"pbbanana", "oatpb", "yogbanana", "yogpb"} <= survivors


def test_avoiding_every_meat_leaves_the_vegetarian_catalogue(cat):
    r = report_for(cat, proteins=["beef", "chicken", "fish"])
    assert r.excluded == {"chilli", "stirfry", "traybake", "wrap", "tunapasta"}


def test_styles_are_any_not_all(cat):
    """Two styles must widen the choice, never narrow it."""
    one = report_for(cat, styles=["speedy"]).total_remaining
    two = report_for(cat, styles=["speedy", "onepot"]).total_remaining
    assert two > one


def test_allergen_tags_are_only_the_defensible_ones(cat):
    """No item may carry an allergen the catalogue cannot actually justify."""
    items = cat[0]
    seen = set().union(*(i.allergens for i in items.values()))
    assert seen <= set(filters.ALLERGENS)
    assert "soy" not in seen and "sesame" not in seen


def test_no_pork_anywhere(cat):
    """The catalogue has no pork, so no plan may ever claim to filter it."""
    assert "pork" not in filters.PROTEINS
    tags = set().union(*(r.tags for r in cat[1].values()))
    assert "pro:pork" not in tags


def test_a_style_never_touches_breakfast(cat):
    """
    Nobody asks for a one-pot breakfast. Applying a style to every slot wiped
    breakfast out entirely, which was technically correct and plainly not what
    anyone meant.
    """
    plain = report_for(cat)
    styled = report_for(cat, styles=["onepot"])
    assert styled.remaining_by_slot["breakfast"] == plain.remaining_by_slot["breakfast"]
    assert styled.remaining_by_slot["snack"] == plain.remaining_by_slot["snack"]
    assert styled.remaining_by_slot["main"] < plain.remaining_by_slot["main"]


def test_blocked_reason_names_one_culprit(cat):
    """
    A reason listing every answer given is not actionable.

    No realistic filter set empties a slot any more, which is the point of
    generating the recipes — so the mechanism is exercised against a
    hand-built report rather than by contriving a diet that still breaks.
    """
    recipes = cat[1]
    breakfasts = [s for s, r in recipes.items() if r.meal_slot == "breakfast"]
    report = filters.FilterReport(
        excluded=set(breakfasts),
        by_reason={"gluten-free": breakfasts, "no beef": ["chilli"]},
        remaining_by_slot={"breakfast": 0, "main": 5, "snack": 3},
        total_remaining=8,
    )
    reason = filters.blocked_reason(report, filters.Diet.of(), recipes)
    assert "breakfast" in reason
    assert "not a budget problem" in reason
    # Named by what emptied the slot, not by everything that was ticked.
    assert "gluten-free" in reason and "no beef" not in reason


def test_no_realistic_diet_runs_out_of_food(cat):
    """
    The catalogue should now absorb a stacked filter set. This is the whole
    return on generating recipes, so it is asserted rather than assumed.
    """
    for kw in (dict(allergens=["gluten"]),
               dict(allergens=["gluten", "dairy"]),
               dict(allergens=["dairy", "peanut"], proteins=["beef", "chicken"]),
               dict(styles=["veggie"], appliances=["hob"])):
        r = report_for(cat, **kw)
        assert filters.blocked_reason(r, filters.Diet.of(**kw), cat[1]) is None, kw
