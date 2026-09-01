import type { PlanMeal, Slot } from "./solver";

/**
 * Turn what the solver bought into a week you can cook.
 *
 * The solver answers with servings, not days: "Bean toast × 3, Bean wrap × 2,
 * Egg wrap × 2". That is the right answer to the question it was asked — the
 * whole model is about packs and totals, and nothing in it has an opinion about
 * Tuesday. But the app's promise is "a full week of meals", and a frequency
 * table is not a week. This lays those servings out across the days.
 *
 * It is arrangement, not selection. Every serving the solver bought appears
 * exactly once and nothing is added, dropped or re-costed — the basket and the
 * total are untouched by anything in here. CLAUDE.md rule 1 is about what
 * chooses the meals; this runs strictly after that choice is made.
 */

export type SlotKey = Slot;

export interface Sitting {
  slot: SlotKey;
  meal: PlanMeal;
  /** Distinguishes the two mains in a day, so React keys stay stable. */
  index: number;
}

export interface Day {
  /** 1-based, matching the "Day 3" the screen shows. */
  n: number;
  sittings: Sitting[];
}

const SLOT_ORDER: SlotKey[] = ["breakfast", "main", "snack"];

/**
 * Spread one slot's servings so the same dish does not land on consecutive days.
 *
 * Dealing each recipe out in a block — three bean toasts, then two egg wraps —
 * is what makes a cheap plan feel like a punishment, and it is a presentation
 * choice rather than anything the solver decided.
 *
 * The obvious greedy, "take one from whichever dish has the most left", does
 * not work: with three bean toasts against four singles it takes toast, toast,
 * toast, because toast is still the largest pile after each pick. Verified in
 * the browser doing exactly that on days one and two.
 *
 * So each dish is spread over the whole span instead, and the spans are then
 * merged. A dish with k servings across n days sits at (i + 0.5) * n / k — the
 * midpoints of k equal stretches — which puts three toasts near days 1, 4 and 6
 * whatever else is in the plan. Sorting all the servings by that position
 * interleaves the dishes without any dish having to know about the others.
 *
 * Ties break on the recipe slug, so the same plan always produces the same
 * week. A plan that reshuffled itself on every render would be unusable as
 * something to shop and cook against.
 */
function deal(meals: PlanMeal[]): PlanMeal[] {
  const span = meals.reduce((a, m) => a + m.servings, 0);
  return meals
    .flatMap((m) =>
      Array.from({ length: m.servings }, (_, i) => ({
        meal: m,
        at: ((i + 0.5) * span) / m.servings,
      })),
    )
    .sort((a, b) => a.at - b.at || a.meal.recipe.localeCompare(b.meal.recipe))
    .map((x) => x.meal);
}

export function layOutWeek(meals: PlanMeal[], days: number): Day[] {
  if (days < 1) return [];

  const week: Day[] = Array.from({ length: days }, (_, i) => ({
    n: i + 1,
    sittings: [],
  }));

  for (const slot of SLOT_ORDER) {
    const queue = deal(meals.filter((m) => m.slot === slot));
    // How many of this slot each day gets. Twelve snacks over seven days is
    // 2,2,2,1,2,2,1 — not ceil(12/7) on every day, which fills the first six
    // and leaves day seven with none. Every serving is placed and the remainder
    // is spread rather than dumped on one end.
    let taken = 0;
    for (let d = 0; d < days; d++) {
      const upto = Math.floor(((d + 1) * queue.length) / days);
      for (let i = 0; taken < upto; i++, taken++) {
        week[d].sittings.push({ slot, meal: queue[taken], index: i });
      }
    }
  }
  return balance(week);
}

/** Dishes on a day, for the "not twice in one day, not two days running" guards. */
const namesOn = (d: Day) => d.sittings.map((x) => x.meal.recipe);

/**
 * Even out the days, without undoing the spread.
 *
 * Spreading each dish across the week takes no view of portion size, and the
 * big-portion mains are twice the calories of a small one — so a purely
 * positional layout produced a 2094 kcal day next to a 3034 kcal one. Both
 * average out, and the note under the week says the targets are plan-wide, but
 * a 900 kcal swing between neighbouring days is a bad week however you label it.
 *
 * So: swap two sittings of the same slot between two days whenever it moves
 * both closer to the mean. Rejected if it would put the same dish twice in one
 * day, or land it on two days running — the spread is the point and this is not
 * allowed to trade it away for arithmetic.
 *
 * Deterministic: fixed iteration order, no randomness, and it only ever accepts
 * a strict improvement, so it terminates and the same plan always lays out the
 * same way.
 */
function balance(week: Day[]): Day[] {
  if (week.length < 2) return week;
  const mean = week.reduce((a, d) => a + kcalIn(d), 0) / week.length;
  const cost = (d: Day) => Math.abs(kcalIn(d) - mean);

  const adjacentRepeat = (at: number, recipe: string) =>
    [at - 1, at + 1].some((k) => week[k] && namesOn(week[k]).includes(recipe));

  for (let pass = 0; pass < 4; pass++) {
    let moved = false;
    for (let i = 0; i < week.length; i++) {
      for (let j = i + 1; j < week.length; j++) {
        for (let a = 0; a < week[i].sittings.length; a++) {
          for (let b = 0; b < week[j].sittings.length; b++) {
            const x = week[i].sittings[a];
            const y = week[j].sittings[b];
            if (x.slot !== y.slot || x.meal.recipe === y.meal.recipe) continue;
            const before = cost(week[i]) + cost(week[j]);
            week[i].sittings[a] = y;
            week[j].sittings[b] = x;
            const clash =
              namesOn(week[i]).filter((r) => r === y.meal.recipe).length > 1 ||
              namesOn(week[j]).filter((r) => r === x.meal.recipe).length > 1 ||
              adjacentRepeat(i, y.meal.recipe) ||
              adjacentRepeat(j, x.meal.recipe);
            if (clash || cost(week[i]) + cost(week[j]) >= before) {
              week[i].sittings[a] = x;
              week[j].sittings[b] = y;
            } else {
              moved = true;
            }
          }
        }
      }
    }
    if (!moved) break;
  }
  return week;
}

/**
 * Collapse a run of the identical dish in one day into a single row.
 *
 * When the solver buys one snack recipe and nothing else, every day gets it
 * twice, and two identical rows one under the other reads as a rendering bug
 * rather than as "eat two of these". The count says the same thing in one line.
 */
export function merged(sittings: Sitting[]): (Sitting & { n: number })[] {
  const out: (Sitting & { n: number })[] = [];
  for (const s of sittings) {
    const last = out[out.length - 1];
    if (last && last.meal.recipe === s.meal.recipe && last.slot === s.slot) last.n += 1;
    else out.push({ ...s, n: 1 });
  }
  return out;
}

/** What a day adds up to. The solver guarantees this across the plan, not per
 *  day — see the note the week view carries — so it is shown as description,
 *  not as a target that was hit. */
export function kcalIn(day: Day): number {
  return day.sittings.reduce((a, x) => a + x.meal.kcal_per_serving, 0);
}

/** Total servings in a laid-out week — used to check nothing was lost. */
export function servingsIn(week: Day[]): number {
  return week.reduce((a, d) => a + d.sittings.length, 0);
}
