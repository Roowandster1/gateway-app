# KICKOFF.md — how to run this in Claude Code

---

## Setup (do this once)

```bash
mkdir pantry && cd pantry
git init
# drop CLAUDE.md, SPEC.md and prototype/ (solver.py, catalogue.py, run.py) in the root
claude
```

`CLAUDE.md` is picked up automatically at the start of every session. That is why
the domain knowledge lives there and not in a prompt you have to remember.

---

## Session 1 — scaffold

> Read CLAUDE.md and SPEC.md. The prototype in `prototype/` is a working proof of
> the core optimiser — treat it as the source of truth for the model, not for code
> style.
>
> Set up P0: monorepo with `apps/web` (Next.js, TypeScript, Tailwind) and
> `services/solver` (FastAPI, PuLP). Postgres schema per SPEC §1 as SQL migrations.
> Port the catalogue and recipes out of `prototype/catalogue.py` into seed
> migrations, adding the `keeps` and `shelf_life_days` columns — classify every
> item yourself and show me the classification for review before you commit it.
>
> Don't build any UI yet. Stop when `docker compose up` gives me a database with
> seeded items priced at both stores, and a solver service that responds to
> `/health`.

---

## Session 2 — the carry-over model (the important one)

> Implement SPEC §3 in `services/solver`. Port the model from
> `prototype/solver.py`, then add: pantry subtraction, staple/perishable leftover
> split, and the revised objective with CARRY_VALUE and WASTE_PENALTY as named
> constants in one config module.
>
> Then write the acceptance test from §3(e): simulate 4 consecutive weeks for one
> user, carrying the pantry forward each week. Print cost per week. Show me the
> numbers before we go further.
>
> If week 2 is not cheaper than week 1, do not work around it — tell me and we
> diagnose the model together.

---

## Session 3 — infeasibility as a feature

> Implement the structured INFEASIBLE response from SPEC §2: when no plan exists,
> identify the binding constraint and re-solve with budget as the objective to find
> the cheapest feasible week. Return both.
>
> Test case that must work: the property, not a price. A budget below the measured
> floor at a store must come back infeasible, name `budget` as the binding
> constraint, report the minimum feasible budget, and that reported figure must
> itself solve. Aldi must undercut Tesco at the same targets.
>
> **Do not pin these to fixed pounds.** The original wording said "Tesco, £25 →
> infeasible, Aldi ≈ £24.94". Both held exactly when written and both are now
> wrong: migration 008's snacks dropped the Tesco floor to £23.77, so £25 solves
> there. Every recipe added moves the floors, so a test pinned to a price fails on
> a catalogue improvement and passes on nothing useful. Measure the floor at
> runtime and assert against that.

---

## Sessions 4+ — follow SPEC §5

One phase per session. At the end of each, ask for a short summary of what changed
and what the next session should pick up, and append it to a `PROGRESS.md`.

---

## Standing instructions worth pasting when relevant

**When it starts reaching for an LLM:**
> The optimiser is deterministic. If you're about to call a model to choose meals,
> price something, or decide quantities, stop and tell me why the constraint model
> can't do it.

**When it starts guessing prices:**
> Don't invent a price. If we don't have a sourced price for an item, exclude the
> item from planning and log it as a catalogue gap.

**When a plan looks too good:**
> Verify by hand: multiply packs by unit price and check it against the reported
> total, and confirm every recipe's ingredient demand is covered by the packs
> bought. Show the arithmetic.

**Before any refactor of the solver:**
> Before changing the model, run the 4-week simulation and save the output. After
> the change, run it again and diff. Any movement in cost or macros needs
> explaining.

---

## Things to resist (they will feel tempting)

- **Adding stores early.** Two stores priced accurately beats six priced badly.
  Every extra store multiplies the price-maintenance problem.
- **Scraping supermarket sites.** It breaks constantly and puts you on the wrong
  side of their terms. The correction loop is the strategy — commit to it.
- **A recipe database of 500 meals.** 40 good, well-tagged, cheap recipes with
  strong ingredient overlap will beat 500 scraped ones, because overlap is what the
  optimiser trades on. More recipes with poor overlap makes plans *worse*.
- **Making it social.** Not yet. It's a utility. Earn daily use first.
- **Building the mobile app.** PWA first. If you're using it weekly and so are
  twenty other people, then consider native.

---

## The one metric that matters

**Projected cost vs actual till receipt.** Track it from week one, in the repo.
Everything else — screens, features, stores — is downstream of whether the number
on the phone matches the number on the receipt. If that holds, you have a product
nobody else has. If it doesn't, nothing else you build will save it.
