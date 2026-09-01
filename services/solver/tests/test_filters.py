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


def test_gluten_free_empties_breakfast(cat):
    """A real gap in the catalogue, and the one filter that cannot be paid past."""
    r = report_for(cat, allergens=["gluten"])
    assert r.remaining_by_slot["breakfast"] == 0
    reason = filters.blocked_reason(r, filters.Diet.of(allergens=["gluten"]))
    assert reason is not None
    assert "breakfast" in reason
    assert "not a budget problem" in reason


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
    r = report_for(cat, styles=["onepot"])
    assert r.remaining_by_slot["breakfast"] == 7
    assert r.remaining_by_slot["snack"] == 5
    assert r.remaining_by_slot["main"] == 9


def test_blocked_reason_names_one_culprit(cat):
    """A reason listing every answer given is not actionable."""
    diet = filters.Diet.of(allergens=["gluten"], appliances=["hob"], proteins=["beef"])
    r = filters.apply(cat[0], cat[1], diet)
    reason = filters.blocked_reason(r, diet, cat[1])
    assert "gluten-free" in reason
    assert "no beef" not in reason and "appliances" not in reason
