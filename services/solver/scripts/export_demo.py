"""
Solve the whole demo grid with the real optimiser and write it to JSON.

The demo front end is static, so it cannot call the solver. Rather than mock
numbers — which would demo nothing — every combination is solved here in
advance and the genuine output is embedded.

Two floors are exported per combination, not one. A single "cheapest week"
figure is misleading: on an empty cupboard a large share of the first shop is
stock you still own afterwards, so quoting it as the weekly cost overstates what
the food costs by around 40%. `floor_first` is the first shop; `floor_ongoing`
is the same targets once the cupboard is stocked.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.catalogue import load                                  # noqa: E402
from app.model import (Infeasible, SolveParams,                 # noqa: E402
                       cheapest_feasible_budget, solve_plan)

# Presets measured against the catalogue, not guessed. Within 1700-2100 kcal the
# most protein reachable is 110g/day, so a 140g "cut" target was fantasy. Bulk is
# unreachable at any budget — 2800 kcal/day needs calorie-dense snacks and the
# `snack` slot is empty. It stays in deliberately: the honest INFEASIBLE answer
# is the headline feature.
GOALS = {
    "frugal":   dict(label="Getting by", kcal_band=(1700, 2400), min_protein_per_day=55),
    "cut":      dict(label="Cut",        kcal_band=(1700, 2100), min_protein_per_day=100),
    "maintain": dict(label="Maintain",   kcal_band=(2000, 2700), min_protein_per_day=100),
    "bulk":     dict(label="Bulk",       kcal_band=(2800, 3300), min_protein_per_day=140),
}
STORES = ["aldi", "tesco"]
DAYS = [1, 2, 3, 5, 7, 14]
STOPS = 13
# Per-duration slider range. Wide enough that the floor sits inside it for every
# goal, so the "not possible below X" state is reachable and so is comfortable.
SPAN = {1: (3, 27), 2: (5, 41), 3: (7, 55), 5: (10, 70), 7: (12, 84), 14: (25, 145)}


def budgets_for(days):
    lo, hi = SPAN[days]
    step = (hi - lo) / (STOPS - 1)
    return [round(lo + step * i, 2) for i in range(STOPS)]


def stocked_pantry(items, recipes, base):
    """Three cheapest weeks run back to back, so the cupboard reflects a
    returning user rather than someone who has never shopped."""
    pantry = {}
    for _ in range(3):
        try:
            p = solve_plan(items, recipes,
                           SolveParams(budget=999.0, objective="cheapest",
                                       pantry=pantry, **base))
        except Infeasible:
            return pantry
        pantry = p.closing_pantry
    return pantry


def main():
    out = {"goals": {k: {"label": v["label"], "kcal_band": v["kcal_band"],
                         "protein": v["min_protein_per_day"]}
                     for k, v in GOALS.items()},
           "stores": STORES, "days": DAYS,
           "budgets": {str(d): budgets_for(d) for d in DAYS},
           "plans": {}, "floors": {}, "methods": load_methods()}

    for store in STORES:
        items, recipes, _ = load(store)
        for days in DAYS:
            for goal, cfg in GOALS.items():
                base = dict(store=store, days=days, kcal_band=cfg["kcal_band"],
                            min_protein_per_day=cfg["min_protein_per_day"])
                combo = f"{store}|{days}|{goal}"

                first = cheapest_feasible_budget(
                    items, recipes, SolveParams(budget=999.0, **base))
                ongoing = None
                if first is not None:
                    pantry = stocked_pantry(items, recipes, base)
                    ongoing = cheapest_feasible_budget(
                        items, recipes, SolveParams(budget=999.0, pantry=pantry, **base))
                out["floors"][combo] = {"first": first, "ongoing": ongoing}
                print(f"{combo:<22} first "
                      f"{('£%.2f' % first) if first else 'none':>8}   ongoing "
                      f"{('£%.2f' % ongoing) if ongoing else 'none':>8}", flush=True)

                # When money is not the blocker the diagnosis does not depend on
                # the budget, so it is computed once rather than 13 times.
                structural = None
                if first is None:
                    try:
                        solve_plan(items, recipes, SolveParams(budget=999.0, **base))
                    except Infeasible as e:
                        structural = {"status": "infeasible", "binding": e.binding,
                                      "also_binding": e.also_binding,
                                      "suggestion": e.suggestion,
                                      "min_feasible_budget": None}

                for budget in budgets_for(days):
                    key = f"{combo}|{budget}"
                    if structural is not None:
                        out["plans"][key] = structural
                        continue
                    # Below a known floor the answer is already known — no solve.
                    if budget < first:
                        out["plans"][key] = {
                            "status": "infeasible", "binding": "budget",
                            "also_binding": [], "min_feasible_budget": first,
                            "suggestion": (
                                f"£{budget:.2f} is not enough at {store.title()}. "
                                f"£{first:.2f} is the cheapest {days}-day plan there "
                                f"for these targets.")}
                        continue
                    p = solve_plan(items, recipes, SolveParams(budget=budget, **base))
                    out["plans"][key] = {
                        "status": "ok", "spend": p.spend,
                        "consumed_value": p.consumed_value,
                        "carry_over_value": p.carry_over_value,
                        "wasted_value": p.wasted_value,
                        "protein_per_day": p.protein_per_day,
                        "kcal_per_day": p.kcal_per_day,
                        "meals": p.meals,
                        "basket": [vars(b) for b in p.basket]}

    dest = Path(__file__).resolve().parents[3] / "demo" / "plans.json"
    dest.parent.mkdir(exist_ok=True)
    dest.write_text(json.dumps(out, separators=(",", ":")))
    ok = sum(1 for v in out["plans"].values() if v["status"] == "ok")
    print(f"\n{len(out['plans'])} combinations, {ok} feasible")
    print(f"wrote {dest} ({dest.stat().st_size / 1024:.0f} KB)")


def load_methods():
    """Cooking copy, written by Claude and validated by app.method_check. Keyed
    by recipe, not by plan — the steps never change with the budget."""
    import psycopg

    from app import config
    with psycopg.connect(config.DATABASE_URL) as conn:
        rows = conn.execute(
            "SELECT slug, method_md FROM recipe WHERE method_md IS NOT NULL").fetchall()
    out = {}
    for slug, md in rows:
        head, _, rest = md.partition("\n\n")
        out[slug] = {"summary": head.strip(),
                     "steps": [ln.split(". ", 1)[1] for ln in rest.strip().splitlines()
                               if ". " in ln]}
    return out


if __name__ == "__main__":
    main()
