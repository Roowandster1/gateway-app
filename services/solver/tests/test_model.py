"""
The plan must be buyable at the till. These tests check the arithmetic by hand
rather than trusting the solver's own reported totals — KICKOFF's standing
instruction for when a plan looks too good.
"""
import pytest

from app import config
from app.model import Infeasible, SolveParams, solve_plan


@pytest.fixture
def plan(aldi):
    items, recipes = aldi
    return solve_plan(items, recipes, SolveParams(store="aldi", budget=30.0))


def test_spend_equals_packs_times_price(plan, aldi):
    """Multiply packs by unit price; it must match the reported total."""
    items, _ = aldi
    by_hand = sum(line.packs * items[line.item].price for line in plan.basket)
    assert by_hand == pytest.approx(plan.spend, abs=0.01)
    assert plan.spend <= plan.budget


def test_every_ingredient_demand_is_covered(plan, aldi):
    """No recipe may call for more of an item than the packs bought contain."""
    items, recipes = aldi
    demand = {}
    for meal in plan.meals:
        for slug, qty in recipes[meal["recipe"]].ingredients.items():
            demand[slug] = demand.get(slug, 0) + qty * meal["servings"]

    supplied = {b.item: b.packs * items[b.item].pack_size + b.qty_from_pantry
                for b in plan.basket}
    for slug, needed in demand.items():
        assert supplied.get(slug, 0) + 1e-6 >= needed, (
            f"{slug}: plan cooks {needed}, basket supplies {supplied.get(slug, 0)}")


def test_basket_lines_conserve(plan):
    """packs*size + from_pantry == used + carried + wasted, per line."""
    for b in plan.basket:
        lhs = b.packs * b.pack_size + b.qty_from_pantry
        rhs = b.qty_used + b.qty_carry_over + b.qty_wasted
        assert lhs == pytest.approx(rhs, abs=0.02), f"{b.item} does not balance"


def test_nutrition_floors_are_met(plan):
    assert plan.protein_per_day >= config.DEFAULT_MIN_PROTEIN_PER_DAY
    lo, hi = config.DEFAULT_KCAL_BAND
    assert lo <= plan.kcal_per_day <= hi


def test_nothing_perishable_enters_the_cupboard(plan, aldi):
    items, _ = aldi
    for slug in plan.closing_pantry:
        assert items[slug].carries(7, config.CARRY_BY_SHELF_LIFE)


def test_pantry_is_free_and_makes_week_two_cheaper(aldi):
    items, recipes = aldi
    wk1 = solve_plan(items, recipes, SolveParams(store="aldi", budget=30.0))
    wk2 = solve_plan(items, recipes,
                     SolveParams(store="aldi", budget=30.0, pantry=wk1.closing_pantry))
    assert wk2.spend < wk1.spend
    assert wk2.protein_per_day >= config.DEFAULT_MIN_PROTEIN_PER_DAY
    # stock drawn from the cupboard is not paid for again
    for b in wk2.basket:
        assert b.qty_from_pantry <= wk1.closing_pantry.get(b.item, 0) + 1e-6


def test_waste_penalty_actually_changes_the_plan(aldi, monkeypatch):
    """
    Regression test. The leftover variable for penalised items must be pinned to
    bought - used; bounded only from above, the objective drives it to zero and
    WASTE_PENALTY becomes decorative. That bug reported waste correctly while
    optimising as though it did not exist, so only a sensitivity check catches it.
    """
    items, recipes = aldi
    wk1 = solve_plan(items, recipes, SolveParams(store="aldi", budget=30.0))
    params = SolveParams(store="aldi", budget=30.0, pantry=wk1.closing_pantry)

    monkeypatch.setattr(config, "WASTE_PENALTY", 0.0)
    lax = solve_plan(items, recipes, params)
    monkeypatch.setattr(config, "WASTE_PENALTY", 100.0)
    strict = solve_plan(items, recipes, params)

    assert strict.wasted_value < lax.wasted_value, (
        "WASTE_PENALTY has no effect — the leftover variable is not pinned")


