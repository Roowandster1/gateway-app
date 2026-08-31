# SPEC.md — build specification

---

## 1. Data model (Postgres)

```sql
-- Stores -------------------------------------------------------------
store(id, slug, name, country)                      -- 'aldi', 'tesco'

-- Catalogue ----------------------------------------------------------
item(
  id, slug, name, unit,                             -- 'g' | 'ml' | 'unit'
  aisle,                                            -- for shopping list ordering
  kcal_per_100, protein_per_100, carb_per_100, fat_per_100,
  keeps,                                            -- 'staple' | 'perishable'
  shelf_life_days,                                  -- null for staples
  category                                          -- protein/carb/veg/dairy/flavour
)

item_price(
  id, item_id, store_id,
  pack_size numeric, price numeric,
  source,                                           -- 'seed' | 'user' | 'receipt'
  observed_at timestamptz,
  reported_by uuid null,
  is_current boolean                                -- one current row per item+store
)
-- Never UPDATE a price. Insert a new row, flip is_current. Full price history
-- is the dataset that makes this defensible.

-- Recipes ------------------------------------------------------------
recipe(id, slug, name, minutes, meal_slot, method_md, serves_base)
      -- meal_slot: 'breakfast' | 'main' | 'snack'
recipe_ingredient(recipe_id, item_id, qty_per_serving, optional bool)
recipe_tag(recipe_id, tag)                          -- 'vegetarian','one-pot','no-oven'

-- Users --------------------------------------------------------------
app_user(id, email, created_at)
user_prefs(
  user_id, store_id, weekly_budget, household_size, days_per_plan,
  meals_per_day, kcal_target, protein_target, max_cook_minutes,
  dietary_tags[], excluded_item_ids[], excluded_recipe_ids[]
)

-- The pantry ledger (retention mechanic) -----------------------------
pantry_stock(user_id, item_id, qty_remaining, updated_at)

-- Plans --------------------------------------------------------------
plan(id, user_id, store_id, week_start, budget, status,
     projected_cost, actual_cost, protein_per_day, kcal_per_day, created_at)
plan_meal(plan_id, recipe_id, servings, day_index null, slot)
plan_basket_line(plan_id, item_id, packs, pack_size, unit_price,
                 qty_used, qty_carry_over, qty_wasted)
```

---

## 2. Solver contract

`POST /solve` (FastAPI service)

```jsonc
{
  "store": "aldi",
  "budget": 30.00,
  "days": 7,
  "meals_per_day": 3,
  "household_size": 1,
  "min_protein_per_day": 100,
  "kcal_band": [2000, 2700],
  "max_cook_minutes_per_day": 75,
  "max_repeat": 3,
  "min_distinct_mains": 5,
  "pantry": { "rice": 550, "oats": 710, "oil": 876 },   // free stock
  "exclude_items": ["mince"],
  "exclude_recipes": [],
  "objective": "protein" | "cheapest" | "variety"
}
```

Response: chosen meals with servings, basket lines with packs + cost, per-day
macros, **and a `carry_over` / `waste` split** (see §3). On failure return a
structured `INFEASIBLE` with the binding constraint identified — e.g.
`{"status":"infeasible","binding":"min_protein_per_day","suggestion":"£26.40 is the
cheapest feasible week at Tesco for these targets"}`. Compute that suggestion by
re-solving with the budget as the objective. This "your budget does not exist at
this store" answer is a headline feature, not an error path.

---

## 3. FIRST BUILD TASK — fix the carry-over model

The prototype's leftover figure is misleading. Fix as follows.

**a. Classify every item** with `keeps` = `staple` | `perishable`.

**b. Subtract pantry stock.** For item *i*, required purchase is
`max(0, used_i - pantry_i)`, and packs are computed on that remainder. Pantry
quantities cost nothing.

