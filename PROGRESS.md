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

---

## Session 4 — breakfasts, and a demo

**Migration 006: four more breakfasts.** `pbtoast`, `beanstoast`, `eggwrap`,
`oatpancake`. Every ingredient is already priced, so no new items and no new
prices. Seven breakfasts clears the 14-day slot count, and 2-week plans now
solve — Aldi 14 days lands at £44.00.

More variety also improved the weekly plan outright. The 4-week simulation is
now monotonic, where before it sawtoothed:

```
        till spend   carried   wasted  protein/d
wk 1        £29.93     £7.45    £3.72       112g      (was £29.67 / 108g)
wk 2        £25.06     £6.29    £2.59       113g
wk 3        £23.21     £5.87    £2.59       113g
wk 4        £18.97     £3.13    £2.59       113g
```

**Two findings from building the demo, both real**

1. **A 140g-protein "cut" is not reachable.** Measured against the catalogue,
   the most protein available within 1700–2100 kcal is **110g/day**. The recipes
   run about 4.3g protein per 100 kcal; a cut needs nearer 6.7. Presets were
   corrected to what the data supports rather than to what sounds right.
2. **Bulk is impossible at any budget or meal count.** 2800 kcal/day cannot be
   reached — at 3 meals a day the ceiling is about 2400, and raising it to 5
   just moves the blocker to `main_recipe_supply`. The catalogue has no
   calorie-dense snack, and the `snack` meal_slot is still unused. Bulk is left
   in the demo deliberately: the honest INFEASIBLE answer is the feature.

**The demo.** `demo/` holds `plans.json` (228 combinations, every one solved by
CBC via `scripts/export_demo.py`) and a static front end embedding it. Nothing
is mocked — the front end is static so it cannot call the solver, and inventing
numbers would demo nothing. Four screens matching the schematic: shop, length,
budget, goal, then the plan and the shopping list. The budget slider shows the
real feasible floor and refuses honestly below it.

---

## Next

- **Calorie-dense snack recipes**, to make `bulk` reachable and put the unused
  `snack` slot to work.
- **P2 proper**: the flow in `apps/web` against the live solver, not a static
  export.
- Still open: `WASTE_PENALTY` 1.5 -> 15, the default objective, and whether a
  2-week plan is two linked shops (the demo copy already promises it is).

---

## Session 5 — cooking steps, via Claude

All 19 recipes now have `method_md`. That gap is closed.

**Where the model is allowed, and how that is enforced**

CLAUDE.md rule 1 permits a model to write copy and forbids it near selection,
pricing and quantities. The line is easy to state and easy to cross by accident:
"stir in 200g of red lentils" puts a quantity the solver never chose in front of
the user, and "finish with a knob of butter" adds an ingredient nobody bought,
breaking rule 4.

So generated copy is not trusted, it is **checked**:

- `app/method_check.py` rejects any step stating a quantity (`200g`, `1.5
  litres`, `2 tbsp`) or a pack count (`a tin of`, `3 stock cubes`), and any step
  naming a catalogue item the recipe does not contain. Times and oven
  temperatures pass — they are method, not quantity.
- `scripts/generate_methods.py` calls `claude-opus-5` with structured outputs,
  runs every result through the checker, retries once with the failures fed
  back, and skips rather than publishing anything that fails twice. It runs
  **offline against the database** — no plan ever waits on a model.
