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
#
# SPEC §3(d) suggested 1.5. The value has to be large because of a units
# mismatch: the `protein` objective is `protein - PROTEIN_COST_WEIGHT * cost`,
# with protein in grams and cost in pounds, so a gram of protein is implicitly
# worth £2 and a small penalty never wins an argument.
#
# Re-measured on the current 24-recipe catalogue (a fortnight at Aldi, £60):
#
#   penalty    spend    waste   protein/d
#       1.5   £51.32    £2.91        134g
#      15.0   £51.32    £2.91        134g   <- no different from 1.5 any more
#      50.0   £47.79    £1.58        132g   <- cheaper AND less waste
#     100.0   £48.14    £1.43        131g
#
# 50 is the knee: £3.53 cheaper over the fortnight and nearly half the waste,
# for 2g/day of protein. It stops the solver buying mince, which was the single
# worst waster. Re-measure this table when the catalogue changes — an earlier
# reading of 15 was correct before migration 008 and is now a no-op.
WASTE_PENALTY = _f("WASTE_PENALTY", 50.0)
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
# Snacks sit outside meals_per_day — see the snack cap in model.py.
DEFAULT_MAX_SNACKS_PER_DAY = _f("DEFAULT_MAX_SNACKS_PER_DAY", 2)
# Snack variety matters far less than meal variety — nobody objects to the same
# banana and peanut butter twice — so snacks get a looser repeat allowance.
# Without it, max_repeat caps a fortnight at roughly one snack a day.
SNACK_REPEAT_MULTIPLIER = _i("SNACK_REPEAT_MULTIPLIER", 4)
DEFAULT_MIN_DISTINCT_MAINS = _i("DEFAULT_MIN_DISTINCT_MAINS", 5)
# How many different proteins the week's mains must be built on. Distinct
# recipes stopped implying distinct dinners once the catalogue grew to 338:
# five rows can be lentils five ways. Three is what the 9 protein items can
# reliably support once a dietary filter has taken a couple away.
DEFAULT_MIN_DISTINCT_PROTEINS = _i("DEFAULT_MIN_DISTINCT_PROTEINS", 3)

# --- solver limits --------------------------------------------------------
MAX_PACKS_PER_ITEM = _i("MAX_PACKS_PER_ITEM", 12)
# CBC's wall-clock limit for one solve. A limit that is hit is NOT an
# infeasibility — see _has_incumbent in model.py. Raised from 20s when the
# catalogue went from 24 recipes to 223: a fortnight's plan legitimately needs
# longer than 20 seconds now, and stopping early was turning good plans into
# invented diagnoses.
SOLVE_TIMEOUT_SECONDS = _i("SOLVE_TIMEOUT_SECONDS", 45)

DATABASE_URL = os.environ.get(
    "DATABASE_URL", "postgresql://pantry:pantry@localhost:5432/pantry"
)
