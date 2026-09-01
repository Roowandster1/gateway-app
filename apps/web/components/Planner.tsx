"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { CostSplit } from "@/components/CostSplit";
import { DAY_STOPS, GOALS, GOAL_ORDER, type GoalKey } from "@/lib/goals";
import {
  ALLERGENS,
  ALL_STORES,
  APPLIANCES,
  PROTEINS,
  STYLES,
  TOTAL_RECIPES,
  type Allergen,
  type Appliance,
  type Protein,
  type Style,
  type Tile,
} from "@/lib/diet";
import type { FilterCount, Floor, Plan, SolveResult, SolverError } from "@/lib/solver";

const STEPS = [
  "store",
  "kitchen",
  "eat",
  "allergies",
  "style",
  "days",
  "budget",
  "goal",
  "plan",
] as const;
type Step = (typeof STEPS)[number];
const LAST_QUESTION = STEPS.length - 2;

const STEP_NAMES: Record<Step, string> = {
  store: "Where you shop",
  kitchen: "Your kitchen",
  eat: "What you eat",
  allergies: "Allergies",
  style: "Your style",
  days: "How long for",
  budget: "The budget",
  goal: "What you're eating for",
  plan: "Your plan",
};

/** Toggles a key in a Set-like array, keeping the order stable. */
function toggle<T>(list: T[], key: T): T[] {
  return list.includes(key) ? list.filter((k) => k !== key) : [...list, key];
}

const money = (n: number) => `£${n.toFixed(2)}`;
const plural = (n: number, w: string) => `${n} ${w}${n === 1 ? "" : "s"}`;

/** The message the route handler sent, or a fallback if it sent nothing usable. */
const detailOf = (v: unknown) =>
  typeof v === "object" && v !== null && typeof (v as SolverError).detail === "string"
    ? (v as SolverError).detail
    : "Could not reach the solver.";

/** For "at the till, for {periodWord}". */
function periodWord(days: number) {
  if (days === 1) return "one day";
  if (days === 7) return "the week";
  if (days === 14) return "the fortnight";
  return `${days} days`;
}

/** For "about £8.91 a {periodNoun}" — a bare noun, never "a one day". */
function periodNoun(days: number) {
  if (days === 1) return "day";
  if (days === 7) return "week";
  if (days === 14) return "fortnight";
  return `${days} days`;
}

function qty(q: number, unit: string) {
  if (unit === "unit") return String(Math.round(q));
  if (q >= 1000)
    return `${(q / 1000).toFixed(q % 1000 === 0 ? 0 : 2).replace(/\.00$/, "")}${
      unit === "ml" ? "L" : "kg"
    }`;
  return `${Math.round(q)}${unit}`;
}

/**
 * 19 budget stops spanning the measured floor: half of it to two and a half
 * times it, so the floor always sits inside the range and a budget well below
 * it is reachable. Before the floor lands, days x £4 is a placeholder.
 */
function budgetStops(floor: Floor | null, days: number): number[] {
  const base = floor?.first ?? days * 4;
  const lo = Math.max(3, Math.round(base * 0.5));
  const hi = Math.round(base * 2.5);
  const step = (hi - lo) / 18;
  return Array.from({ length: 19 }, (_, i) => Math.round((lo + step * i) * 4) / 4);
}

