/**
 * The dietary, kitchen and style options the onboarding offers.
 *
 * Every option here exists because the catalogue can honour it. Nothing is
 * offered that the data cannot act on:
 *
 * - **No pork.** The 28-item catalogue has beef, chicken, tuna and eggs. A pork
 *   toggle would look like a feature and do nothing.
 * - **Five allergens, not nine.** gluten, dairy, egg, fish and peanut are
 *   settled by what the products plainly are. Soy, sesame and shellfish are not
 *   knowable from a product name, and a guessed allergen is worse than an
 *   absent one — so they are absent, and the screen says why.
 * - **Three styles, not eight.** Speed is a column, one-pot is a property of the
 *   method, vegetarian is already tagged. "Family favourite" and "gut friendly"
 *   would be a language model's opinion dressed as data, which CLAUDE.md rule 1
 *   rules out of the selection path.
 */

export type Allergen = "gluten" | "dairy" | "egg" | "fish" | "peanut";
export type Appliance = "hob" | "oven" | "microwave" | "airfryer";
export type Protein = "beef" | "chicken" | "fish" | "egg";
export type Style = "speedy" | "onepot" | "veggie";

export interface Tile<T> {
  key: T;
  emoji: string;
  label: string;
  sub?: string;
}

export const APPLIANCES: Tile<Appliance>[] = [
  { key: "hob", emoji: "🔥", label: "Hob", sub: "18 recipes" },
  { key: "oven", emoji: "🔲", label: "Oven", sub: "2 recipes" },
  { key: "microwave", emoji: "📻", label: "Microwave", sub: "jacket only" },
  { key: "airfryer", emoji: "🌀", label: "Air fryer", sub: "does the oven's job" },
];

export const PROTEINS: Tile<Protein>[] = [
  { key: "chicken", emoji: "🍗", label: "Chicken" },
  { key: "beef", emoji: "🥩", label: "Beef" },
  { key: "fish", emoji: "🐟", label: "Fish" },
  { key: "egg", emoji: "🥚", label: "Eggs" },
];

export const ALLERGENS: Tile<Allergen>[] = [
  { key: "gluten", emoji: "🌾", label: "Gluten free" },
  { key: "dairy", emoji: "🥛", label: "Dairy free" },
  { key: "egg", emoji: "🥚", label: "Egg free" },
  { key: "fish", emoji: "🐟", label: "Fish free" },
  { key: "peanut", emoji: "🥜", label: "Peanut free" },
];

export const STYLES: Tile<Style>[] = [
  { key: "speedy", emoji: "⚡", label: "Speedy", sub: "15 min or less" },
  { key: "onepot", emoji: "🍲", label: "One pot", sub: "one pan, one wash" },
  { key: "veggie", emoji: "🥦", label: "Veggie", sub: "no meat or fish" },
];

/**
 * Every UK supermarket the onboarding shows, and whether it has prices.
 *
 * The seven without prices are listed but not selectable. CLAUDE.md rule 3 is
 * that an unpriced item is excluded from planning rather than guessed at, and a
 * whole unpriced store is the same rule at a larger scale — offering Sainsbury's
 * and quietly planning it with Tesco's numbers would break the one promise the
 * product makes. They are shown rather than hidden so the gap is visible.
 *
 * Names only, never logos: DESIGN.md says the app names these shops as data and
 * must not dress as them, and reproducing their marks is a trademark question
 * nobody here has answered.
 */
export const ALL_STORES = [
  { slug: "aldi", name: "Aldi", priced: true },
  { slug: "tesco", name: "Tesco", priced: true },
  { slug: "sainsburys", name: "Sainsbury's", priced: false },
  { slug: "asda", name: "Asda", priced: false },
  { slug: "morrisons", name: "Morrisons", priced: false },
  { slug: "lidl", name: "Lidl", priced: false },
  { slug: "coop", name: "Co-op", priced: false },
  { slug: "mands", name: "M&S", priced: false },
  { slug: "waitrose", name: "Waitrose", priced: false },
] as const;

export const TOTAL_RECIPES = 24;
