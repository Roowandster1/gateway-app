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
 *
 * The colour classes are the pastel tile fills in globals.css. They carry no
 * meaning — every tile is labelled — and dark `--ink` text clears 4.5:1 on all
 * of them.
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
  colour: string;
}

export const APPLIANCES: Tile<Appliance>[] = [
  { key: "hob", emoji: "🔥", label: "Hob", sub: "18 recipes", colour: "c2" },
  { key: "oven", emoji: "🔲", label: "Oven", sub: "2 recipes", colour: "c4" },
  { key: "microwave", emoji: "📻", label: "Microwave", sub: "jacket only", colour: "c5" },
  { key: "airfryer", emoji: "🌀", label: "Air fryer", sub: "does the oven's job", colour: "c6" },
];

export const PROTEINS: Tile<Protein>[] = [
  { key: "chicken", emoji: "🍗", label: "Chicken", colour: "c3" },
  { key: "beef", emoji: "🥩", label: "Beef", colour: "c1" },
  { key: "fish", emoji: "🐟", label: "Fish", colour: "c4" },
  { key: "egg", emoji: "🥚", label: "Eggs", colour: "c9" },
];

export const ALLERGENS: Tile<Allergen>[] = [
  { key: "gluten", emoji: "🌾", label: "Gluten free", colour: "c3" },
  { key: "dairy", emoji: "🥛", label: "Dairy free", colour: "c5" },
  { key: "egg", emoji: "🥚", label: "Egg free", colour: "c9" },
  { key: "fish", emoji: "🐟", label: "Fish free", colour: "c4" },
  { key: "peanut", emoji: "🥜", label: "Peanut free", colour: "c2" },
];

export const STYLES: Tile<Style>[] = [
  { key: "speedy", emoji: "⚡", label: "Speedy", sub: "15 min or less", colour: "c5" },
  { key: "onepot", emoji: "🍲", label: "One pot", sub: "one pan, one wash", colour: "c6" },
  { key: "veggie", emoji: "🥦", label: "Veggie", sub: "no meat or fish", colour: "c7" },
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
  { slug: "aldi", name: "Aldi", priced: true, colour: "c4" },
  { slug: "tesco", name: "Tesco", priced: true, colour: "c1" },
  { slug: "sainsburys", name: "Sainsbury's", priced: false, colour: "c2" },
  { slug: "asda", name: "Asda", priced: false, colour: "c7" },
  { slug: "morrisons", name: "Morrisons", priced: false, colour: "c3" },
  { slug: "lidl", name: "Lidl", priced: false, colour: "c8" },
  { slug: "coop", name: "Co-op", priced: false, colour: "c6" },
  { slug: "mands", name: "M&S", priced: false, colour: "c5" },
  { slug: "waitrose", name: "Waitrose", priced: false, colour: "c9" },
] as const;

export const TOTAL_RECIPES = 24;
