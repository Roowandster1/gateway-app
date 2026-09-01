/**
 * Typed client for the solver service.
 *
 * The solver runs as a separate Python service (PuLP/CBC) and is never exposed
 * to the browser — every call goes through a route handler so SOLVER_URL stays
 * server-side. Nothing here decides meals, prices or quantities; it forwards a
 * request and returns what CBC produced.
 */
import type { Allergen, Appliance, Protein, Style } from "@/lib/diet";

export type Objective = "protein" | "cheapest" | "variety";
export type Slot = "breakfast" | "main" | "snack";

export interface SolveRequest {
  store: string;
  budget: number;
  days: number;
  min_protein_per_day: number;
  kcal_band: [number, number];
  household_size?: number;
  objective?: Objective;
  pantry?: Record<string, number>;
  /** Dietary answers. These only remove recipes before the solve — never score them. */
  avoid_allergens?: Allergen[];
  /** Appliances owned. Empty means "assume everything", never "assume none". */
  appliances?: Appliance[];
  avoid_proteins?: Protein[];
  styles?: Style[];
}

export interface PlanMeal {
  recipe: string;
  name: string;
  servings: number;
  slot: Slot;
  minutes: number;
  kcal_per_serving: number;
  protein_per_serving: number;
  /** Decorative dish photography. Absent is a normal state, not an error. */
  image_url: string | null;
}

export interface BasketLine {
  item: string;
  name: string;
  aisle: string;
  unit: "g" | "ml" | "unit";
  packs: number;
  pack_size: number;
  unit_price: number;
  line_cost: number;
  qty_from_pantry: number;
  qty_used: number;
  qty_carry_over: number;
  qty_wasted: number;
  carries: boolean;
}

export interface Plan {
  status: "ok";
  store: string;
  budget: number;
  spend: number;
  consumed_value: number;
  carry_over_value: number;
  wasted_value: number;
  protein_per_day: number;
  kcal_per_day: number;
  meals: PlanMeal[];
  basket: BasketLine[];
  closing_pantry: Record<string, number>;
  recipes_left?: number;
}

/** SPEC §2: infeasibility is a feature, so it arrives as a 200 with a reason. */
export interface Infeasible {
  status: "infeasible";
  binding: string;
  also_binding: string[];
  suggestion: string;
  min_feasible_budget: number | null;
  recipes_left?: number;
  /** How many recipes each answer removed, so the blocker can be named. */
  removed_by?: Record<string, number>;
}

export interface Floor {
  store: string;
  days: number;
  /** Cheapest plan from an empty cupboard. */
  first: number | null;
  /** Cheapest plan once the cupboard is stocked. Null when money is not the blocker. */
  ongoing: number | null;
  /**
   * Set when the dietary filters, not money, make a plan impossible — the
   * catalogue has no gluten-free breakfast, say. No budget fixes this, so the
   * budget screen must not offer one.
   */
  blocked: string | null;
  /** How many of the 24 recipes survive the filters. */
  recipes_left: number;
}

/**
 * What a route handler returns when the solver service itself cannot answer.
 * It is not a Plan and it is not a Floor: callers must narrow on `status`
 * before reading any number off it.
 */
export interface SolverError {
  status: "error";
  detail: string;
}

export type SolveResult = Plan | Infeasible;

const SOLVER_URL = process.env.SOLVER_URL ?? "http://127.0.0.1:8000";

async function post<T>(path: string, body: unknown): Promise<T> {
  const res = await fetch(`${SOLVER_URL}${path}`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
    cache: "no-store",
  });
  if (!res.ok) {
    throw new Error(`solver ${path} returned ${res.status}`);
  }
  return (await res.json()) as T;
}

/** How many of the catalogue's recipes survive the dietary answers. */
export interface FilterCount {
  recipes_left: number;
  total: number;
  by_slot: Record<string, number>;
  removed_by: Record<string, number>;
  /** Set when the filters alone make a plan impossible at any budget. */
  blocked: string | null;
}

export const solve = (req: SolveRequest) => post<SolveResult>("/solve", req);
export const floor = (req: SolveRequest) => post<Floor>("/floor", req);
export const filtersOnly = (req: SolveRequest) => post<FilterCount>("/filters", req);