- 15 tests in `tests/test_method_check.py`, written adversarially: quantities,
  pack counts, a chicken smuggled into the dahl, yoghurt into a recipe without
  it, and the false positives that would make the checker unusable ("toast the
  curry powder" is a verb, "peanut" must not trip the `pea` alias).

**On the seed copy.** This environment has no Anthropic credentials, so
`generate_methods.py` could not be run here. The 19 methods in migration 007
were written by Claude in-session — the same sanctioned path, the same model
family — and put through the identical checker and migration writer. All 19
passed on the first attempt. Re-run the script with a key to regenerate or to
cover new recipes; `--all` redoes existing ones.

**New catalogue gap: salt, pepper and water are assumed.** The checker allows
them as store-cupboard basics and reports every use. They are not priced items,
so strictly the basket does not cover them. Either add them to the catalogue
with real prices, or state the assumption in the UI. Currently neither.

**Demo.** `demo/` now builds from `template.html` + `plans.json` via
`build.py`, instead of having the data baked irreversibly into the page. Meals
expand to show their method. Re-exported with the methods included.

---

## Next

- **The receipt test.** Still the gate on P2 and still the highest-value thing
  in the project. 28 prices, none yet checked against a till. `RECEIPTS.md` is
  waiting for row one.
- Calorie-dense snack recipes, to make `bulk` reachable.
- P2 proper: the four screens in `apps/web` against the live solver.
- Still open: `WASTE_PENALTY` 1.5 -> 15, the default objective, and whether a
  2-week plan is two linked shops.

---

## Session 6 — short plans, and a floor that stops lying

Two owner-reported problems, both real, both worse than reported.

### Plans shorter than a week were impossible for a silly reason

`min_distinct_mains` was hardcoded at 5 and compared against however many main
meals the plan held. A 1-day plan holds two. So every 1- and 2-day request came
back `INFEASIBLE — min_distinct_mains`, which is not a preference failing, it is
arithmetic. The floor is now clamped to `min(requested, main_servings,
recipes_available)`. All six durations solve:

```
       spend   food eaten   cupboard   protein/day
 1d   £15.35        £3.06     £12.29          126g
 2d   £19.83        £5.87     £13.96          116g
 3d   £22.38        £8.77     £13.61          118g
 5d   £24.12       £16.22      £7.90          117g
 7d   £33.24       £21.95     £11.29          113g
14d   £44.00       £33.69     £10.31          101g
```

### The cost figures were misleading, and short plans made it obvious

**80% of a one-day shop is stock the shopper still owns tomorrow.** Reporting
`spend` alone reads as "£15 for one day" and makes the product look broken, when
the day's food actually cost £3.06. `Plan.consumed_value` (spend minus
cupboard) is now returned and shown alongside spend, cupboard and waste.

### The quoted minimum was a first-week number sold as a weekly one

The owner said people get by on far less than the £25 the app was quoting. Both
halves of that turned out to be true.

- £25 was Tesco on the `maintain` preset. The real Aldi floor is **£18.18 a
  week, £2.60 a day**.
- It **plateaus**. Dropping the protein target from 100g to 40g does not move it
  at all — below a point you stop paying for nutrition and start paying for
  packaging. That is the product's own thesis appearing as a hard floor.
- **41% of that £18.18 is stock still owned on day 8.** Run the same targets
  against a stocked cupboard and the week costs **£10.71, or £1.53 a day**.

So the app was quoting an empty-cupboard stock-up as if it were the ongoing
weekly cost. Two floors are now computed and shown per combination —
`floor_first` and `floor_ongoing` — and a budget under the first floor says so
usefully: *"Not possible from an empty cupboard. Once your cupboard is stocked
the same week costs about £8.91, so this budget works from your second shop on."*

A fourth preset, **Getting by** (55g protein, 1700–2400 kcal), sits below `cut`.

**Honest limit.** 28 items, no value ranges. Real budget shopping runs on 20p
noodles, value bread and yellow-sticker reductions. Those prices cannot be
invented, so the £18.18 floor is a *catalogue* limit, not a food-cost one. This
is the strongest argument yet for widening the catalogue with real observations.

Demo re-exported: 624 combinations, 6 durations, 4 goals. 40 tests.

---

## Next

- **Design pass with generated food imagery.** Priced: ~1.25 credits an image on
  `recraft_v4_1`, so ~24 for all 19 recipes; 50 credits covers style tests and
  redos. Owner's Higgs balance is currently 0.
- **The receipt test.** Still the gate on P2, still untouched.
- Calorie-dense snacks, to make `bulk` reachable.
- Still open: `WASTE_PENALTY` 1.5 -> 15, and the default objective.

---

## Session 7 — snacks, and the acceptance case that stopped holding

### The `snack` slot existed since migration 001 and was never used

That was why `bulk` was impossible at any budget: three meals a day of these
recipes tops out near 2400 kcal, and no amount of money adds a fourth. Migration
008 adds five snacks — peanut butter banana, cheese on toast, an oats and peanut
butter pot, yoghurt with banana, boiled eggs — all built from already-priced
items, all overlapping with what the mains already justify buying.

Two model changes went with them:

- `meal_slot == "snack"` is now its own slot. It was being lumped in with mains,
  because `mains` was defined as everything that is not breakfast.
- Snacks get a looser repeat allowance (`SNACK_REPEAT_MULTIPLIER`, default 4).
  Snack variety matters far less than meal variety, and without it `max_repeat`
  capped a fortnight at roughly one snack a day.

`bulk` at 140g protein still failed over 14 days, by 7g/day. The measured
ceiling is 133g, so the preset is **130g** — the number the catalogue supports,
not the one that sounds right. Bulk now solves at 1, 7 and 14 days
(£12.71 / £24.27 / £49.69 at Aldi).