def test_carry_rule_respects_shelf_life(aldi):
    """Cheese outlives a 7-day plan and must not be booked as waste."""
    items, _ = aldi
    assert items["cheese"].carries(7, by_shelf_life=True)
    assert not items["cheese"].carries(7, by_shelf_life=False)
    assert not items["chicken"].carries(7, by_shelf_life=True)   # 3-day life
    assert items["rice"].carries(7, by_shelf_life=True)          # staple


def test_tesco_is_dearer_than_aldi(aldi, tesco):
    """
    Compared on the `cheapest` objective, not `protein`. Under `protein` both
    stores spend up to whatever the budget still buys, so the spends land within
    pennies of each other and the difference shows up as protein per pound
    instead. Comparing spend there measures nothing.
    """
    a_items, a_recipes = aldi
    t_items, t_recipes = tesco
    a = solve_plan(a_items, a_recipes,
                   SolveParams(store="aldi", budget=30.0, objective="cheapest"))
    t = solve_plan(t_items, t_recipes,
                   SolveParams(store="tesco", budget=30.0, objective="cheapest"))
    assert a.protein_per_day == pytest.approx(t.protein_per_day, abs=5)
    assert t.spend > a.spend, "Aldi should undercut Tesco at equal nutrition"


# --- infeasibility as a feature (SPEC §2) ----------------------------------

def test_tesco_at_25_is_infeasible_and_reports_a_floor(tesco):
    """KICKOFF §3, the case that must work."""
    items, recipes = tesco
    with pytest.raises(Infeasible) as exc:
        solve_plan(items, recipes, SolveParams(store="tesco", budget=25.0))
    e = exc.value
    assert e.binding == "budget"
    assert e.min_feasible_budget is not None
    assert e.min_feasible_budget > 25.0
    assert "£" in e.suggestion


def test_aldi_at_25_is_feasible(aldi):
    """KICKOFF §3: the same targets must work at Aldi, around £24.94."""
    items, recipes = aldi
    plan = solve_plan(items, recipes, SolveParams(store="aldi", budget=25.0))
    assert plan.spend == pytest.approx(24.94, abs=0.5)


def test_binding_constraint_is_identified_not_guessed(aldi):
    """Each impossible target must name itself, not just say 'infeasible'."""
    items, recipes = aldi
    cases = [
        (dict(budget=5.0), "budget"),
        (dict(budget=30.0, min_protein_per_day=250.0), "min_protein_per_day"),
        (dict(budget=30.0, max_cook_minutes_per_day=8.0), "max_cook_minutes_per_day"),
        (dict(budget=60.0, days=14), "breakfast_recipe_supply"),
    ]
    for kwargs, expected in cases:
        with pytest.raises(Infeasible) as exc:
            solve_plan(items, recipes, SolveParams(store="aldi", **kwargs))
        assert exc.value.binding == expected, f"{kwargs} named {exc.value.binding}"
        assert exc.value.suggestion, "an infeasible answer must explain itself"


def test_floor_is_actually_feasible(tesco):
    """The reported cheapest week must itself solve — otherwise it is a guess."""
    items, recipes = tesco
    with pytest.raises(Infeasible) as exc:
        solve_plan(items, recipes, SolveParams(store="tesco", budget=25.0))
    floor = exc.value.min_feasible_budget
    plan = solve_plan(items, recipes,
                      SolveParams(store="tesco", budget=floor, objective="cheapest"))
    assert plan.spend <= floor + 0.01


def test_no_budget_number_when_money_is_not_the_problem(aldi):
    """A protein floor of 250g/day is not a budget problem; do not invent a price."""
    items, recipes = aldi
    with pytest.raises(Infeasible) as exc:
        solve_plan(items, recipes,
                   SolveParams(store="aldi", budget=30.0, min_protein_per_day=250.0))
    assert exc.value.min_feasible_budget is None
