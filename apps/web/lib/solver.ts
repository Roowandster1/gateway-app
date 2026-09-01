/**
 * Typed client for the solver service.
 *
 * The solver runs as a separate Python service (PuLP/CBC) and is never exposed
 * to the browser — every call goes through a route handler so SOLVER_URL stays
 * server-side. Nothing here decides meals, prices or quantities; it forwards a
 * request and returns what CBC produced.
 */
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
}

/** SPEC §2: infeasibility is a feature, so it arrives as a 200 with a reason. */
export interface Infeasible {
  status: "infeasible";
  binding: string;
  also_binding: string[];
  suggestion: string;
  min_feasible_budget: number | null;
}

export interface Floor {
  store: string;
  days: number;
  /** Cheapest plan from an empty cupboard. */
  first: number | null;
  /** Cheapest plan once the cupboard is stocked. Null when money is not the blocker. */
  ongoing: number | null;
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

export const solve = (req: SolveRequest) => post<SolveResult>("/solve", req);
export const floor = (req: SolveRequest) => post<Floor>("/floor", req);