### Snacks made everything else cheaper

Cheap calorie-dense snacks displace expensive meals, so the floors moved:

```
                before    after
aldi  maintain  £21.29   £19.38
tesco maintain  £25.89   £23.77
```

### This broke the KICKOFF §3 acceptance case, and that is worth saying plainly

KICKOFF §3 pins "Tesco, £25, 100g protein, 7 days -> infeasible". **£25 now
solves at Tesco**, because the Tesco floor fell to £23.77. That is the catalogue
improving, not a regression — but it is a documented acceptance case no longer
holding, so it is flagged rather than quietly edited away.

Four tests were rewritten to assert the *behaviour* against a floor measured at
runtime rather than a hardcoded price: a budget below the floor is infeasible,
names `budget`, reports the floor, and that floor is itself solvable. Aldi is
still asserted to undercut Tesco. The prototype-parity numbers (£24.94, £29.67)
are now historical — the recipe set has deliberately changed twice since.

**KICKOFF §3 should be updated** to describe the property rather than the price,
or the numbers will drift again the next time a recipe is added.

40 tests. Demo re-exported.

---

## Next

- **Design pass.** Recommended holding the image generation until the recipe set
  settled — it now has (19 -> 24 recipes). Style test first: ~3 credits for the
  same dish across two or three models, then ~24 for the set on `recraft_v4_1`.
- **The receipt test.** Still the gate on P2, still untouched.
- Still open: `WASTE_PENALTY` 1.5 -> 15, and the default objective.

---

## Session 8 — design pass, no credits spent

The owner's first complaint was that the demo is "basic text". This is the half
that costs nothing; generated food photography is still waiting on credits.

**The money split is now a chart, because it is the product's whole argument.**
Three numbers in a row did not say what they meant. One stacked bar — spend, cut
into food you eat / stays in the cupboard / wasted — makes the thing that
confused the owner obvious at a glance: a one-day plan is £16.70 at the till and
**79% of it is stock you still own tomorrow**.

Segment colours were run through the dataviz palette validator rather than
picked by eye, against both surfaces:

```
light  #2A5FA8 #1C7A57 #B0512A   lightness, chroma, normal-vision floor, contrast: PASS
dark   #5590D6 #35A87C #D0733F   all checks PASS (re-stepped for the dark surface,
                                 not an inverted copy)
```

The first two attempts failed outright — a neutral grey "eaten" tripped the
chroma floor and sat too close to the green for deutan vision. Identity never
rests on colour alone: every segment is named with its value and share in the
key, segments carry a 2px surface gap, and the bar has an `aria-label` spelling
out the whole split.

Also: meals are grouped under Breakfast / Main meals / Snacks with serving
counts, instead of one flat list.

**One bug worth recording.** The cost bar first rendered as a blank gap. The
class name `.bar` was already the phone's top bar, whose `align-items:center`
collapsed the segments to zero height — a pure cascade collision, invisible in
the source and obvious in the DOM. Renamed to `.costbar`, with a comment saying
why. Found by inspecting computed styles, not by reading the CSS.

---

## Next

- **Food photography.** Recipe set has settled at 24. ~3 credits for a style
  test across two or three models, ~24 for the set on `recraft_v4_1`; 50 covers
  redos. Owner's Higgs balance is 0.
- **The receipt test.** Still the gate on P2, still untouched. 28 prices, none
  yet checked against a till.
- **KICKOFF §3 needs updating** — its acceptance case now solves (Session 7).
- Still open: `WASTE_PENALTY` 1.5 -> 15, and the default objective.

---

## Session 9 — P2: the real app

`apps/web` was an untouched `create-next-app` scaffold. It is now the product:
the four onboarding screens from the owner's schematic, running against the live
solver rather than a static export.

**Shape**

```
app/api/solve/route.ts   POST -> solver /solve
app/api/floor/route.ts   POST -> solver /floor
lib/solver.ts            typed client; SOLVER_URL never reaches the browser
lib/goals.ts             the four presets, with the measured numbers
components/Planner.tsx   store -> length -> budget -> goal -> plan
components/CostSplit.tsx the stacked spend bar, same validated palette
```

Next 16 + React 19 + Tailwind v4, same palette and typography as the demo, so
they read as one product. Verified end to end in a browser against a live
Postgres and CBC: floor £19.38, plan £29.44, 19 basket rows, ticking items
updates the trolley total, both themes, production build clean, lint clean.