export function Planner() {
  const [step, setStep] = useState<Step>("store");
  const [store, setStore] = useState("aldi");
  const [days, setDays] = useState(7);
  const [goal, setGoal] = useState<GoalKey>("maintain");
  // Filters. Empty is the permissive answer everywhere: no allergen avoided,
  // every appliance assumed, every protein eaten, no style narrowing. A person
  // who taps Continue four times gets exactly the plan they got before these
  // screens existed.
  const [appliances, setAppliances] = useState<Appliance[]>([]);
  const [avoidProteins, setAvoidProteins] = useState<Protein[]>([]);
  const [avoidAllergens, setAvoidAllergens] = useState<Allergen[]>([]);
  const [styles, setStyles] = useState<Style[]>([]);
  // A slider, with the measured floor pinned on the track. The old build's
  // range started at £25 and implied that was the minimum; it now runs from
  // half the floor to two and a half times it, so a small budget is reachable
  // and simply comes back as infeasible with the real number attached.
  const [budgetIx, setBudgetIx] = useState(9);
  // `value: null` means the request was made and the solver could not answer.
  // That is a different state from "not asked yet" and the UI must not show
  // the same "working it out…" line for both.
  const [floorFor, setFloorFor] = useState<{ key: string; value: Floor | null } | null>(
    null,
  );
  const [counts, setCounts] = useState<{ key: string; value: FilterCount } | null>(null);
  const [result, setResult] = useState<SolveResult | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState<"food" | "shop">("food");
  const [ticked, setTicked] = useState<Record<string, boolean>>({});

  const ix = STEPS.indexOf(step);
  const targets = GOALS[goal];
  const diet = useMemo(
    () => ({
      avoid_allergens: avoidAllergens,
      appliances,
      avoid_proteins: avoidProteins,
      styles,
    }),
    [avoidAllergens, appliances, avoidProteins, styles],
  );
  // The floor depends on the filters too — a vegetarian week has a different
  // cheapest shop — so they belong in the key that makes a stored floor stale.
  const countKey = `${store}|${JSON.stringify(diet)}`;
  const floorKey = `${store}|${days}|${goal}|${JSON.stringify(diet)}`;
  const floorEntry = floorFor?.key === floorKey ? floorFor : null;
  const floor = floorEntry?.value ?? null;
  const floorUnavailable = floorEntry !== null && floorEntry.value === null;

  const stops = useMemo(() => budgetStops(floor, days), [floor, days]);
  const budget = stops[Math.min(budgetIx, stops.length - 1)];

  const body = useCallback(
    (over: Record<string, unknown> = {}) => ({
      store,
      days,
      budget,
      min_protein_per_day: targets.protein,
      kcal_band: targets.kcal,
      ...diet,
      ...over,
    }),
    [store, days, budget, targets, diet],
  );

  // The recipe counter on every filter screen. This costs nothing — it is a set
  // intersection, not a solve — so it can run on every tap.
  useEffect(() => {
    let live = true;
    fetch("/api/filters", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ store, days: 7, budget: 1, ...diet }),
    })
      .then(async (r) => (r.ok ? ((await r.json()) as FilterCount) : null))
      .then((value) => {
        if (live && value && "recipes_left" in value) {
          setCounts({ key: countKey, value });
        }
      })
      .catch(() => {});
    return () => {
      live = false;
    };
  }, [countKey, store, diet]);

  // The floor costs a set of CBC runs, so it is fetched only once the answers
  // that shape it are in — not on every tap of a filter screen.
  useEffect(() => {
    if (ix < STEPS.indexOf("budget")) return;
    let live = true;
    fetch("/api/floor", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        store,
        days,
        budget: 999,
        min_protein_per_day: targets.protein,
        kcal_band: targets.kcal,
        ...diet,
      }),
    })
      .then(async (r) => ({ ok: r.ok, value: (await r.json()) as Floor | SolverError }))
      .then(({ ok, value }) => {
        if (!live) return;
        // A 502 body is shaped nothing like a Floor. Storing it anyway put
        // `undefined` where a number belonged, and the budget screen died on
        // the first money() call rather than saying the solver was down.
        if (!ok || !("first" in value)) {
          setFloorFor({ key: floorKey, value: null });
          setError(detailOf(value));
          return;
        }
        setFloorFor({ key: floorKey, value });
        setError(null);
      })
      .catch(() => {
        if (!live) return;
        setFloorFor({ key: floorKey, value: null });
        setError("Could not reach the solver.");
      });
    return () => {
      live = false;
    };
  }, [floorKey, store, days, targets, diet, ix]);

  async function buildPlan() {
    setBusy(true);
    setError(null);
    setTicked({});
    try {
      const res = await fetch("/api/solve", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(body()),
      });
      const data = (await res.json()) as SolveResult | SolverError;
      if (!res.ok || (data.status !== "ok" && data.status !== "infeasible")) {
        setError(detailOf(data));
        return;
      }
      setResult(data);
      setStep("plan");
    } catch {
      setError("Could not reach the solver.");
    } finally {
      setBusy(false);
    }
  }

  const plan = result?.status === "ok" ? (result as Plan) : null;
  const storeName = ALL_STORES.find((s) => s.slug === store)?.name ?? store;
  const count = counts?.key === countKey ? counts.value : null;
  const recipesLeft = count?.recipes_left ?? null;
  const totalRecipes = count?.total ?? TOTAL_RECIPES;
  const blocked = count?.blocked ?? floor?.blocked ?? null;

  return (
    <div className="phone">
      <div className="topbar">
        {ix > 0 && (
          <button className="back" onClick={() => setStep(STEPS[ix - 1])} aria-label="Go back">
            ←
          </button>
        )}
        <span className="lab">{STEP_NAMES[step]}</span>
        <span className="idx">
          {ix <= LAST_QUESTION ? `${ix + 1} of ${LAST_QUESTION + 1}` : plan ? "Solved" : "No fit"}
        </span>
      </div>
      {ix <= LAST_QUESTION && (
        <div className="rail">
          {STEPS.slice(0, LAST_QUESTION + 1).map((_, i) => (
            <i key={i} className={i <= ix ? "on" : undefined} />
          ))}
        </div>
      )}

      {step === "store" && (
        <Screen
          eyebrow={`Step 1 of ${LAST_QUESTION + 1}`}
          q="Where do you shop?"
          sub="We'll plan the whole shop around it."
          cta="Continue"
          onNext={() => setStep("kitchen")}
        >
          <div className="tiles">
            {ALL_STORES.map((s) => (
              <button
                key={s.slug}
                className={`tile ${s.priced ? s.colour : "c0"}`}
                aria-pressed={store === s.slug}
                disabled={!s.priced}
                onClick={() => setStore(s.slug)}
              >
                <span className="t">{s.name}</span>
                <span className="s">{s.priced ? "28 items priced" : "no prices yet"}</span>
              </button>
            ))}
          </div>
          <p className="caveat">
            Only Aldi and Tesco carry real prices so far. The rest are greyed out
            rather than hidden: planning them with another shop&apos;s numbers would
            break the one thing this app promises.
          </p>
        </Screen>
      )}

      {step === "kitchen" && (
        <Screen
          eyebrow={`Step 2 of ${LAST_QUESTION + 1}`}
          q="What can you cook with?"
          sub="Leave it blank if you have the lot."
          cta="Continue"
          onNext={() => setStep("eat")}
        >
          <TileGrid
            tiles={APPLIANCES}
            selected={appliances}
            onToggle={(k) => setAppliances(toggle(appliances, k))}
          />
          <Counter left={recipesLeft} total={totalRecipes} blocked={blocked} />
        </Screen>
      )}

      {step === "eat" && (
        <Screen
          eyebrow={`Step 3 of ${LAST_QUESTION + 1}`}
          q="Anything you don't eat?"
          sub="Tap what to leave out."
          cta="Continue"
          onNext={() => setStep("allergies")}
        >
          <TileGrid
            tiles={PROTEINS}
            selected={avoidProteins}
            onToggle={(k) => setAvoidProteins(toggle(avoidProteins, k))}
          />
          <p className="caveat">
            No pork option, because the catalogue has no pork. A toggle that did
            nothing would look like a feature.
          </p>
          <Counter left={recipesLeft} total={totalRecipes} blocked={blocked} />
        </Screen>
      )}

      {step === "allergies" && (
        <Screen
          eyebrow={`Step 4 of ${LAST_QUESTION + 1}`}
          q="Any allergies?"
          sub="Nothing tapped means none."
          cta="Continue"
          onNext={() => setStep("style")}
        >
          <TileGrid
            tiles={ALLERGENS}
            selected={avoidAllergens}
            onToggle={(k) => setAvoidAllergens(toggle(avoidAllergens, k))}
          />
          <p className="caveat">
            <b>These come from product names, not from labels.</b> They are enough
            to filter a meal plan and <b>not</b> enough to rely on for a real
            allergy — always check the packet. Soy, sesame and shellfish are
            missing because no product name settles them, and a guessed allergen
            is worse than an absent one.
          </p>
          <Counter left={recipesLeft} total={totalRecipes} blocked={blocked} />
        </Screen>
      )}

      {step === "style" && (
        <Screen
          eyebrow={`Step 5 of ${LAST_QUESTION + 1}`}
          q="What are you in the mood for?"
          sub="Pick any, or none for everything."
          cta="Continue"
          onNext={() => setStep("days")}
        >
          <TileGrid
            tiles={STYLES}
            selected={styles}
            onToggle={(k) => setStyles(toggle(styles, k))}
          />
          <Counter left={recipesLeft} total={totalRecipes} blocked={blocked} />
        </Screen>
      )}

      {step === "days" && (
        <Screen eyebrow={`Step 6 of ${LAST_QUESTION + 1}`} q="How long for?" cta="Continue" onNext={() => setStep("budget")}>
          <div className="readout">
            <span className="tik big">
              {days % 7 === 0
                ? `${days / 7} ${days === 7 ? "week" : "weeks"}`
                : `${days} ${days === 1 ? "day" : "days"}`}
            </span>
            <span className="rt lab">
              {plural(days * 3, "meal")}
              <br />
              for one
            </span>
          </div>
          <Slider
            max={DAY_STOPS.length - 1}
            value={DAY_STOPS.indexOf(days)}
            label="Plan length"
            onChange={(i) => {
              setDays(DAY_STOPS[i]);
              setTicked({});
            }}
          />
          <div className="scale">
            <span>1 day</span>
            <span>2 weeks</span>
          </div>
          <p className="note">
            {days === 14
              ? `${plural(days * 3, "meal")}. Two shops, a week apart, so nothing fresh has to last a fortnight.`
              : days <= 2
                ? `${plural(days * 3, "meal")}. Packs are whole, so most of a short shop is stock you keep.`
                : `${plural(days * 3, "meal")}. One shop.`}
          </p>
        </Screen>
      )}

      {step === "budget" && (
        <Screen
          eyebrow={`Step 7 of ${LAST_QUESTION + 1}`}
          q="What's the budget?"
          cta="Continue"
          onNext={() => setStep("goal")}
        >
          <div className="readout">
            <span className="tik big">{money(budget).replace(/\.00$/, "")}</span>
            <span className="rt lab">
              For one
              <br />
              at {storeName}
              <br />
              {days === 1 ? "1 day" : plural(days, "day")}
            </span>
          </div>
          <Slider
            max={stops.length - 1}
            value={Math.min(budgetIx, stops.length - 1)}
            label="Budget"
            floorPct={
              floor?.first != null &&
              floor.first > stops[0] &&
              floor.first < stops[stops.length - 1]
                ? (floor.first - stops[0]) / (stops[stops.length - 1] - stops[0])
                : null
            }
            onChange={(i) => {
              setBudgetIx(i);
              setTicked({});
            }}
          />
          <div className="scale">
            <span>{money(stops[0]).replace(/\.00$/, "")}</span>
            <span>{money(stops[stops.length - 1]).replace(/\.00$/, "")}</span>
          </div>
          <FloorNote
            floor={floor}
            unavailable={floorUnavailable}
            budget={budget}
            days={days}
            store={storeName}
          />
        </Screen>
      )}

      {step === "goal" && (
        <Screen
          eyebrow={`Step 8 of ${LAST_QUESTION + 1}`}
          q="What are you eating for?"
          cta={busy ? "Solving…" : "Build the plan"}
          disabled={busy}
          onNext={buildPlan}
        >
          <div className="choices">
            {GOAL_ORDER.map((g) => (
              <Choice
                key={g}
                selected={goal === g}
                onClick={() => setGoal(g)}
                name={GOALS[g].label}
                detail={`${GOALS[g].kcal[0]}–${GOALS[g].kcal[1]} kcal a day`}
                aside={
                  <>
                    {GOALS[g].protein}g protein
                    <br />
                    minimum
                  </>
                }
              />
            ))}
          </div>
        </Screen>
      )}

      {step === "plan" && (
        <PlanScreen
          result={result}
          days={days}
          tab={tab}
          setTab={setTab}
          ticked={ticked}
          setTicked={setTicked}
          onUseFloor={(b) => {
            const i = stops.findIndex((s) => s >= b);
            setBudgetIx(i < 0 ? stops.length - 1 : i);
            setStep("budget");
          }}
          onRestart={() => {
            setResult(null);
            setStep("store");
          }}
        />
      )}

      {error && (
        <p className="screen-error">
          {error} Is the solver running on port 8000?
        </p>
      )}
    </div>
  );
}