**c. Split leftovers in the output.**
- `qty_carry_over` = leftover of a **staple** → written back to `pantry_stock`.
- `qty_wasted` = leftover of a **perishable** → real waste.

**d. Change the objective** to value staple leftovers as an asset and punish
perishable waste:

```
minimise:  pack_cost
         - CARRY_VALUE * Σ(staple leftover × unit_cost)      # asset, recover ~70%
         + WASTE_PENALTY * Σ(perishable leftover × unit_cost) # dead money, ×1.5
```

Start with `CARRY_VALUE = 0.7`, `WASTE_PENALTY = 1.5`. Both must be tunable
constants in one place, not scattered magic numbers.

**e. Report two numbers to the user,** never one:
`Spend this week £29.67 · Cupboard value carried forward £4.10 · Wasted £0.35`

**Acceptance test:** simulate 4 consecutive weeks for the same user with pantry
carried between them. Week 2+ must cost measurably less than week 1 at the same
nutrition. If it does not, the pantry logic is wrong.

---

## 4. Screens (v1)

1. **Onboarding** — budget, store, household size, days, dietary tags, cook-time
   ceiling. Four taps max.
2. **The Plan** — the week. Meals with macros, cook time, servings. Swap any single
   meal → **re-solve with that meal pinned out** (never patch the plan client-side;
   a swap changes the basket and must go back through the optimiser).
3. **Shopping list** — grouped by aisle, packs and pack sizes explicit, running
   total. Tick items off. **Long-press any price to correct it** → new `item_price`
   row → optionally re-solve.
4. **Cupboard** — the pantry ledger. Editable. Shows what carried over and what it
   unlocks next week.
5. **Compare stores** — same targets, both stores, side by side. Include the
   INFEASIBLE case explicitly: "Tesco can't do this week for £25. Aldi can, at
   £24.94."

---

## 5. Build phases

| Phase | Deliverable | Done when |
|---|---|---|
| **P0** | Repo, schema, seed catalogue + recipes migrated from the prototype | `select` returns 25+ items priced at both stores |
| **P1** | Solver service with pantry + carry-over model (§3) | 4-week simulation shows declining cost |
| **P2** | Next.js app: onboarding → plan → shopping list | A real shop can be done from the phone |
| **P3** | Price correction loop + confidence display | A corrected price changes the next plan |
| **P4** | Cupboard screen + week-over-week continuity | Returning user is not told to rebuy rice |
| **P5** | Auth, PWA install, plan history, store comparison | Usable daily without a laptop |

**Do P1 before any UI.** If the carry-over model doesn't work the product doesn't
exist, and every screen built on top of it would need rewriting.

---

## 6. Validation before P2 — the receipt test

Take one generated £30 Aldi plan. Do the actual shop. Keep the receipt. Compare
line by line against `plan_basket_line`.

Record: how many items were mispriced, how many were out of stock, what the real
total was. **This number is the product's honesty metric** and should be tracked in
the repo from day one. If projected vs actual is more than ~8% out, price accuracy
is the priority over every feature in P2–P5.

---

## 7. Known open problems (do not paper over)

- **Out of stock.** The plan assumes availability. Needs a "substitute this" flow
  that re-solves with the item excluded.
- **Multi-buy offers.** 3-for-£10 style deals break the linear cost model. They can
  be modelled as extra binary variables but add real complexity. Defer, and log a
  decision when it's taken on.
- **Household scaling.** Scaling servings is not linear with pack sizes — a family
  of 4 wastes proportionally less. Handle explicitly, don't just multiply.
- **Palatability.** The optimiser has no taste. Nothing stops it serving dahl three
  times. `min_distinct_mains` and `max_repeat` are blunt instruments; a per-user
  "I'm sick of this" signal should feed back into constraints.
- **Nutrition beyond protein and calories.** Fibre, micronutrients, saturated fat.
  Adding them is easy (more constraints) but each one shrinks the feasible set and
  may push budgets up. Add deliberately, measure the cost of each.
