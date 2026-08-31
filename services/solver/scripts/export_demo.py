"""
Solve the whole demo grid with the real optimiser and write it to JSON.

The demo front end is static, so it cannot call the solver. Rather than mock
numbers — which would demo nothing — every combination is solved here in
advance and the genuine output is embedded. Every price, pack count and total
in the demo is what CBC actually returned.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.catalogue import load                                  # noqa: E402
from app.model import (Infeasible, SolveParams, cheapest_feasible_budget,  # noqa: E402
                       solve_plan)

# Goal presets. These are presets for roughly an 80kg adult, NOT a calculation:
# real targets need bodyweight, which onboarding does not collect yet.
# Measured against the catalogue, not guessed. Within 1700-2100 kcal the most
# protein reachable is 110g/day, so a 140g "cut" target was fantasy. Bulk is
# genuinely unreachable at any budget or meal count: 2800 kcal/day needs
# calorie-dense snacks and the `snack` slot is still empty. It is left in
# deliberately — the honest INFEASIBLE answer is the product's headline feature.
GOALS = {
    "cut":      dict(label="Cut",      kcal_band=(1700, 2100), min_protein_per_day=100),
    "maintain": dict(label="Maintain", kcal_band=(2000, 2700), min_protein_per_day=100),
    "bulk":     dict(label="Bulk",     kcal_band=(2800, 3300), min_protein_per_day=140),
}
STORES = ["aldi", "tesco"]
BUDGETS = {7: [x / 2 for x in range(30, 121, 5)],      # £15.00 - £60.00, 50p-ish steps
           14: [float(x) for x in range(30, 121, 5)]}  # £30 - £120, £5 steps


def main():
    out = {"goals": {k: {"label": v["label"], "kcal_band": v["kcal_band"],
                         "protein": v["min_protein_per_day"]}
                     for k, v in GOALS.items()},
           "stores": STORES, "plans": {}, "floors": {}}

    for store in STORES:
        items, recipes, _ = load(store)
        for days in (7, 14):
            for goal, cfg in GOALS.items():
                base = dict(store=store, days=days,
                            kcal_band=cfg["kcal_band"],
                            min_protein_per_day=cfg["min_protein_per_day"])
                floor = cheapest_feasible_budget(
                    items, recipes, SolveParams(budget=999.0, **base))
                out["floors"][f"{store}|{days}|{goal}"] = floor
                print(f"{store} {days}d {goal}: floor "
                      f"{'£%.2f' % floor if floor else 'none'}", flush=True)

                for budget in BUDGETS[days]:
                    key = f"{store}|{days}|{goal}|{budget}"
                    try:
                        p = solve_plan(items, recipes,
                                       SolveParams(budget=budget, **base))
                    except Infeasible as e:
                        out["plans"][key] = {
                            "status": "infeasible", "binding": e.binding,
                            "also_binding": e.also_binding,
                            "suggestion": e.suggestion,
                            "min_feasible_budget": e.min_feasible_budget}
                        continue
                    out["plans"][key] = {
                        "status": "ok", "spend": p.spend,
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
    print(f"\n{len(out['plans'])} combinations solved, {ok} feasible")
    print(f"wrote {dest} ({dest.stat().st_size / 1024:.0f} KB)")


if __name__ == "__main__":
    main()