/* ---------- pieces ---------- */

function Screen({
  eyebrow,
  q,
  sub,
  cta,
  onNext,
  disabled,
  children,
}: {
  eyebrow: string;
  q: string;
  sub?: string;
  cta: string;
  onNext: () => void;
  disabled?: boolean;
  children: React.ReactNode;
}) {
  return (
    <section className="screen">
      <h2 className="q">
        <span className="sm">{eyebrow}</span>
        {q}
      </h2>
      {sub && <p className="qsub">{sub}</p>}
      {children}
      <div className="cta">
        <button className="btn" onClick={onNext} disabled={disabled}>
          {cta}
        </button>
      </div>
    </section>
  );
}

/** A grid of pastel pick-many tiles. Colour is decoration; every tile is labelled. */
function TileGrid<T extends string>({
  tiles,
  selected,
  onToggle,
}: {
  tiles: Tile<T>[];
  selected: T[];
  onToggle: (k: T) => void;
}) {
  return (
    <div className="tiles">
      {tiles.map((t) => (
        <button
          key={t.key}
          className={`tile ${t.colour}`}
          aria-pressed={selected.includes(t.key)}
          onClick={() => onToggle(t.key)}
        >
          <span className="emo" aria-hidden>
            {t.emoji}
          </span>
          <span className="t">{t.label}</span>
          {t.sub && <span className="s">{t.sub}</span>}
        </button>
      ))}
    </div>
  );
}

