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
import multiprocessing
import sys
import tempfile
from pathlib import Path

import pulp

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app import filters                                        # noqa: E402
from app.catalogue import load                                  # noqa: E402
from app.model import (Infeasible, SolveParams,                 # noqa: E402
                       cheapest_feasible_budget, solve_plan)

# Diet presets the demo can actually show. The filter space is combinatorial and
# cannot be pre-solved whole, so a handful of real ones are exported and the demo
# says which. Four is what fits inside a reasonable export; the live app takes
# any combination.
DIETS = {
    "any":    dict(label="Anything",    diet=dict()),
    "veggie": dict(label="Veggie",      diet=dict(styles=["veggie"])),
    "gf":     dict(label="Gluten free", diet=dict(allergens=["gluten"])),
    "df":     dict(label="Dairy free",  diet=dict(allergens=["dairy"])),
}

# Presets measured against the catalogue, not guessed. Within 1700-2100 kcal the
# most protein reachable is 110g/day, so a 140g "cut" target was fantasy. Bulk is
# unreachable at any budget — 2800 kcal/day needs calorie-dense snacks and the
# `snack` slot is empty. It stays in deliberately: the honest INFEASIBLE answer
# is the headline feature.
GOALS = {
    "frugal":   dict(label="Getting by", kcal_band=(1700, 2400), min_protein_per_day=55),
    "cut":      dict(label="Cut",        kcal_band=(1700, 2100), min_protein_per_day=100),
    "maintain": dict(label="Maintain",   kcal_band=(2000, 2700), min_protein_per_day=100),
    "bulk":     dict(label="Bulk",       kcal_band=(2800, 3300), min_protein_per_day=130),
}
STORES = ["aldi", "tesco"]
# Four durations rather than six. Each (store, days, goal, diet) needs its own
# floor, and a floor is five CBC runs — with 223 recipes that is the expensive
# part of this export, so the grid buys diet presets with duration steps.
DAYS = [1, 3, 7, 14]
STOPS = 9
# Per-duration slider range. Wide enough that the floor sits inside it for every
# goal, so the "not possible below X" state is reachable and so is comfortable.
# Low ends sit well under the cheapest week any preset produces, so a budget
# below the floor is always reachable and comes back as a real infeasible answer
# with the real number attached. These were calibrated against the 24-recipe
# catalogue and went stale when generating recipes dropped the floors by half:
# a fortnight's range started at £25 while the floor had fallen to £17.44, which
# is the "the minimum is £25 but people get by on less" complaint returning by
# the back door. Re-check them whenever the catalogue changes.
SPAN = {1: (1, 27), 3: (2, 55), 7: (4, 84), 14: (7, 145)}


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


_CACHE: dict = {}


def _init_worker():
    """
    Give each worker its own temp directory.

    PuLP writes the LP file and CBC's output into a temp path derived from the
    problem's name, so four workers solving problems with the same name clobber
    each other's files. That surfaces as a bare PulpSolverError two hundred
    solves in, which is a miserable thing to debug — hence a comment rather than
    a one-line fix.
    """
    tempfile.tempdir = tempfile.mkdtemp(prefix="tt-export-")


def _catalogue(store):
    """One catalogue per worker process, loaded once."""
    if store not in _CACHE:
        _CACHE[store] = load(store)[:2]
    return _CACHE[store]


