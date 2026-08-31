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

_(Session 2 follows below.)_

---

## Session 2 — the carry-over model

Decision on open item 1: **shelf life**, confirmed by the owner.
`CARRY_BY_SHELF_LIFE = true`.

**Built**

- `app/domain.py` — `Item` / `Recipe`, no DB or framework, so the model is
  testable without either. `Item.carries()` is the shelf-life rule.
- `app/catalogue.py` — loads items priced at the requested store. An unpriced
  item is excluded and any recipe needing it is dropped and *reported*
  (CLAUDE.md rule 3).
- `app/model.py` — the model, ported from `prototype/solver.py`, plus pantry
  subtraction, the leftover split, and the SPEC §3(d) objective.
- `scripts/simulate_weeks.py` — the 4-week acceptance test.
- `tests/` — 9 tests, including hand-checked arithmetic.
- `/solve` is live.

**The 4-week simulation** (Aldi, £30, 100g protein/day, `protein` objective)

```
        till spend   carried   wasted  cupboard  protein/d   kcal/d
wk 1        £29.67    £10.10    £2.04    £10.10       108g     2028
wk 2        £21.45     £4.11    £3.35     £9.58       110g     2023
wk 3        £20.36     £4.22    £3.35     £7.90       110g     2011
wk 4        £25.25     £8.36    £3.35    £11.18       110g     2023

4 weeks: £96.73. Without a cupboard: £118.68. Saved £21.95.
```

Week 1 reproduces the prototype exactly — £29.67, same meals — so the port did
not move the model. Week 2 draws 16 items free from the cupboard and costs
28% less at *higher* protein.

Week 4 rising to £25.25 is not a regression. It is the sawtooth of pack buying:
a 1kg bag of rice lasts about two weeks, then it is rebought. Cost oscillates
around a floor rather than falling monotonically, which is why the test asserts
a plateau rather than a monotonic decline.

**Bug found and fixed: `WASTE_PENALTY` did nothing.**

The leftover variable was bounded from above only. For penalised items the
objective drives it to zero, so the model optimised as though waste were free —
while `_extract` computed the reported waste separately from actual quantities
and printed a correct-looking £3.35. Reporting was right; the optimisation was
blind. Only a sensitivity sweep catches that class of bug, since every output
looks plausible.

Fixed by pinning `leftover == bought - used` for non-carrying items. Carrying
items are credited, so the objective pushes their leftover up to the true
minimum on its own and upper bounds remain correct — the two cases are genuinely
asymmetric. `test_waste_penalty_actually_changes_the_plan` is the regression
test.

---

## Open decisions — need a call before Session 3

### 5. `WASTE_PENALTY = 1.5` is still inert under the `protein` objective

With the bug fixed the knob works, but not at the spec's suggested value:

```
objective   WASTE_PENALTY    spend   wasted  protein/d
protein               1.5   £21.45    £3.35       110g
protein              15.0   £18.75    £1.96       109g
protein             100.0   £16.92    £0.53       106g
```

The cause is a units mismatch, not the penalty. The objective is
`protein - 0.5 * cost`, with protein in grams and cost in pounds, so one gram of
protein is implicitly worth £2. Against that, £1 of waste is worth half a gram
of protein and never changes a decision. SPEC's 1.5 was presumably calibrated
against a `cheapest`-like scale.

**Recommendation: `WASTE_PENALTY = 15` for the `protein` objective.** It is
strictly better on the two numbers that matter — £2.70 a week cheaper and £1.39
less waste — for one gram of protein a day. Default left at the spec's 1.5
pending your call, since changing it silently would be overriding your spec.

### 6. The week-on-week saving depends on protein saturating

Under `protein` the solver converts freed budget into more protein rather than
handing money back, until protein saturates around 110g/day — then it stops and
the saving appears. Give it a partial cupboard and it *spends more*, not less
(£29.87 vs £29.67), because it can now afford to reach the ceiling.

That is consistent with CLAUDE.md's "given £40 it only spent £32.96", and it is
defensible. But it means "week 2 is cheaper" is a consequence of satiation, not
a direct result of the pantry. Under `cheapest` the mechanic is far starker:
**£23.54 → £11.13**. Worth deciding which objective the product ships as the
default before P2 builds screens around it.

---

## Notes

- Cook time is counted per **cook**, not per serving: one pan of chilli for four
  is one cook. SPEC §7 asks for household scaling to be explicit; with
  `household_size = 1` this reduces to the prototype exactly.
- `max_repeat` counts meals, not servings, for the same reason.
- Tesco at £25 returns `infeasible`, matching KICKOFF §3. `min_feasible_budget`
  is still null — that is Session 3, via the elastic model in open decision 4.

---

## Session 3 — infeasibility as a feature

Resolves open decision 4. SPEC §2's structured `INFEASIBLE` is live.

**How the binding constraint is found**

CBC cannot name it: an infeasible integer program has no dual, and PuLP exposes
no irreducible infeasible subset. So the model is rebuilt *elastic* — every
constraint a user could plausibly relax gets a slack variable, each normalised
by its own right-hand side so pounds, grams, calories and minutes are
comparable. Minimising total normalised slack finds the smallest set of
relaxations that restores feasibility; the largest slack is what is blocking the
plan. The cheapest feasible week comes from a second solve with the budget cap
dropped and till spend minimised.

`model.py` was restructured so the plan solve, the diagnosis and the
cheapest-budget search share one `_build()`. Per the KICKOFF standing
instruction the 4-week simulation was run before and after: **byte-identical**.

**KICKOFF §3 acceptance cases**

```
tesco £25  ->  INFEASIBLE  binding=budget  floor=£28.58
               "£25.00 is not enough at Tesco. £28.58 is the cheapest
                feasible week there for these targets."
aldi  £25  ->  FEASIBLE    £24.94 · 102g protein/day      (spec says ~£24.94)
```

**Other diagnoses, all returning a named constraint and plain English**

| Request | Binding | Floor |
|---|---|---|
| Aldi £5 | `budget` | £23.54 |
| Aldi, 250g protein/day | `min_protein_per_day` | none — money cannot fix it |
| Aldi, 8 cook-minutes/day | `max_cook_minutes_per_day` | none |
| Aldi, 12 distinct mains | `min_distinct_mains` | none |
| Aldi, 14 days | `breakfast_recipe_supply` | none |

`min_feasible_budget` is null whenever money is not the problem, rather than a
number that would be a guess. `/solve` returns HTTP 200 for infeasible: the
client renders it, it is not a failed request.

That last row is the 1–2 week slider from the UI schematic. The 14-day plan
fails on breakfasts, not money: *"5 of the 14 breakfast servings cannot be
filled without repeating a recipe more than 3 times."* 5 more tests, 14 total.

---

## Next session

1. **Add 3–4 breakfast recipes** — unblocks the right-hand end of the duration
   slider. Cheap, and better ingredient overlap improves every plan.
2. **P2: the four onboarding pages** — shop → duration → budget → goal.
   The budget slider can now show its floor instead of dead-ending.

Still open for the owner: `WASTE_PENALTY` 1.5 -> 15 (open decision 5), the
default objective (open decision 6), and whether a 2-week plan is two linked
weekly shops rather than one basket — one shop cannot cover a fortnight of
3-day-shelf-life chicken without breaking CLAUDE.md hard rule 4.