/**
 * How many of the 24 recipes survive the filters chosen so far.
 *
 * With a catalogue this small a stacked filter set empties a meal slot quickly,
 * and finding that out four screens later is a dead end. This says it as it
 * happens, and turns red with the real reason when the slot is already gone.
 */
function Counter({
  left,
  total,
  blocked,
}: {
  left: number | null;
  total: number;
  blocked: string | null;
}) {
  if (blocked) {
    return (
      <div className="counter bad">
        <span>{blocked}</span>
      </div>
    );
  }
  return (
    <div className="counter">
      <span>
        {left === null ? (
          "Counting the recipes that fit…"
        ) : (
          <>
            <b>
              {left} of {total}
            </b>{" "}
            recipes still fit.
          </>
        )}
      </span>
    </div>
  );
}

function Choice({
  selected,
  onClick,
  name,
  detail,
  aside,
}: {
  selected: boolean;
  onClick: () => void;
  name: string;
  detail: string;
  aside?: React.ReactNode;
}) {
  return (
    <button className="choice" onClick={onClick} aria-pressed={selected}>
      <span>
        <span className="nm">{name}</span>
        <span className="dt">{detail}</span>
      </span>
      {aside && <span className="num">{aside}</span>}
    </button>
  );
}

/**
 * A range input whose filled portion is painted from the value, plus an
 * optional pin for a real, solved number on the track — the budget floor is
 * something the solver measured, so it belongs on the control rather than only
 * in a sentence underneath.
 */
