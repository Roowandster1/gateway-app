# CLAUDE.md

Project context. Read this before doing anything.

---

## What this is

A meal planning app where the user inputs **a weekly budget** and **a supermarket**,
and gets back a **full week of meals plus a shopping list that actually costs that
much at the till**.

Currently supports **Aldi** and **Tesco** (UK). More stores later.

## The one idea that matters

**Food is sold in packs, not grams.**

Every other meal planner prices a recipe by multiplying grams by a per-100g cost.
That is fiction. If a recipe needs 70g of lentils, you do not buy 70g of lentils.
You buy a 500g bag for 99p. If nothing else that week uses lentils, you have spent
99p to use 14% of a bag.

So the core problem is **not** recipe selection. It is a constrained optimisation:

> Choose a set of meals that hits the nutrition floor and stays under budget,
> where cost is computed over **whole packs bought**, not grams consumed.

This constraint is what forces ingredient reuse. It is emergent, not scripted:
the solver buys one bag of lentils and then finds three lentil meals to justify it,
because that is cheaper than buying a second protein source.

**This is the entire moat.** An LLM asked to "plan cheap meals" cannot do it —
it has no mechanism to reason about integer pack purchases against a budget.

## HARD RULES — do not violate

1. **Never replace the solver with an LLM call.** If you find yourself writing a
   prompt that asks a model to "generate a meal plan under £30", stop. That is the
   product being thrown away. The optimiser is deterministic maths (integer
   programming, CBC via PuLP). LLMs may be used for *copy* — recipe descriptions,
   cooking steps, tone — never for selection, pricing, or quantities.
2. **Never price by per-gram cost.** Always integer packs. If a UI needs a per-gram
   figure it is derived for display only and never feeds the optimiser.
3. **Never invent prices.** Every price in the DB has a `source` and `updated_at`.
   Unknown price = item is excluded from planning, not guessed.
4. **The plan must be executable.** If the solver returns a basket, a human must be
   able to walk into that store and buy exactly those packs for approximately that
   money. Any feature that breaks this is not shipped.
5. **Nutrition floors are constraints, not suggestions.** A plan that comes in
   under budget by starving the user is a failed plan, and the solver must return
   INFEASIBLE rather than a weak plan. "Your budget doesn't work at this store" is
   a legitimate and valuable answer.

## Domain knowledge you will not guess correctly

### Carry-over vs waste
Leftover ingredient is **two different things** and conflating them makes the
numbers lie:

- **Carry-over (staples):** rice, oats, oil, pasta, spices, tinned goods. Long
  shelf life. Leftovers are an **asset** — they make next week cheaper. This is the
  app's retention mechanic: week 2 costs materially less than week 1 because the
  cupboard is already stocked.
- **Waste (perishables):** fresh veg, dairy, meat, bread. Leftovers **rot**. This
  is a real cost and the optimiser must be penalised for creating it.

The v1 prototype conflated these and reported ~7kg "leftover" per week, which was
alarming and wrong — most of it was rice and oil. **Fixing this is the first real
build task.** See `SPEC.md` §3.

### The pantry ledger
Because staples carry over, the solver must accept a **starting pantry** and treat
those quantities as free. A user in week 4 should have a very different (cheaper)
basket than a user in week 1 with an empty cupboard. Without this, the app feels
broken to a returning user — it keeps telling them to buy rice they already own.

### Price staleness
Supermarkets have no public price API and scraping them is an arms race we will
lose. The strategy is deliberate:
- Seed the catalogue with real observed prices, timestamped.
- Let the user correct any price in **two taps** while standing in the aisle.
- Corrections are the data moat. Accuracy improves with usage.
- Show price confidence in the UI (fresh / ageing / stale). Never hide it.

Do not build a scraper without an explicit decision from the owner.

### Objective function subtlety
The prototype maximised `protein - 0.5 * cost` under a budget cap. This produced a
genuinely interesting behaviour: **given £40 it only spent £32.96**, because the
remaining £7 bought nothing worth having. Preserve this. An app that hands money
back is a real differentiator. Do not "fix" it by forcing full budget spend.

## Stack

- **Solver service:** Python + FastAPI + PuLP (CBC). Deployed separately.
- **App:** Next.js (App Router) + TypeScript + Tailwind.
- **DB:** Postgres (Supabase — also gives auth for free).
- **Hosting:** Vercel for the app, Railway for the solver service.

Rationale: the solver stays in Python because PuLP/CBC is mature and the model is
already written and proven. Do not port it to a JS LP library to "keep one
language" — that trades a working core for tidiness.

## Owner

Reuben (Roo), UK. Building this for his own use first, product second. Prefers
direct feedback and concrete options. Tell him when something is a bad idea.

## Definition of done for any feature

- The plan it produces is still buyable at the till.
- Prices used are timestamped and sourced.
- INFEASIBLE is handled and explained in plain English, never swallowed.
- No LLM is in the selection or pricing path.
