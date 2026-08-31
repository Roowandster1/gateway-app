"""
Every tunable number in the model lives here. SPEC §3(d): the carry-over and
waste weights "must be tunable constants in one place, not scattered magic
numbers". Nothing in the solver may hard-code these.
"""
import os


def _f(name, default):
    return float(os.environ.get(name, default))


def _i(name, default):
    return int(os.environ.get(name, default))


# --- objective weights (SPEC §3(d)) ---------------------------------------
# Staple leftover is an asset: we recover this fraction of its unit cost.
CARRY_VALUE = _f("CARRY_VALUE", 0.7)
# Perishable leftover is dead money, and is punished above its face cost.
WASTE_PENALTY = _f("WASTE_PENALTY", 1.5)
# Prototype objective was `protein - 0.5 * cost`. CLAUDE.md is explicit that the
# under-spend behaviour this produces is a feature, so the weight is preserved.
PROTEIN_COST_WEIGHT = _f("PROTEIN_COST_WEIGHT", 0.5)

# --- carry-over rule ------------------------------------------------------
# OPEN DECISION (PROGRESS.md #1): if True, a perishable whose shelf life covers
# the plan horizon carries over instead of being booked as waste. If False, the
# binary `keeps` flag decides, per a literal reading of SPEC §3(c).
CARRY_BY_SHELF_LIFE = os.environ.get("CARRY_BY_SHELF_LIFE", "true").lower() == "true"

# --- planning defaults (SPEC §2) ------------------------------------------
DEFAULT_DAYS = _i("DEFAULT_DAYS", 7)
DEFAULT_MEALS_PER_DAY = _i("DEFAULT_MEALS_PER_DAY", 3)
DEFAULT_MIN_PROTEIN_PER_DAY = _f("DEFAULT_MIN_PROTEIN_PER_DAY", 100)
DEFAULT_KCAL_BAND = (_f("DEFAULT_KCAL_MIN", 2000), _f("DEFAULT_KCAL_MAX", 2700))
DEFAULT_MAX_COOK_MINUTES_PER_DAY = _f("DEFAULT_MAX_COOK_MINUTES_PER_DAY", 75)
DEFAULT_MAX_REPEAT = _i("DEFAULT_MAX_REPEAT", 3)
DEFAULT_MIN_DISTINCT_MAINS = _i("DEFAULT_MIN_DISTINCT_MAINS", 5)

# --- solver limits --------------------------------------------------------
MAX_PACKS_PER_ITEM = _i("MAX_PACKS_PER_ITEM", 12)
SOLVE_TIMEOUT_SECONDS = _i("SOLVE_TIMEOUT_SECONDS", 20)

DATABASE_URL = os.environ.get(
    "DATABASE_URL", "postgresql://pantry:pantry@localhost:5432/pantry"
)