def one_combo(job):
    """
    Everything for a single (store, days, goal, diet): the floor pair and every
    budget stop. Independent of every other combo, which is what lets the export
    run across cores — 128 floors at five CBC runs each is over two hours in a
    single process and about forty minutes across four.
    """
    store, days, goal, diet_key = job
    items, recipes = _catalogue(store)
    cfg = GOALS[goal]

    report = filters.apply(items, recipes,
                           filters.Diet.of(**DIETS[diet_key]["diet"]))
    excluded = tuple(sorted(report.excluded))
    base = dict(store=store, days=days, kcal_band=cfg["kcal_band"],
                min_protein_per_day=cfg["min_protein_per_day"],
                exclude_recipes=excluded)
    combo = f"{store}|{days}|{goal}|{diet_key}"

    first = cheapest_feasible_budget(items, recipes, SolveParams(budget=999.0, **base))
    ongoing = None
    if first is not None:
        pantry = stocked_pantry(items, recipes, base)
        ongoing = cheapest_feasible_budget(
            items, recipes, SolveParams(budget=999.0, pantry=pantry, **base))

    plans, missing = {}, []
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
            plans[key] = structural
            continue
        # Below a known floor the answer is already known — no solve.
        if budget < first:
            plans[key] = {
                "status": "infeasible", "binding": "budget", "also_binding": [],
                "min_feasible_budget": first,
                "suggestion": (
                    f"£{budget:.2f} is not enough at {store.title()}. "
                    f"£{first:.2f} is the cheapest {days}-day plan there "
                    f"for these targets.")}
            continue
        # A 14-day plan over 222 recipes is a big enough MILP that CBC falls
        # over when several run at once — every 1, 3 and 7-day combo finished
        # and the crash was always on the first fortnight. Retry once, and if it
        # fails again leave the key out: the demo already renders a missing
        # combination as "outside the exported grid", which is true, rather than
        # inventing a plan for it.
        p = None
        for attempt in (1, 2):
            try:
                p = solve_plan(items, recipes, SolveParams(budget=budget, **base))
                break
            except pulp.PulpSolverError:
                if attempt == 2:
                    missing.append(key)
        if p is None:
            continue
        plans[key] = {
            "status": "ok", "spend": p.spend,
            "consumed_value": p.consumed_value,
            "carry_over_value": p.carry_over_value,
            "wasted_value": p.wasted_value,
            "protein_per_day": p.protein_per_day,
            "kcal_per_day": p.kcal_per_day,
            "meals": p.meals,
            "basket": [vars(b) for b in p.basket]}

    return combo, {"first": first, "ongoing": ongoing,
                   "recipes_left": report.total_remaining}, plans, missing


def main():
    jobs = [(store, days, goal, diet)
            for store in STORES for days in DAYS
            for goal in GOALS for diet in DIETS]

    out = {"goals": {k: {"label": v["label"], "kcal_band": v["kcal_band"],
                         "protein": v["min_protein_per_day"]}
                     for k, v in GOALS.items()},
           "diets": {k: {"label": v["label"]} for k, v in DIETS.items()},
           "stores": STORES, "days": DAYS,
           "budgets": {str(d): budgets_for(d) for d in DAYS},
           "plans": {}, "floors": {}, "methods": load_methods()}

    # Two workers, not three: a fortnight's MILP is large, and three of them at
    # once is what CBC could not survive.
    dropped = []
    with multiprocessing.Pool(2, initializer=_init_worker) as pool:
        for n, (combo, floor, plans, missing) in enumerate(
                pool.imap_unordered(one_combo, jobs), 1):
            out["floors"][combo] = floor
            out["plans"].update(plans)
            dropped.extend(missing)
            first = floor["first"]
            print(f"[{n:>3}/{len(jobs)}] {combo:<26} first "
                  f"{('£%.2f' % first) if first else 'none':>8}   ongoing "
                  f"{('£%.2f' % floor['ongoing']) if floor['ongoing'] else 'none':>8}",
                  flush=True)

    dest = Path(__file__).resolve().parents[3] / "demo" / "plans.json"
    dest.parent.mkdir(exist_ok=True)
    dest.write_text(json.dumps(out, separators=(",", ":")))
    ok = sum(1 for v in out["plans"].values() if v["status"] == "ok")
    print(f"\n{len(out['plans'])} combinations, {ok} feasible")
    if dropped:
        print(f"{len(dropped)} the solver could not finish, left out rather than faked:")
        for k in dropped[:10]:
            print("  " + k)
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