function Slider({
  max,
  value,
  label,
  onChange,
  floorPct,
}: {
  max: number;
  value: number;
  label: string;
  onChange: (i: number) => void;
  floorPct?: number | null;
}) {
  const pct = max > 0 ? (value / max) * 100 : 0;
  return (
    <div className="track">
      <input
        type="range"
        min={0}
        max={max}
        step={1}
        value={value}
        aria-label={label}
        onChange={(e) => onChange(+e.target.value)}
        style={{ "--pct": `${pct}%` } as React.CSSProperties}
      />
      {floorPct != null && (
        <span
          className="floorpin"
          // The thumb is 28px, so the usable track is inset by half a thumb at
          // each end; the pin has to sit in that same space to line up.
          style={{ left: `calc(14px + ${floorPct} * (100% - 28px))` }}
        >
          <b>floor</b>
        </span>
      )}
    </div>
  );
}

function FloorNote({
  floor,
  unavailable,
  budget,
  days,
  store,
}: {
  floor: Floor | null;
  unavailable?: boolean;
  budget: number;
  days: number;
  store: string;
}) {
  if (unavailable) {
    return (
      <div className="floormark under">
        The floor could not be worked out — the solver is not answering. Any number you
        pick here is a guess until it does.
      </div>
    );
  }
  if (!floor) return <div className="floormark">Working out the floor…</div>;
  if (floor.first === null) {
    return (
      <div className="floormark under">
        No budget works for these targets here. The targets have to move.
      </div>
    );
  }
  const under = budget < floor.first;
  return (
    <div className={under ? "floormark under" : "floormark"}>
      {under ? (
        <>
          Too low at {store} from an empty cupboard. Cheapest first shop is{" "}
          <b>{money(floor.first)}</b>.
          {floor.ongoing !== null && (
            <>
              {" "}
              Once stocked, about <b>{money(floor.ongoing)}</b> a {periodNoun(days)}.
            </>
          )}
        </>
      ) : (
        <>
          Cheapest first shop <b>{money(floor.first)}</b>
          {floor.ongoing !== null ? (
            <>
              , then about <b>{money(floor.ongoing)}</b> a {periodNoun(days)}. The first is
              dearer because it stocks the cupboard.
            </>
          ) : (
            "."
          )}
        </>
      )}
    </div>
  );
}

