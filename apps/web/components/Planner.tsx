"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { CostSplit } from "@/components/CostSplit";
import { DAY_STOPS, GOALS, GOAL_ORDER, STORES, type GoalKey } from "@/lib/goals";
import type { Floor, Plan, SolveResult, SolverError } from "@/lib/solver";

const STEPS = ["store", "days", "budget", "goal", "plan"] as const;
type Step = (typeof STEPS)[number];

const STEP_NAMES: Record<Step, string> = {
  store: "Where you shop",
  days: "How long for",
  budget: "The budget",
  goal: "What you're eating for",
  plan: "Your plan",
};

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

export function Planner() {
  const [step, setStep] = useState<Step>("store");
  const [store, setStore] = useState("aldi");
  const [days, setDays] = useState(7);
  const [goal, setGoal] = useState<GoalKey>("maintain");
  // The budget is punched in, not dragged. A slider has to invent a range
  // before the floor is known, and its ends are a claim about what is possible
  // that the solver has not made yet. A keypad claims nothing and takes any
  // number, so "people get by on far less than £25" is simply true here.
  const [budgetInput, setBudgetInput] = useState("");
  const budgetTouched = useRef(false);
  // `value: null` means the request was made and the solver could not answer.
  // That is a different state from "not asked yet" and the UI must not show
  // the same "working it out…" line for both.
  const [floorFor, setFloorFor] = useState<{ key: string; value: Floor | null } | null>(
    null,
  );
  const [result, setResult] = useState<SolveResult | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState<"food" | "shop">("food");
  const [ticked, setTicked] = useState<Record<string, boolean>>({});

  const targets = GOALS[goal];
  const floorKey = `${store}|${days}|${goal}`;
  const floorEntry = floorFor?.key === floorKey ? floorFor : null;
  const floor = floorEntry?.value ?? null;
  const floorUnavailable = floorEntry !== null && floorEntry.value === null;

  const budget = budgetInput === "" ? null : parseInt(budgetInput, 10);

  const body = useCallback(
    (over: Record<string, unknown> = {}) => ({
      store,
      days,
      budget: budget ?? 0,
      min_protein_per_day: targets.protein,
      kcal_band: targets.kcal,
      ...over,
    }),
    [store, days, budget, targets],
  );

  // The floor is fetched before a budget is chosen, so the screen can say what
  // is actually possible instead of letting someone pick an impossible number.
  useEffect(() => {
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
        // Seed the keypad with a round number clear of the floor, but only
        // until the first keypress — after that the figure is theirs.
        if (!budgetTouched.current && value.first !== null) {
          setBudgetInput(String(Math.ceil((value.first * 1.25) / 5) * 5));
        }
      })
      .catch(() => {
        if (!live) return;
        setFloorFor({ key: floorKey, value: null });
        setError("Could not reach the solver.");
      });
    return () => {
      live = false;
    };
  }, [floorKey, store, days, targets]);

  const punch = useCallback((k: string) => {
    budgetTouched.current = true;
    setTicked({});
    setBudgetInput((prev) => {
      if (k === "clear") return "";
      if (k === "del") return prev.slice(0, -1);
      if (prev.length >= 3) return prev;
      // No leading zeros: "0" then "5" is £5, not £05.
      return (prev === "0" ? "" : prev) + k;
    });
  }, []);

  // The keypad is a real control, so a real keyboard drives it too.
  useEffect(() => {
    if (step !== "budget") return;
    const onKey = (e: KeyboardEvent) => {
      if (e.metaKey || e.ctrlKey || e.altKey) return;
      if (/^[0-9]$/.test(e.key)) {
        punch(e.key);
        e.preventDefault();
      } else if (e.key === "Backspace") {
        punch("del");
        e.preventDefault();
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [step, punch]);

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

  const ix = STEPS.indexOf(step);
  const plan = result?.status === "ok" ? (result as Plan) : null;
  const storeName = STORES.find((s) => s.slug === store)?.name ?? store;

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
          {ix < 4 ? `0${ix + 1}/04` : plan ? "SOLVED" : "NO FIT"}
        </span>
      </div>
      {ix < 4 && (
        <div className="rail">
          {[0, 1, 2, 3].map((i) => (
            <i key={i} className={i <= ix ? "on" : undefined} />
          ))}
        </div>
      )}

      {step === "store" && (
        <Screen eyebrow="Step one" q="Where do you shop?" cta="Continue" onNext={() => setStep("days")}>
          <div className="choices">
            {STORES.map((s) => (
              <Choice
                key={s.slug}
                selected={store === s.slug}
                onClick={() => setStore(s.slug)}
                name={s.name}
                detail="28 items priced"
                aside={
                  floor?.first && store === s.slug ? (
                    <>
                      from {money(floor.first)}
                      <br />a {periodNoun(days)}
                    </>
                  ) : undefined
                }
              />
            ))}
          </div>
        </Screen>
      )}

      {step === "days" && (
        <Screen eyebrow="Step two" q="How long for?" cta="Continue" onNext={() => setStep("budget")}>
          <div className="chips">
            {DAY_STOPS.map((d) => {
              const whole = d % 7 === 0;
              return (
                <button
                  key={d}
                  className="chip"
                  aria-pressed={days === d}
                  onClick={() => {
                    setDays(d);
                    setTicked({});
                  }}
                >
                  <span className="tik n">{whole ? d / 7 : d}</span>
                  <span className="u">
                    {whole ? (d === 7 ? "week" : "weeks") : d === 1 ? "day" : "days"}
                  </span>
                </button>
              );
            })}
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
          eyebrow="Step three"
          q="What's the budget?"
          cta="Continue"
          disabled={budget === null}
          onNext={() => setStep("goal")}
        >
          <div className="amount">
            <span className="tik big">{budget === null ? "£—" : `£${budget}`}</span>
            <span className="rt lab">
              For one
              <br />
              at {storeName}
              <br />
              {days === 1 ? "1 day" : plural(days, "day")}
            </span>
          </div>
          <Keypad onPunch={punch} />
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
          eyebrow="Step four"
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
            budgetTouched.current = true;
            setBudgetInput(String(Math.ceil(b)));
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
  cta,
  onNext,
  disabled,
  children,
}: {
  eyebrow: string;
  q: string;
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
      {children}
      <div className="cta">
        <button className="btn" onClick={onNext} disabled={disabled}>
          {cta}
        </button>
      </div>
    </section>
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

const KEYS = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "clear", "0", "del"];

function Keypad({ onPunch }: { onPunch: (k: string) => void }) {
  return (
    <div className="pad">
      {KEYS.map((k) => (
        <button
          key={k}
          className={k === "clear" || k === "del" ? "key fn" : "key"}
          onClick={() => onPunch(k)}
          aria-label={k === "del" ? "Delete last digit" : undefined}
        >
          {k === "clear" ? "Clear" : k === "del" ? "Del" : k}
        </button>
      ))}
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
  budget: number | null;
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
  const under = budget !== null && budget < floor.first;
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
