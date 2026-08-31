# RECEIPTS.md — the honesty metric

**Projected cost vs actual till receipt.** SPEC §6 and KICKOFF both name this as
the one number that matters, tracked in the repo from day one. This file is that
tracker. It is empty because no plan has been shopped yet — P2 is gated on the
first entry.

Rule from SPEC §6: if projected vs actual is more than ~8% out, price accuracy
becomes the priority over every feature in P2–P5.

## Method

1. Generate a plan. Record `plan.id`, store, and `projected_cost`.
2. Do the shop. Keep the receipt.
3. Compare line by line against `plan_basket_line`.
4. Record the row below, and write `actual_cost` back to the `plan` row.

## Log

| Date | Store | Plan | Projected | Actual | Δ | Mispriced | Out of stock | Notes |
|---|---|---|---|---|---|---|---|---|
| _(none yet)_ | | | | | | | | |

## Running accuracy

- Shops recorded: **0**
- Mean absolute error: **—**
- Worst single week: **—**