/**
 * The meal and shopping lists are taller than the ticket, so they scroll inside
 * it. Left plain, the cap slices a row flat and reads as the end of the list —
 * you cannot tell there is more. The bottom edge fades only while there
 * actually is, so the last row is never faded for nothing.
 *
 * Measured on scroll and on mount rather than in an effect: the effect version
 * of this sets state on every render pass and React flags it.
 */
function Scroller({ label, children }: { label: string; children: React.ReactNode }) {
  const [more, setMore] = useState(false);

  const measure = useCallback((node: HTMLDivElement | null) => {
    if (!node) return;
    const v = node.scrollTop + node.clientHeight < node.scrollHeight - 2;
    setMore((prev) => (prev === v ? prev : v));
  }, []);

  return (
    <div
      ref={measure}
      onScroll={(e) => measure(e.currentTarget)}
      // A scrollable region is reachable by keyboard, so it needs a name and a
      // tab stop of its own (WCAG 2.1.1).
      tabIndex={0}
      role="group"
      aria-label={label}
      className={more ? "pane more" : "pane"}
    >
      {children}
    </div>
  );
}

function PlanScreen({
  result,
  days,
  tab,
  setTab,
  ticked,
  setTicked,
  onUseFloor,
  onRestart,
}: {
  result: SolveResult | null;
  days: number;
  tab: "food" | "shop";
  setTab: (t: "food" | "shop") => void;
  ticked: Record<string, boolean>;
  setTicked: (t: Record<string, boolean>) => void;
  onUseFloor: (b: number) => void;
  onRestart: () => void;
}) {
  if (!result) return null;

  if (result.status === "infeasible") {
    return (
      <section className="screen">
        <div className="stop">
          <h3>
            {result.min_feasible_budget !== null
              ? "That budget doesn't exist here"
              : "This one can't be done"}
          </h3>
          <p>{result.suggestion}</p>
          <p>
            {[result.binding, ...result.also_binding].map((b) => (
              <span key={b} className="blocker">
                {b}
              </span>
            ))}
          </p>
        </div>
        {result.min_feasible_budget !== null && (
          <button className="btn" onClick={() => onUseFloor(result.min_feasible_budget!)}>
            Use {money(result.min_feasible_budget)} instead
          </button>
        )}
        <p className="note">
          This is the answer, not a failure. No set of whole packs meets the targets, so it
          names what blocked it rather than serving you a worse week.
        </p>
        <div className="cta">
          <button className="btn ghost" onClick={onRestart}>
            Start again
          </button>
        </div>
      </section>
    );
  }

  const plan = result;
  const order = { breakfast: 0, main: 1, snack: 2 } as const;
  const meals = [...plan.meals].sort(
    (a, b) => order[a.slot] - order[b.slot] || b.servings - a.servings,
  );
  const titles = { breakfast: "Breakfast", main: "Main meals", snack: "Snacks" };
  const seen = new Set<string>();

  const byAisle = new Map<string, typeof plan.basket>();
  plan.basket
    .filter((b) => b.packs > 0)
    .forEach((b) => byAisle.set(b.aisle, [...(byAisle.get(b.aisle) ?? []), b]));

  const picked = plan.basket
    .filter((b) => b.packs > 0 && ticked[b.item])
    .reduce((a, b) => a + b.line_cost, 0);

  return (
    <section className="screen">
      <CostSplit plan={plan} period={periodWord(days)} periodNoun={periodNoun(days)} />

      <div className="tabs" role="tablist">
        <button
          className="tab"
          role="tab"
          aria-selected={tab === "food"}
          onClick={() => setTab("food")}
        >
          The food
        </button>
        <button
          className="tab"
          role="tab"
          aria-selected={tab === "shop"}
          onClick={() => setTab("shop")}
        >
          Shopping list
        </button>
      </div>

      {tab === "food" ? (
        <Scroller label="The meals in this plan">
          {meals.map((m) => {
            let head = null;
            if (!seen.has(m.slot)) {
              seen.add(m.slot);
              const n = meals
                .filter((o) => o.slot === m.slot)
                .reduce((a, o) => a + o.servings, 0);
              head = (
                <div className="slot-head">
                  <span>{titles[m.slot]}</span>
                  <span>{plural(n, "serving")}</span>
                </div>
              );
            }
            return (
              <div key={m.recipe}>
                {head}
                <div className="meal">
                  <div className="row">
                    {m.image_url ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img className="shot" src={m.image_url} alt="" loading="lazy" />
                    ) : (
                      <span className="shot" />
                    )}
                    <span className="mult">{m.servings}×</span>
                    <span className="nm">{m.name}</span>
                    <span className="mac">
                      {Math.round(m.protein_per_serving)}g ·{" "}
                      {Math.round(m.kcal_per_serving)} kcal
                      <br />
                      {m.minutes} min
                    </span>
                  </div>
                </div>
              </div>
            );
          })}
          <p className="note">
            <b>{plan.protein_per_day.toFixed(0)}g</b> protein and{" "}
            <b>{plan.kcal_per_day.toFixed(0)}</b> kcal a day, averaged over{" "}
            {days === 1 ? "the day" : plural(days, "day")}. Cooked in batches.
          </p>
        </Scroller>
      ) : (
        <Scroller label="The shopping list">
          {[...byAisle.entries()]
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([aisle, lines]) => (
              <div key={aisle}>
                <div className="aisle">{aisle}</div>
                {[...lines]
                  .sort((a, b) => b.line_cost - a.line_cost)
                  .map((b) => (
                    <label
                      key={b.item}
                      className={ticked[b.item] ? "line ticked" : "line"}
                    >
                      <input
                        type="checkbox"
                        checked={!!ticked[b.item]}
                        onChange={(e) =>
                          setTicked({ ...ticked, [b.item]: e.target.checked })
                        }
                      />
                      <span className="lbl">
                        {b.name}
                        {b.qty_carry_over > 0 && (
                          <span className="pill carry">
                            {qty(b.qty_carry_over, b.unit)} carries
                          </span>
                        )}
                        {b.qty_wasted > 0 && (
                          <span className="pill waste">
                            {qty(b.qty_wasted, b.unit)} wasted
                          </span>
                        )}
                        <span className="qty">
                          {b.packs} × {qty(b.pack_size, b.unit)} @ {money(b.unit_price)}
                        </span>
                      </span>
                      <span className="amt">{money(b.line_cost)}</span>
                    </label>
                  ))}
              </div>
            ))}
          <div className="tally">
            <span className="l">In the trolley</span>
            <span className="tik n">
              {money(picked)} / {money(plan.spend)}
            </span>
          </div>
          <p className="note">
            Prices are seed estimates, <b>unverified</b>. Correcting one in the aisle
            writes a new price and re-solves.
          </p>
        </Scroller>
      )}

      <div className="cta">
        <button className="btn ghost" onClick={onRestart}>
          Start again
        </button>
      </div>
    </section>
  );
}