**New solver endpoint: `POST /floor`.** The budget screen has to know the floor
*before* anyone picks a number, and `/solve` only reveals it after failing.
Returns two figures, never one — `first` for an empty cupboard, `ongoing` for a
stocked one.

**Three bugs found by running it, not by reading it**

1. **`/solve` returned no `status` field.** The endpoint returned the plan
   dataclass directly, so a successful plan and an infeasible one were
   indistinguishable to a client — both are HTTP 200 by design. The header read
   "No plan" over a working plan. Now `{"status": "ok", ...}`.
2. **Next's dev server 403'd its own chunks on `127.0.0.1`.** The page rendered
   and never hydrated, so nothing responded to a click and there was no error to
   read. It is Next's dev-origin check; `allowedDevOrigins` now lists both
   spellings.
3. **"about £3.72 a one day".** `periodWord` was being string-mangled into a
   noun. Split into `periodWord` ("for the week") and `periodNoun` ("a week").

Also fixed a lint error rather than silencing it: the floor effect cleared state
synchronously, cascading renders. The floor is now stored with the request key
it belongs to, so a stale answer is derived away instead of cleared.

**Note on SPEC §6.** That section gates P2 on the receipt test, which is still
undone. Building the screens anyway is a deliberate call: the receipt test
invalidates *prices*, which are data, not the flow. The onboarding is identical
whether rice is 75p or 85p. It remains the highest-value outstanding task.

---

## Next

- **The receipt test.** 28 prices, none checked against a till.
- **Food photography** — 50 Higgs credits; the recipe set has settled at 24.
- Persistence: `user_prefs`, `plan`, `plan_basket_line` and `pantry_stock` all
  exist in the schema and nothing writes to them yet, so a plan is not saved and
  the cupboard does not carry between visits. That is P4.
- Still open: `WASTE_PENALTY` 1.5 -> 15, and the default objective.

---

## Session 10 — finishing up

- **Snack cooking steps.** Migration 008 added five snacks and left them without
  `method_md`, so the demo showed "No steps written yet" on a quarter of the
  recipes. Migration 009 fills them, through the same `app.method_check`
  validator — no quantities, no ingredient outside each recipe's own list. All
  five passed first time. **24 of 24 recipes now have steps.**
- **KICKOFF §3 rewritten to describe the property rather than a price.** Its
  original wording ("Tesco £25 → infeasible, Aldi ≈ £24.94") was exactly right
  when written and is now wrong in both halves, because migration 008 moved the
  floors. A test pinned to pounds fails on a catalogue improvement and passes on
  nothing useful.

---

# STATE OF THE PROJECT

## What exists and is verified

| | |
|---|---|
| Schema | 9 migrations, clean rebuild verified from empty |
| Catalogue | 28 items, 56 current prices, both stores |
| Recipes | 24 (12 main, 7 breakfast, 5 snack), all with cooking steps |
| Solver | FastAPI + PuLP/CBC. `/health`, `/solve`, `/floor`. 40 tests |
| App | Next 16 / React 19 / Tailwind v4, four screens on the live solver |
| Demo | 624 pre-solved combinations, published as an Artifact |

Every headline number in this repo came out of CBC. No figure was written by
hand, and no model is in the selection, pricing or quantity path.

## What the model does that a chatbot cannot

- Costs **whole packs**, so a 70g lentil recipe costs a 99p bag — which is what
  makes the solver find a second and third lentil meal to justify it.
- Splits leftovers into **carry-over** and **waste** by shelf life against the
  plan horizon, values the first as an asset and penalises the second.
- Treats pantry stock as free, so week 2 is materially cheaper than week 1.
- Answers **INFEASIBLE with the binding constraint named** and the cheapest
  feasible budget priced, via an elastic re-solve.

## The three numbers worth remembering

```
£18.18   cheapest possible week at Aldi, empty cupboard
£10.71   the same week with a stocked cupboard
  £3.06  what a one-day plan's food actually costs, out of a £15.35 shop
```

## Open — and honest about it

1. **THE RECEIPT TEST HAS NEVER BEEN DONE.** SPEC §6 makes it the honesty
   metric and the gate on P2. 28 seed prices, none checked against a till.
   `RECEIPTS.md` is waiting for row one. Everything else is downstream of this.
2. **Nothing is persisted.** `user_prefs`, `plan`, `plan_basket_line` and
   `pantry_stock` exist in the schema and nothing writes to them. A plan is not
   saved and the cupboard does not carry between visits — so the retention
   mechanic is proven in simulation but not lived. That is P4 and it is the
   biggest functional gap.
