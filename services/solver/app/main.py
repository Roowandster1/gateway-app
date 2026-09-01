"""
Solver service.

The optimiser is deterministic integer programming. No model is consulted for
selection, pricing, or quantities — CLAUDE.md hard rule 1.
"""
import dataclasses

import pulp
from fastapi import FastAPI
from fastapi.responses import JSONResponse

from . import config, filters
from .catalogue import load
from .model import (Infeasible, SolveParams, cheapest_feasible_budget,
                    solve_plan)
from .schemas import SolveRequest

app = FastAPI(title="pantry solver", version="0.2.0")


def _filtered(req: SolveRequest, items, recipes):
    """
    Apply the dietary answers, and report a filter set that can never work.

    A filter that empties a meal slot is not a budget problem, so it is caught
    here rather than handed to CBC — reporting "budget too low" for a catalogue
    that has no gluten-free breakfast would name the wrong constraint, which is
    the one thing SPEC §2 says an infeasible answer must never do.
    """
    diet = filters.Diet.of(req.avoid_allergens, req.appliances,
                           req.avoid_proteins, req.styles)
    report = filters.apply(items, recipes, diet)
    return diet, report, tuple(sorted(set(req.exclude_recipes) | report.excluded))


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

    diet, report, excluded = _filtered(req, items, recipes)
    if filters.blocked_reason(report, diet, recipes) is not None:
        return {"store": req.store, "days": req.days, "first": None, "ongoing": None,
                "blocked": filters.blocked_reason(report, diet, recipes),
                "recipes_left": report.total_remaining}

    def params(pantry):
        return SolveParams(
            store=req.store, budget=10_000.0, days=req.days,
            meals_per_day=req.meals_per_day, household_size=req.household_size,
            min_protein_per_day=req.min_protein_per_day, kcal_band=tuple(req.kcal_band),
            max_cook_minutes_per_day=req.max_cook_minutes_per_day,
            max_repeat=req.max_repeat, min_distinct_mains=req.min_distinct_mains,
            pantry=pantry, exclude_items=tuple(req.exclude_items),
            exclude_recipes=excluded, objective="cheapest")

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

    return {"store": req.store, "days": req.days, "first": first, "ongoing": ongoing,
            "blocked": None, "recipes_left": report.total_remaining}


@app.post("/solve")
def solve(req: SolveRequest):
    try:
        items, recipes, dropped = load(req.store)
    except ValueError as e:
        return JSONResponse(status_code=404, content={"status": "error", "detail": str(e)})

    diet, report, excluded = _filtered(req, items, recipes)
    blocked = filters.blocked_reason(report, diet, recipes)
    if blocked is not None:
        # Answered before CBC is asked: no budget can conjure a recipe that is
        # not in the catalogue.
        return JSONResponse(status_code=200, content={
            "status": "infeasible",
            "binding": "filters",
            "suggestion": blocked,
            "min_feasible_budget": None,
            "also_binding": sorted(report.by_reason),
            "recipes_left": report.total_remaining,
            "removed_by": {k: len(v) for k, v in sorted(report.by_reason.items())},
        })

    params = SolveParams(
        store=req.store, budget=req.budget, days=req.days,
        meals_per_day=req.meals_per_day, household_size=req.household_size,
        min_protein_per_day=req.min_protein_per_day, kcal_band=tuple(req.kcal_band),
        max_cook_minutes_per_day=req.max_cook_minutes_per_day,
        max_repeat=req.max_repeat, min_distinct_mains=req.min_distinct_mains,
        pantry=req.pantry, exclude_items=tuple(req.exclude_items),
        exclude_recipes=excluded, objective=req.objective,
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
            "recipes_left": report.total_remaining,
            "removed_by": {k: len(v) for k, v in sorted(report.by_reason.items())},
        })

    # The discriminator the client branches on. Without it a successful plan is
    # indistinguishable from an infeasible one, because both arrive as HTTP 200.
    body = {"status": "ok", **dataclasses.asdict(plan)}
    body["recipes_left"] = report.total_remaining
    if dropped:
        body["catalogue_gaps"] = dropped
    return body
