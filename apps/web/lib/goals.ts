/**
 * Goal presets, measured against the catalogue rather than guessed.
 *
 * Within 1700-2100 kcal the most protein reachable is 110g/day, so a 140g cut
 * target was fantasy. Bulk needs 130g rather than 140g: at 140 a fortnight fails
 * by 7g/day. These are the numbers the food supports.
 *
 * They are presets for roughly an 80kg adult, not a calculation — real targets
 * need bodyweight, which onboarding does not collect yet.
 */
export const GOALS = {
  frugal: {
    label: "Getting by",
    blurb: "Cheapest food that still feeds you properly",
    protein: 55,
    kcal: [1700, 2400] as [number, number],
  },
  maintain: {
    label: "Maintain",
    blurb: "Hold steady",
    protein: 100,
    kcal: [2000, 2700] as [number, number],
  },
  cut: {
    label: "Cut",
    blurb: "Lower calories, protein held high",
    protein: 100,
    kcal: [1700, 2100] as [number, number],
  },
  bulk: {
    label: "Bulk",
    blurb: "Eat big, snacks included",
    protein: 130,
    kcal: [2800, 3300] as [number, number],
  },
} as const;

export type GoalKey = keyof typeof GOALS;
export const GOAL_ORDER: GoalKey[] = ["frugal", "maintain", "cut", "bulk"];

export const STORES = [
  { slug: "aldi", name: "Aldi" },
  { slug: "tesco", name: "Tesco" },
] as const;

/**
 * Retired. The length slider now runs every day from 1 to 14, because the
 * solver accepts any length in that range and six named stops was an invention
 * that made dragging snap. Kept only for the demo's export grid, which does
 * carry a fixed set of durations.
 */
export const DAY_STOPS = [1, 3, 7, 14];