3. **The catalogue is the binding limit, not the solver.** 28 items, no value
   ranges. Real budget shopping runs on 20p noodles and yellow-sticker
   reductions. £18.18 is a *catalogue* floor. Those prices cannot be invented —
   they have to be observed.
4. **Salt, pepper and water are assumed** and are not priced items, so strictly
   the basket does not cover them.
5. **`carb_per_100` and `fat_per_100` are NULL for every item.** No fat or carb
   constraint is possible until sourced.
6. **`docker compose up` has never been run** — this environment cannot pull
   images. The compose file and solver Dockerfile are written but unexercised.
7. **Two decisions still open**: `WASTE_PENALTY` 1.5 → 15 (at 1.5 it provably
   changes nothing under the `protein` objective), and whether `protein` or
   `cheapest` ships as the default.
8. **Food photography** — ~50 Higgs credits. The recipe set has settled at 24,
   so images would be generated once.

## If you pick this up cold

Read `CLAUDE.md`, then `SPEC.md`, then this file's Session entries in order —
each one records what was measured and what was wrong. Run
`services/solver/scripts/simulate_weeks.py` to see the carry-over model working,
and `pytest` in `services/solver` before changing anything in the model.

---

## Session 11 — the two open decisions, settled with measurements

### Default objective: stays `protein`. I recommended `cheapest` and was wrong.

`cheapest` looked like the honest default for a budgeting app. Measured, it
breaks the product:

```
budget          cheapest              protein
   £20   £19.98 · 103g/day    £19.77 · 106g/day
   £25   £21.32 · 100g/day    £24.43 · 132g/day
   £30   £21.32 · 100g/day    £29.44 · 144g/day
   £40   £21.32 · 100g/day    £32.72 · 147g/day
   £60   £21.32 · 100g/day    £32.72 · 147g/day
```

Under `cheapest` every budget from £25 to £60 returns the **same** £21.32 plan.
The budget slider — the app's central input — would do nothing above the floor.
Under `protein` the budget does real work and then stops at £32.72 and hands the
rest back, which is the behaviour CLAUDE.md explicitly says to preserve.

`cheapest` stays available and is what `/floor` uses.

### `WASTE_PENALTY`: 50, not the 15 previously recommended.

The 15 figure was measured before migration 008 and is now a no-op. Re-measured
on the current 24-recipe catalogue (a fortnight at Aldi, £60):

```
penalty    spend    waste   protein/d
    1.5   £51.32    £2.91        134g
   15.0   £51.32    £2.91        134g    <- identical to 1.5 now
   50.0   £47.79    £1.58        132g    <- cheaper AND less waste
  100.0   £48.14    £1.43        131g
```

50 is the knee: £3.53 cheaper over a fortnight and nearly half the waste, for
2g/day of protein. It stops the solver buying mince, the single worst waster.
The table is in `config.py` with a note to re-measure it when the catalogue
changes — this is the second time a tuned constant has gone stale on new recipes.

4-week simulation, better on every axis than the 1.5 baseline:

```
        till spend   carried   wasted  protein/d
wk 1        £29.66     £8.48    £0.10       143g
wk 2        £25.22     £4.36    £0.57       146g
wk 3        £23.72     £4.87    £0.57       146g
wk 4        £22.73     £4.64    £0.57       146g
```

### Food photography: style test done, and a blocker found

Three models on the same dish (~3.4 of 80 credits): `recraft_v4_1`,
`nano_banana_pro`, `z_image`. Rendered for the owner to judge.

**This environment cannot download them.** The Higgsfield CDN
(`d8j0ntlcm91z4.cloudfront.net`) is blocked by the network policy — CONNECT
returns 403 — so generated images cannot be pulled into the repo, and I cannot
see them to judge quality myself. Consequences:

- The **artifact demo can never show them**: its CSP blocks external images and
  the files cannot be embedded from here.
- The **Next app can**, because the viewer's browser reaches the CDN even though
  this sandbox does not. So the route is: generate, store the URL against the
  recipe, and render it with `<img>` in `apps/web`.
- Or the owner downloads the set and commits the files, which is the only way
  the demo gets pictures.

Held the remaining ~30 credits rather than generating 24 images in a style
nobody has approved and I cannot inspect.

---

## Session 12 — photography

24 dish photos generated with **Recraft V4.1** (owner's pick from a three-model
style test), from a single brief: overhead, plain white crockery, pale wooden
worktop, natural window light, no garnish or styling. The point was that 24
dishes read as one set rather than 24 stock photos, and that they look like
Tuesday food rather than a magazine — a glossy photo would sit badly against a
product whose pitch is that the numbers are honest.

