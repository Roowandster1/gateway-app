"""
The SPEC §3 acceptance test: four consecutive weeks for one user, pantry carried
forward, at constant nutrition targets.

Week 2+ must cost measurably less than week 1. If it does not, the pantry logic
is wrong and we stop and diagnose rather than working around it.

Three things are checked, not one (PROGRESS.md open decisions 2 and 3):

  1. COST FALLS   — measured on TILL SPEND (sum of packs x price), never on the
                    objective value. The objective credits staple leftover at
                    CARRY_VALUE and then hands the same stock over free next
                    week; reading it would make week 2 cheaper by construction
                    and the test would pass on a broken model.
  2. COST PLATEAUS — it must converge on the marginal perishable cost, not fall
                    forever. Falling forever means stock is being invented.
  3. PANTRY CONSERVES — per item, per week, exactly:
                    packs x pack_size + from_pantry = used + carried + wasted
                    and  closing = opening - from_pantry + carried
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app import config                                    # noqa: E402
from app.catalogue import load                            # noqa: E402
from app.model import SolveParams, solve_plan             # noqa: E402

WEEKS = 4
TOL = 0.02


def main(store="aldi", budget=30.0):
    items, recipes, dropped = load(store)
    if dropped:
        print(f"catalogue gaps, recipes dropped: {dropped}")

    print(f"\n{'':<6}{'till spend':>11}{'carried':>10}{'wasted':>9}"
          f"{'cupboard':>10}{'protein/d':>11}{'kcal/d':>9}")
    print("-" * 66)

    pantry: dict[str, float] = {}
    spends, plans = [], []

    for week in range(1, WEEKS + 1):
        opening = dict(pantry)
        plan = solve_plan(items, recipes,
                          SolveParams(store=store, budget=budget, pantry=opening))
        check_conservation(week, plan, opening, items)

        print(f"wk {week:<3}{'£%.2f' % plan.spend:>11}"
              f"{'£%.2f' % plan.carry_over_value:>10}"
              f"{'£%.2f' % plan.wasted_value:>9}"
              f"{'£%.2f' % plan.cupboard_value:>10}"
              f"{plan.protein_per_day:>10.0f}g{plan.kcal_per_day:>9.0f}")

        spends.append(plan.spend)
        plans.append(plan)
        pantry = plan.closing_pantry

    print("-" * 66)
    report(spends, plans, store, budget)


def check_conservation(week, plan, opening, items):
    for line in plan.basket:
        lhs = line.packs * line.pack_size + line.qty_from_pantry
        rhs = line.qty_used + line.qty_carry_over + line.qty_wasted
        assert abs(lhs - rhs) < TOL, (
            f"week {week}: {line.item} does not balance: "
            f"{lhs:.2f} != {rhs:.2f}")

    for slug, closing_qty in plan.closing_pantry.items():
        line = next((b for b in plan.basket if b.item == slug), None)
        drawn = line.qty_from_pantry if line else 0.0
        carried = line.qty_carry_over if line else 0.0
        expected = opening.get(slug, 0.0) - drawn + carried
        assert abs(expected - closing_qty) < TOL, (
            f"week {week}: pantry for {slug} does not reconcile: "
            f"expected {expected:.2f}, got {closing_qty:.2f}")

    # Nothing may appear in the cupboard that cannot survive to next week.
    for slug in plan.closing_pantry:
        assert items[slug].carries(7, config.CARRY_BY_SHELF_LIFE), \
            f"week {week}: {slug} cannot carry but is in the cupboard"


def report(spends, plans, store, budget):
    w1, w2 = spends[0], spends[1]
    later = spends[1:]

    checks = [
        ("week 2 cheaper than week 1", w2 < w1 - TOL,
         f"£{w1:.2f} -> £{w2:.2f}  (saves £{w1 - w2:.2f}, {(w1 - w2) / w1:.0%})"),
        ("cost plateaus, does not fall forever",
         max(later) - min(later) < w1 - w2,
         f"weeks 2-4 spread £{max(later) - min(later):.2f} vs "
         f"week 1->2 drop £{w1 - w2:.2f}"),
        ("nutrition held constant",
         max(p.protein_per_day for p in plans) - min(p.protein_per_day for p in plans) < 100,
         f"protein/day {min(p.protein_per_day for p in plans):.0f}"
         f"-{max(p.protein_per_day for p in plans):.0f}g"),
        ("every week within budget", all(s <= budget + TOL for s in spends),
         f"max £{max(spends):.2f} of £{budget:.2f}"),
        ("pantry conserved every week", True, "checked per item, per week"),
    ]
    for name, ok, detail in checks:
        print(f"  {'PASS' if ok else 'FAIL'}  {name:<38} {detail}")

    total = sum(spends)
    naive = w1 * len(spends)
    print(f"\n  4 weeks at {store}: £{total:.2f}. "
          f"Without a cupboard: £{naive:.2f}. Saved £{naive - total:.2f}.")
    if not all(c[1] for c in checks):
        sys.exit(1)


if __name__ == "__main__":
    main(*(sys.argv[1:] or []))
