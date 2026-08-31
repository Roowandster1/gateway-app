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
from .model import Infeasible, SolveParams, solve_plan
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
        # Session 3 completes this: identify the binding constraint via an
        # elastic model and re-solve with budget as the objective to report the
        # cheapest feasible week. SPEC §2 — a headline feature, not an error.
        return JSONResponse(status_code=200, content={
            "status": "infeasible",
            "binding": e.binding,
            "suggestion": (
                f"No plan at {req.store} for £{req.budget:.2f} hits "
                f"{req.min_protein_per_day:.0f}g protein a day over {req.days} days."
            ),
            "min_feasible_budget": None,
        })

    body = dataclasses.asdict(plan)
    if dropped:
        body["catalogue_gaps"] = dropped
    return body
