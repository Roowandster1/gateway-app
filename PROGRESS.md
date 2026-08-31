# PROGRESS.md

Running log. One entry per session: what changed, what was verified, what the
next session picks up.

---

## Session 1 — P0 scaffold and seed

**Built**

- `db/migrations/` — SPEC §1 schema plus seed data, five migrations, applied in
  filename order.
- `db/seed/` — `classify.py` (the staple/perishable judgement call) and
  `generate.py`, which reads `prototype/catalogue.py` and emits the seed SQL.
  The catalogue is ported by machine so prices and macros cannot drift from the
  prototype. Re-run with `python3 db/seed/generate.py`.
- `services/solver/` — FastAPI + PuLP. `/health` only. `config.py` holds every
  tunable, including `CARRY_VALUE` and `WASTE_PENALTY` (SPEC §3(d)).
  `schemas.py` fixes the `/solve` contract; `/solve` returns 501 until Session 2.
- `apps/web/` — Next.js 15 + TypeScript + Tailwind, `create-next-app` default.
  No UI, as instructed.
- `baselines/prototype-baseline.txt` — saved output of `prototype/run.py`, the
  before-diff for any solver change (KICKOFF standing instruction).

**Verified**

| Check | Result |
|---|---|
| All 5 migrations apply to a clean PG16 | pass |
| P0 done-when: items priced at both stores | **28** (bar is 25) |
| Seed prices match `catalogue.py` | spot-checked lentils, chicken, frozveg, cheese — exact |
| `GET /health` | `{"status":"ok","cbc_available":true}` |
| `POST /solve` | 501; invalid budget → 422 |
| `UPDATE item_price` blocked by trigger | pass |
| Flipping `is_current` still allowed | pass |
| Two current rows for one item+store blocked | pass |
| Unbalanced `plan_basket_line` blocked | pass |
| Prototype still runs | Aldi £25 → £24.94, Tesco £25 → INFEASIBLE (matches KICKOFF §3) |

**NOT verified: `docker compose up`.** Docker Hub's blob CDN
(`production.cloudfront.docker.com`) is blocked by this environment's network
policy — the daemon runs, but no image can be pulled. Everything above was
verified against a local PG16 cluster and a local venv instead, which exercises
the same migrations and the same app code. `docker-compose.yml` and the solver
`Dockerfile` are written but unrun. **Run `docker compose up --build` on a
machine with registry access before trusting them.**

---

## Open decisions — need a call before Session 2

### 1. Does the carry-over rule key off `keeps`, or off shelf life? (blocking)

SPEC §3(c) says perishable leftover is waste. But six of the twelve perishables
outlive a 7-day plan: cheese (21d), eggs (21d), onion (30d), potato (21d),
carrot (14d), tortilla (14d), yoghurt (10d).

Measured on the prototype's own £29.67 Aldi week, leftover valued at unit cost:

```
BINARY keeps rule (SPEC §3c):  carry £6.23  ·  waste £5.91
SHELF-LIFE rule (proposed):    carry £10.10 ·  waste £2.04
```

The binary rule books £5.91 of good food as waste — 20% of the week's spend —
led by cheese £1.58, yoghurt £0.92, milk £0.91. Worse than the misreporting:
with `WASTE_PENALTY = 1.5` the objective would carry ~£8.87 of penalty for that
week and steer away from a 400g cheddar block and 1kg yoghurt, two of the
cheapest protein sources in the catalogue.

Proposal: `carries = (keeps = 'staple' OR shelf_life_days >= days_per_plan)`,
with `keeps` kept as a UI label. Implemented behind
`config.CARRY_BY_SHELF_LIFE`, default `true`. Flip to `false` for a literal
SPEC §3(c) reading. **Milk is the honest edge case** — 7-day life against a
7-day horizon, so `>=` currently carries it. Arguably wrong for one person.

### 2. The 4-week acceptance test must measure till spend, not objective value

SPEC §3(d) credits staple leftover at `0.7 × unit_cost` this week, and §3(b)
then makes the same stock free next week — 1.7× total. If the acceptance test
reads the objective, week 2 is cheaper by construction and passes even with the
pantry logic broken, which is the exact failure the test exists to catch. It
must compare `Σ packs × price`.

### 3. The acceptance test is too weak either way

Week 1 buys 1kg of rice to use 550g, so week 2 is cheaper under almost any
implementation. Two assertions that actually discriminate:

- cost **plateaus** by week 3–4 rather than falling forever (converging on the
  marginal perishable cost);
- pantry **conserves**: for every item, `end = start + purchased − used`, exactly.
  Already enforced per basket line by the `basket_line_balances` CHECK.

### 4. Infeasibility needs an elastic model (affects how Session 2 writes constraints)

SPEC §2 wants the binding constraint named. CBC will not tell you: an infeasible
MIP has no dual, and PuLP exposes no IIS. Plan: give each soft constraint a
penalised slack variable and minimise total slack — the constraint with non-zero
slack *is* the binding one, and the same solve yields the cheapest feasible
budget. Cheap to build, but it shapes constraint construction, so it should be
agreed before the model is written rather than retrofitted.

---

## Catalogue gaps (CLAUDE.md rule 3 — logged, not invented)

- **`carb_per_100` / `fat_per_100` are NULL for all 28 items.** The prototype
  carries only kcal and protein. No fat or carbohydrate constraint is possible
  until sourced. Blocks part of SPEC §7's "nutrition beyond protein and calories".
- **`recipe.method_md` is NULL for all 15 recipes.** No cooking steps exist.
  CLAUDE.md rule 1 permits an LLM to write this copy — it is not selection,
  pricing, or quantities.
- **The `one-pot` tag is not emitted.** It cannot be derived without method text
  and guessing it would be inventing data. `vegetarian` (10) and `no-oven` (13)
  are derived from ingredients.
- **Seed prices have no true observation date.** They come from the prototype
  undated; `observed_at` is set to the seed date. The confidence UI must key off
  `source = 'seed'` meaning *unverified*, regardless of how fresh the timestamp
  looks.

---

## Next session — Session 2, the carry-over model

Per KICKOFF: port `prototype/solver.py` into `services/solver`, add pantry
subtraction, the leftover split, and the revised objective. Then the 4-week
simulation, with the corrections in open decisions 2 and 3. Diff against
`baselines/prototype-baseline.txt` and explain any movement in cost or macros.

Resolve open decision 1 first — it changes what the objective optimises.
