# pantry

Weekly budget + a supermarket in, a week of meals and a shopping list that costs
that much at the till out.

Food is sold in packs, not grams. That makes this an integer optimisation over
whole packs, not recipe selection — see `CLAUDE.md`.

## Layout

```
apps/web/           Next.js 15 + TS + Tailwind (no UI yet)
services/solver/    FastAPI + PuLP/CBC — the optimiser
db/migrations/      schema + seed, applied in filename order
db/seed/            classification + generator for the seed SQL
prototype/          the original proof. Source of truth for the model, not for style
baselines/          saved solver output, the before-diff for any model change
```

## Run

```bash
docker compose up --build          # db on :5432, solver on :8000
curl localhost:8000/health
```

Without Docker:

```bash
createdb pantry
for f in db/migrations/0*.sql; do psql -d pantry -f "$f"; done
python3 -m venv .venv && .venv/bin/pip install -r services/solver/requirements.txt
cd services/solver && ../../.venv/bin/uvicorn app.main:app --port 8000
```

Regenerate seed SQL after editing the catalogue or the classification:

```bash
python3 db/seed/generate.py
```

The app (needs the solver running on :8000):

```bash
cd apps/web && npm install
SOLVER_URL=http://127.0.0.1:8000 npm run dev
# open http://localhost:3000
```

Tests and the 4-week acceptance simulation (both need a seeded database):

```bash
.venv/bin/pip install -r services/solver/requirements-dev.txt
cd services/solver
../../.venv/bin/python -m pytest tests -q
../../.venv/bin/python scripts/simulate_weeks.py
```

## Reading order

`CLAUDE.md` (rules and domain) → `SPEC.md` (schema, solver contract, phases) →
`PROGRESS.md` (what is built, what is open) → `RECEIPTS.md` (the honesty metric).