Migration 010 adds `recipe.image_url`; the solver returns it on each meal; the
app renders a 56px thumbnail per row. Images are **decoration** and nothing
more: CLAUDE.md rule 1 allows a model to make copy and imagery, and none of this
touches selection, pricing or quantities. A recipe without a photo renders
without one.

Credits: 80 → 46.60. About 3.4 on the style test, 30 on the set.

**Two things to know.**

1. **The images are CDN URLs, not files in this repo.** This sandbox cannot
   reach the Higgsfield CDN — CONNECT returns 403 — so they could not be
   downloaded and committed. If that account or CDN path rotates, every photo
   404s. The fix is to self-host them under `apps/web/public`, which needs
   someone who can actually fetch the files. Until then this is a real fragility,
   not a tidy-up.
2. **The artifact demo still has no photos and cannot have any**, because its
   CSP blocks external images and the files cannot be embedded from here. Photos
   are an `apps/web` feature only.

Verified: 24 of 24 recipes carry an image, the solver returns them, 10 `<img>`
tags render with correct URLs, and the layout reserves the space so it degrades
to neutral placeholders when the CDN is unreachable — which is exactly what it
does from this sandbox. **I have never seen these images.** Whether they are any
good is the owner's call.

---

## Session 13 — the photography is self-hosted, and the demo has pictures

All 24 photos now live in `apps/web/public/recipes`, 1.4MB total, named by
recipe slug. Migration 011 repoints `recipe.image_url` at `/recipes/<slug>.webp`
and asserts in SQL that no recipe is left on a CDN path, so a drifted slug fails
the migration rather than silently 404ing in the UI. `db/seed/recipe_images.py`
— the CDN mapping from migration 010 — is deleted.

This removes the fragility recorded last session. No expiring links, no
third-party dependency, and the repo owns its own assets.

**The demo has photography now**, which external URLs made impossible: an
Artifact's CSP blocks them outright. `demo/thumbs.py` centre-crops each photo to
160px (2× the 56px it renders at, so it stays sharp on a retina screen) and
inlines them as data URIs — 24 images for 92KB, against a 2.7MB page.

**Two identification calls worth recording**, since four of the recipes are
near-identical bowls:

- `yogpb` was assigned early off a creamy base under the oats. When `oatpb`
  (oats + peanut butter, no yoghurt) and `yogbanana` (yoghurt + oats, no peanut
  butter) arrived, they confirmed it: `yogpb` is the only one with both.
- The dahl was swapped mid-set. The first was on warm beige wood while every
  other shot is pale painted wood; one odd surface undoes the point of shooting
  to a single brief. Rejected crops are parked in scratch, not deleted.

Verified: 24 of 24 on local paths, all 10 thumbnails on a rendered plan report
`naturalWidth > 0` in both the app and the demo, both themes, no console errors.

**I still have not judged whether the photographs are good.** I can see them now
that they are local files, and they read as one coherent set — but whether they
sell the product is the owner's call, not mine.

---

## Session 14 — DESIGN.md

