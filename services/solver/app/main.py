"""
Solver service. P0 exposes /health only — the model lands in Session 2
(SPEC §3). /solve is declared so the contract is fixed, and returns 501
rather than a placeholder plan: a wrong plan is worse than no plan.
"""
import pulp
from fastapi import FastAPI
from fastapi.responses import JSONResponse

from . import config
from .schemas import SolveRequest

app = FastAPI(title="pantry solver", version="0.1.0")


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
    }


@app.post("/solve")
def solve(req: SolveRequest):
    return JSONResponse(
        status_code=501,
        content={
            "status": "not_implemented",
            "detail": "The optimiser lands in Session 2. See SPEC.md §3.",
            "received_store": req.store,
        },
    )
