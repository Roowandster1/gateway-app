"""
Solver service.

The optimiser is deterministic integer programming. No model is consulted for
selection, pricing, or quantities — CLAUDE.md hard rule 1.
"""
import dataclasses

import pulp
from fastapi import FastAPI
from fastapi.responses import JSONResponse

from . import config
from .catalogue import load
from .model import (Infeasible, SolveParams, cheapest_feasible_budget,
                    solve_plan)
from .schemas import SolveRequest

app = FastAPI(title="pantry solver", version="0.2.0")


@app.get("/health")
def health():
    """Liveness. Reports CBC availability — a solver without CBC is not healthy."""
    try:
        cbc_ok = pulp.PULP_CBC_CMD(msg=0).available()
    except Exception:
        cbc_ok = False
    return {
        "status": "ok" if cbc_ok else "degraded",
        "service": "solver",
        "version": app.version,
        "cbc_available": bool(cbc_ok),
        "carry_value": config.CARRY_VALUE,
        "waste_penalty": config.WASTE_PENALTY,
        "carry_by_shelf_life": config.CARRY_BY_SHELF_LIFE,
    }


@app.post("/floor")
def floor(req: SolveRequest):
    """
    The cheapest plan that meets these targets, before anyone picks a budget.

    Two numbers, never one. `first` assumes an empty cupboard; `ongoing` assumes
    a stocked one. Quoting `first` as the recurring cost overstates it by around
    40%, because a large share of a first shop is stock the user still owns
    afterwards. `ongoing` is null when the caller supplies no pantry and the
    targets are unreachable at any budget.
    """
    try:
        items, recipes, _ = load(req.store)
    except ValueError as e:
        return JSONResponse(status_code=404, content={"status": "error", "detail": str(e)})

    def params(pantry):
        return SolveParams(
            store=req.store, budget=10_000.0, days=req.days,
            meals_per_day=req.meals_per_day, household_size=req.household_size,
            min_protein_per_day=req.min_protein_per_day, kcal_band=tuple(req.kcal_band),
            max_cook_minutes_per_day=req.max_cook_minutes_per_day,
            max_repeat=req.max_repeat, min_distinct_mains=req.min_distinct_mains,
            pantry=pantry, exclude_items=tuple(req.exclude_items),
            exclude_recipes=tuple(req.exclude_recipes), objective="cheapest")

    first = cheapest_feasible_budget(items, recipes, params(req.pantry))
    ongoing = None
    if first is not None:
        pantry = dict(req.pantry)
        if not pantry:
            # Model a returning user: three cheapest runs back to back.
            for _ in range(3):
                try:
                    pantry = solve_plan(items, recipes, params(pantry)).closing_pantry
                except Infeasible:
                    break
        ongoing = cheapest_feasible_budget(items, recipes, params(pantry))

    return {"store": req.store, "days": req.days, "first": first, "ongoing": ongoing}


@app.post("/solve")
def solve(req: SolveRequest):
    try:
        items, recipes, dropped = load(req.store)
    except ValueError as e:
        return JSONResponse(status_code=404, content={"status": "error", "detail": str(e)})

    params = SolveParams(
        store=req.store, budget=req.budget, days=req.days,
        meals_per_day=req.meals_per_day, household_size=req.household_size,
        min_protein_per_day=req.min_protein_per_day, kcal_band=tuple(req.kcal_band),
        max_cook_minutes_per_day=req.max_cook_minutes_per_day,
        max_repeat=req.max_repeat, min_distinct_mains=req.min_distinct_mains,
        pantry=req.pantry, exclude_items=tuple(req.exclude_items),
        exclude_recipes=tuple(req.exclude_recipes), objective=req.objective,
    )

    try:
        plan = solve_plan(items, recipes, params)
    except Infeasible as e:
        # SPEC §2: a headline feature, not an error path. 200, not 4xx — the
        # client renders this, it does not treat it as a failed request.
        return JSONResponse(status_code=200, content={
            "status": "infeasible",
            "binding": e.binding,
            "suggestion": e.suggestion,
            "min_feasible_budget": e.min_feasible_budget,
            "also_binding": e.also_binding,
        })

    # The discriminator the client branches on. Without it a successful plan is
    # indistinguishable from an infeasible one, because both arrive as HTTP 200.
    body = {"status": "ok", **dataclasses.asdict(plan)}
    if dropped:
        body["catalogue_gaps"] = dropped
    return body