The owner pointed at [awesome-claude-design](https://github.com/VoltAgent/awesome-claude-design),
a curated set of `DESIGN.md` files. The useful idea in it is the file format
rather than the collection: **token, rule and rationale in one place**. A Figma
export says what to use but not why; a brand PDF says why but too loosely for an
agent to act on. This project had `CLAUDE.md` for how to build and nothing at all
for how it should look, so every visual decision so far has lived only in commit
messages.

`DESIGN.md` now sits at the root, written to that repo's nine-section shape but
**original to this product** — its own disclaimer is explicit that the curated
files are inspiration, not systems to clone, and copying another company's
visual identity would be wrong regardless.

Nothing in it is aspirational. Every token, size and rule is already in
`apps/web/app/globals.css` or `demo/template.html`; the file is the reasoning
that was missing, including the parts learned the hard way:

- the cost-split colours are **computed, not chosen**, with the note that two
  earlier attempts failed the validator and that they must not be nudged by eye;
- dark mode is re-stepped per surface, never inverted, and no colour may be
  defined only inside a media or `[data-theme]` block;
- generic class names are a hazard — `.bar` collided with the phone's top bar and
  silently collapsed the cost bar to zero height;
- the central rule that falls out of the product itself: **show two numbers where
  one would mislead**, because a single figure is precisely how this app lies.

Next: this can be fed to Claude Design (claude.ai/design) to scaffold a fuller
component kit, or used as-is as the guardrail for new screens.

---

## Session 15 — UX audit against `ui-ux-pro-max-skill`, and two real bugs

The second design repo, `nextlevelbuilder/ui-ux-pro-max-skill`, ships a
119-row guideline table. Its palette and font catalogues were **not** adopted —
Till Total already has a validated palette and a deliberate anti-glossy stance,
and swapping either would undo work that was measured. What is worth having is
the 45 critical/high web rows used as an audit checklist against the running
app, which is what this session did.

**Already passing, verified in a real browser rather than asserted:** viewport
meta and `lang="en-GB"`; text contrast (screen sub 5.58:1 at 13.5px, heading
17.64:1 at 23px, choice detail 4.86:1 at 12.5px — all AA); smallest rendered
text 11px and only on eyebrow labels; no horizontal overflow at 320/375/414px,
nor at a 195px viewport (the 200%-zoom reflow case); a visible 2px focus ring on
the first tab stop; no interactive target under 24px on any screen — the
shopping-list checkbox is 15px but its target is the 308×63px row label.

**One checklist item was a false positive.** The dish photos carry no intrinsic
`width`/`height`, which the guideline flags for layout shift. Measured with every
photo delayed 1.5s: **CLS 0.000**. Tailwind's `w-14 h-14` already reserves the
box, and the no-photo case renders a same-sized placeholder. No change made —
adding the attributes would have been cargo cult.

**Two genuine bugs, both found by the audit walking the flow rather than by
reading it:**

1. *The app hard-crashed to an error boundary whenever the solver was down.*
   `/api/floor` returns `{status:"error", detail}` with a 502, and the client
   parsed that body straight into a `Floor`. `first` was then `undefined`, not
   `null`, so the `floor.first === null` guard fell through to `money(undefined)`
   → `Cannot read properties of undefined (reading 'toFixed')` → white screen.
   Found because Postgres was not running in this container, which is exactly
   the condition the code was worst at. Fixed at the boundary: a `SolverError`
   type, narrowing on shape (`"first" in value`) before storing, and a third
   state — *asked and failed* — distinct from *not asked yet*, so the budget
   screen says "the floor could not be worked out… any number you pick here is a
   guess" instead of "working out the floor…" forever. `buildPlan` had the same
   class of bug: a 502 body would have been rendered as an infeasible plan with
   every field undefined.

2. *The meal and shopping lists were sliced flat at their 430px cap.* A row cut
   mid-height reads as the end of the list — there was nothing to say more
   existed. Both panes now go through a `Scroller` that fades its bottom 26px
   **only while there is more below**, and carries a `tabIndex` and label so a
   keyboard can reach the scroll (WCAG 2.1.1). Measured on scroll, not in an
   effect, because the effect version trips `react-hooks/set-state-in-effect`.

Both lessons are written into `DESIGN.md` §7 and §8 so the next screen inherits
them. `next build`, `eslint` and `tsc` clean; 40 solver tests pass.

Still open, unchanged: **the receipt test** (SPEC §6, the gate on P2 — 28 seed
prices, none yet checked against a till, `RECEIPTS.md` still empty), persistence
(P4), the NULL `carb_per_100`/`fat_per_100` columns, and `docker compose up`,
which has never been verified because the image registry CDN is blocked here.

---

## Session 16 — The interface, rebuilt

Roo's verdict on the old UI: *"I don't like the sliders, text, entire page to be
honest it's bad colours and poor design. It screams ai."* He was right, and it is
worth writing down exactly what was doing it, because none of it was subtle:

- **A sage-green wellness palette.** Soft off-white ground, grey-green surfaces,
  one amber accent. That specific combination is the default look of
  machine-generated pages.
- **26px radii and a blurred drop shadow** under a floating card.
- **Essayistic sub-copy under every heading** — two-line explanations of what the
  screen was for, em-dashes throughout, three "here's why this is clever" cards
  down the side.
- **Two generic HTML range sliders**, which he had already objected to twice.

The worst of it: `DESIGN.md` §1 has said "a shelf-edge ticket, not a food
magazine" since it was written. The file described one product and the pixels
rendered a different one. The redesign is not a new direction — it is finally
building the one already written down.

**What it is now.** Paper white on card grey, near-black ink, hairline rules,
square corners, no shadow anywhere, and one saturated price-flash yellow that
only ever means *this one is selected*. Archivo loaded as a variable font with
its **width axis**, so every price is set condensed and heavy the way a shelf
ticket is printed; IBM Plex Mono keeps the receipt data. Aisle headings and slot
headings are reversed-out black bars. Copy is cut to signage length.

**The sliders are gone, and not for taste.** A slider has to invent a range
before the floor is known, and its two ends are a claim about what is possible
that the solver has not made. That is precisely how the old build came to tell
people the minimum was £25 when Aldi's measured floor is £19.38 — and Roo's
third complaint, *"people get by on much less"*, was a complaint about a control
lying. Length is now six discrete chips. Budget is a **keypad**: you punch in a
number the way you would at a till, it accepts anything, and the floor note —
which comes from a real solve — does the arguing. £12 is now a thing you can
type; it turns the note red and tells you the cheapest first shop is £19.38.

**Verified rather than assumed:**
- The Google Fonts stylesheet **did not load** on the first render, so the
  condensed numerals were silently falling back to a normal-width system face
  and the whole type idea was inert. Caught by measuring the rendered width of
  the masthead (151px fallback vs 116.6px real). Both faces are now self-hosted:
  inlined woff2 data URIs in the demo, `next/font` with `axes: ["wdth"]` in the
  app.
- Smallest rendered text had slipped to **9.5px**. Raised to a 10.5px floor
  across every mono label and 11px on the chip units.
- Contrast measured in the DOM: 7.54:1 on the muted mono roles, 19.8:1 on
  headings, 13.1:1 on the masthead sub. No target under 24px. No horizontal
  overflow at 320 / 360 / 414px.
- Dark mode re-stepped and shot at phone width, not inverted.
- The cost-split segments are **unchanged** — the surface they sit on is still
  white — so the validated palette still holds and was not re-eyeballed.

`apps/web/app/globals.css` is now generated from `demo/template.html`'s style
block, so the shipped app and the demo carry literally the same rules and cannot
drift. `DESIGN.md` is rewritten to match what is actually on screen.

`next build`, `eslint` and `tsc` clean.

Still open, unchanged: **the receipt test** (SPEC §6, the gate on P2 — 28 seed
prices, none yet checked against a till), persistence (P4), the NULL
`carb_per_100`/`fat_per_100` columns, and `docker compose up`.

---

## Session 17 — Correcting the over-correction

Session 16's redesign was wrong in the opposite direction. Roo, on seeing it on
his phone: *"Is too blocky, weird colours. Weird stuff at the bottom when u
scroll down. It's missing sliders."* Four complaints, all fair, all fixed:

1. **Too blocky.** Hard 1.5px black borders on everything, reversed-out black
   bars for every heading, a full-bleed black masthead. Now: light paper, 1px
   hairlines, 11–14px radii, and light `--paper-2` chips where the black slabs
   were. Fixing "it looks AI-generated" by making it shout is not fixing it.
2. **Weird colours.** The saturated price-flash yellow is gone.
3. **Weird stuff at the bottom.** On a phone the two proof panels stacked under
   the app as a wall of black-barred text with no obvious job. They are now a
   single `<details>`, collapsed.
4. **Missing sliders.** They are back.

**On the sliders specifically — I was wrong and said so.** I removed them
arguing that a slider's two ends are a claim about what is possible that the
solver has not made. That reasoning was fine; the conclusion was not. The
problem was never the control, it was the *range*: the old build started it at
£25 and implied that was the minimum. The range now runs from half the measured
floor to two and a half times it, so at Aldi it spans **£10 to £48** and a £10
budget is reachable — it simply comes back infeasible with the real floor
attached. The measured floor is drawn as a **pin on the track**, because it is a
solved number and belongs on the control rather than only in a sentence
underneath. That answers his original "people get by on much less" complaint
better than the keypad did.

**The colour is not settled, and I stopped guessing.** Two attempts, two
rejections. `demo/template.html` now carries a **palette picker** — green, blue,
orange, violet — that repaints the whole app at a tap and remembers the choice.
It is a decision aid, not a feature: once he picks one, the picker comes out.
`apps/web` ships only the default green.

Re-verified after the rework: no horizontal overflow at 320 / 360 / 414px,
smallest rendered text 10.5px, contrast 6.11:1 on the muted mono roles and
17.77:1 on headings, no touch target under 24px, dark mode re-stepped, no page
errors through the whole flow in either the demo or the app. The cost-split
segments are still the validated set — the surface under them is still white,
so they hold. `next build`, `eslint` and `tsc` clean.

`DESIGN.md` §1 now records **both** failed passes, because the pair of them is
the useful lesson: the sage wellness app and the brutalist over-correction are
two ways of missing the same target. The landing point is between them — quiet
surface, loud numbers.

Still open, unchanged: **the receipt test** (SPEC §6, the gate on P2),
persistence (P4), the NULL `carb_per_100`/`fat_per_100` columns, and
`docker compose up`.
