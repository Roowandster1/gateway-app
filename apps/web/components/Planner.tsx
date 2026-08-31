"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { CostSplit } from "@/components/CostSplit";
import { DAY_STOPS, GOALS, GOAL_ORDER, STORES, type GoalKey } from "@/lib/goals";
import type { Floor, Plan, SolveResult } from "@/lib/solver";

const STEPS = ["store", "days", "budget", "goal", "plan"] as const;
type Step = (typeof STEPS)[number];

const money = (n: number) => `£${n.toFixed(2)}`;
const plural = (n: number, w: string) => `${n} ${w}${n === 1 ? "" : "s"}`;

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

/** 19 budget stops spanning the measured floor, so the floor is always reachable. */
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
  const [budgetIx, setBudgetIx] = useState(9);
  // The floor is stored with the request it belongs to, so switching store,
  // length or goal makes the previous answer stale by derivation rather than by
  // clearing state inside an effect (which cascades renders).
  const [floorFor, setFloorFor] = useState<{ key: string; value: Floor } | null>(null);
  const [result, setResult] = useState<SolveResult | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState<"food" | "shop">("food");
  const [ticked, setTicked] = useState<Record<string, boolean>>({});

  const targets = GOALS[goal];
  const floorKey = `${store}|${days}|${goal}`;
  const floor = floorFor?.key === floorKey ? floorFor.value : null;

  const stops = useMemo(() => budgetStops(floor, days), [floor, days]);
  const budget = stops[Math.min(budgetIx, stops.length - 1)];

  const body = useCallback(
    (over: Record<string, unknown> = {}) => ({
      store,
      days,
      budget,
      min_protein_per_day: targets.protein,
      kcal_band: targets.kcal,
      ...over,
    }),
    [store, days, budget, targets],
  );

  // The floor is fetched before a budget is chosen, so the slider can show what
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
      .then((r) => r.json())
      .then((value: Floor) => {
        if (!live) return;
        setFloorFor({ key: floorKey, value });
        setError(null);
      })
      .catch(() => live && setError("Could not reach the solver."));
    return () => {
      live = false;
    };
  }, [floorKey, store, days, targets]);

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
      const data = (await res.json()) as SolveResult;
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

  return (
    <div className="bg-surface border border-line rounded-[26px] overflow-hidden flex flex-col min-h-[720px] shadow-[0_18px_44px_-18px_rgb(20_26_24/0.14)]">
      <header className="flex items-center gap-2.5 px-4 py-3.5 border-b border-line bg-surface-2 min-h-[52px]">
        {ix > 0 && (
          <button
            onClick={() => setStep(STEPS[ix - 1])}
            aria-label="Go back"
            className="text-lg leading-none px-1.5 py-1 rounded opacity-75 hover:opacity-100 hover:bg-surface-3"
          >
            ←
          </button>
        )}
        <span className="font-mono text-[11px] uppercase tracking-[0.08em] text-muted">
          {ix < 4 ? `Step ${ix + 1} of 4` : plan ? "Your plan" : "No plan"}
        </span>
        <div className="flex gap-1.5 ml-auto">
          {STEPS.slice(0, 4).map((s, i) => (
            <span
              key={s}
              className={`w-1.5 h-1.5 rounded-full ${
                i === ix ? "bg-ink" : i < ix ? "bg-muted" : "bg-line"
              }`}
            />
          ))}
        </div>
      </header>

      <div className="px-5 pt-6 pb-6 flex-1 flex flex-col">
        {step === "store" && (
          <Screen
            q="Where do you shop?"
            sub="Prices differ enough between the two to change what a week can contain."
            cta="Continue"
            onNext={() => setStep("days")}
          >
            {STORES.map((s) => (
              <Choice
                key={s.slug}
                selected={store === s.slug}
                onClick={() => setStore(s.slug)}
                name={s.name}
                detail="UK · 28 items priced"
                aside={floor?.first && store === s.slug ? `from ${money(floor.first)}` : undefined}
              />
            ))}
          </Screen>
        )}

        {step === "days" && (
          <Screen
            q="How far ahead?"
            sub="Anything from a single day to a fortnight. Short plans still buy whole packs, so most of a one-day shop stays in your cupboard."
            cta="Continue"
            onNext={() => setStep("budget")}
          >
            <Readout
              value={days % 7 === 0 ? `${days / 7}` : `${days}`}
              unit={days % 7 === 0 ? (days === 7 ? "week" : "weeks") : days === 1 ? "day" : "days"}
              note={
                days === 14
                  ? `${plural(days * 3, "meal")}. Planned as two shops a week apart, so nothing fresh has to survive a fortnight.`
                  : days <= 2
                    ? `${plural(days * 3, "meal")}. Short plans still buy whole packs, so most of this shop is stock you keep.`
                    : `${plural(days * 3, "meal")}. One shop.`
              }
            />
            <input
              type="range"
              min={0}
              max={DAY_STOPS.length - 1}
              value={DAY_STOPS.indexOf(days)}
              aria-label="Plan length"
              onChange={(e) => setDays(DAY_STOPS[+e.target.value])}
              className="w-full my-3"
            />
            <Scale lo="1 day" hi="2 weeks" />
          </Screen>
        )}

        {step === "budget" && (
          <Screen
            q="What's the budget?"
            sub="The floor is real: below it, no combination of packs meets the nutrition targets at this shop."
            cta="Continue"
            onNext={() => setStep("goal")}
          >
            <Readout
              value={money(budget)}
              note={`For one person across ${days === 1 ? "one day" : plural(days, "day")} at ${
                STORES.find((s) => s.slug === store)?.name
              }.`}
            />
            <input
              type="range"
              min={0}
              max={stops.length - 1}
              value={Math.min(budgetIx, stops.length - 1)}
              aria-label="Budget"
              onChange={(e) => setBudgetIx(+e.target.value)}
              className="w-full my-3"
            />
            <Scale lo={money(stops[0])} hi={money(stops[stops.length - 1])} />
            <FloorNote floor={floor} budget={budget} days={days} store={store} />
          </Screen>
        )}

        {step === "goal" && (
          <Screen
            q="What are you eating for?"
            sub="These set the calorie band and the protein floor. They are constraints, not suggestions — the solver refuses rather than under-feed you."
            cta={busy ? "Solving…" : "Build the plan"}
            onNext={buildPlan}
            disabled={busy}
          >
            {GOAL_ORDER.map((g) => (
              <Choice
                key={g}
                selected={goal === g}
                onClick={() => setGoal(g)}
                name={GOALS[g].label}
                detail={`${GOALS[g].kcal[0]}–${GOALS[g].kcal[1]} kcal a day`}
                aside={`${GOALS[g].protein}g protein`}
              />
            ))}
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
          <p className="mt-4 text-xs text-bad bg-bad-bg border border-bad/30 rounded-lg px-3 py-2">
            {error} Is the solver running on port 8000?
          </p>
        )}
      </div>
    </div>
  );
}

/* ---------- pieces ---------- */

function Screen({
  q,
  sub,
  cta,
  onNext,
  disabled,
  children,
}: {
  q: string;
  sub: string;
  cta: string;
  onNext: () => void;
  disabled?: boolean;
  children: React.ReactNode;
}) {
  return (
    <>
      <h2 className="text-[23px] font-semibold tracking-tight mb-1.5 text-balance">{q}</h2>
      <p className="text-[13.5px] text-muted mb-5">{sub}</p>
      <div className="flex flex-col gap-2.5">{children}</div>
      <div className="mt-auto pt-5">
        <button
          onClick={onNext}
          disabled={disabled}
          className="w-full text-[15.5px] font-semibold py-3.5 rounded-[10px] bg-ink text-ground hover:opacity-90 disabled:opacity-50 focus-visible:outline-2 focus-visible:outline-accent"
        >
          {cta}
        </button>
      </div>
    </>
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
  aside?: string;
}) {
  return (
    <button
      onClick={onClick}
      aria-pressed={selected}
      className={`text-left w-full flex items-center gap-3.5 px-4 py-4 rounded-xl border transition-colors focus-visible:outline-2 focus-visible:outline-accent ${
        selected
          ? "border-ink bg-surface-2 shadow-[inset_3px_0_0_var(--accent)]"
          : "border-line bg-surface hover:border-muted hover:bg-surface-2"
      }`}
    >
      <span>
        <span className="block text-[17px] font-semibold tracking-tight">{name}</span>
        <span className="block text-[12.5px] text-muted mt-0.5">{detail}</span>
      </span>
      {aside && (
        <span className="ml-auto font-mono text-[12.5px] text-muted text-right whitespace-nowrap">
          {aside}
        </span>
      )}
    </button>
  );
}

function Readout({ value, unit, note }: { value: string; unit?: string; note?: string }) {
  return (
    <>
      <div className="font-mono text-[42px] font-semibold tracking-tight leading-none tabular-nums mt-2 mb-1">
        {value}
        {unit && <span className="text-xl text-muted font-normal"> {unit}</span>}
      </div>
      {note && <p className="text-[13px] text-muted min-h-[38px] mb-2">{note}</p>}
    </>
  );
}

function Scale({ lo, hi }: { lo: string; hi: string }) {
  return (
    <div className="flex justify-between font-mono text-[11px] text-muted">
      <span>{lo}</span>
      <span>{hi}</span>
    </div>
  );
}

function FloorNote({
  floor,
  budget,
  days,
  store,
}: {
  floor: Floor | null;
  budget: number;
  days: number;
  store: string;
}) {
  const name = STORES.find((s) => s.slug === store)?.name ?? store;
  if (!floor) {
    return <p className="mt-4 text-[12.5px] text-muted">Working out the floor…</p>;
  }
  if (floor.first === null) {
    return (
      <p className="mt-4 px-3 py-2.5 rounded-lg text-[12.5px] bg-bad-bg border-l-[3px] border-bad text-bad">
        No budget works for these targets here. The targets themselves have to move.
      </p>
    );
  }
  const under = budget < floor.first;
  return (
    <>
      <p
        className={`mt-4 px-3 py-2.5 rounded-lg text-[12.5px] border-l-[3px] ${
          under ? "bg-bad-bg border-bad text-bad" : "bg-surface-2 border-muted text-muted"
        }`}
      >
        {under ? (
          <>
            Not possible at {name} from an empty cupboard. The cheapest first shop is{" "}
            <b className="font-mono">{money(floor.first)}</b>.
          </>
        ) : (
          <>
            Cheapest first shop here: <b className="font-mono">{money(floor.first)}</b>
            {floor.ongoing !== null && (
              <>
                , then about <b className="font-mono">{money(floor.ongoing)}</b> a{" "}
                {periodNoun(days)}
              </>
            )}
            .
          </>
        )}
      </p>
      {floor.ongoing !== null && (
        <p className="text-[11.5px] text-muted mt-3 leading-relaxed">
          {under
            ? `Once your cupboard is stocked the same ${periodNoun(days)} costs about ${money(floor.ongoing)}, so this budget works from your second shop on.`
            : "The first shop is dearer because it stocks the cupboard. Rice, oil and tins carry over, so later shops buy far less."}
        </p>
      )}
    </>
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
      <>
        <div className="border border-bad bg-bad-bg rounded-xl p-4.5 mb-4 px-4 py-4">
          <h3 className="text-[16.5px] text-bad font-semibold mb-2">
            {result.min_feasible_budget !== null
              ? "That budget doesn't exist here"
              : "This one can't be done"}
          </h3>
          <p className="text-[13.5px] leading-relaxed mb-3">{result.suggestion}</p>
          <p className="flex flex-wrap gap-1">
            {[result.binding, ...result.also_binding].map((b) => (
              <span
                key={b}
                className="font-mono text-[11px] bg-surface border border-line rounded px-1.5 py-0.5"
              >
                {b}
              </span>
            ))}
          </p>
        </div>
        {result.min_feasible_budget !== null && (
          <button
            onClick={() => onUseFloor(result.min_feasible_budget!)}
            className="w-full text-[15.5px] font-semibold py-3.5 rounded-[10px] bg-ink text-ground hover:opacity-90"
          >
            Use {money(result.min_feasible_budget)} instead
          </button>
        )}
        <p className="text-[11.5px] text-muted mt-4 pt-3 border-t border-line leading-relaxed">
          This is the answer, not a failure. The solver proved no set of whole packs meets
          the targets, so it names what blocked it rather than quietly serving you a worse
          week.
        </p>
        <div className="mt-auto pt-5">
          <button
            onClick={onRestart}
            className="w-full text-[15.5px] font-semibold py-3.5 rounded-[10px] border border-line hover:bg-surface-2"
          >
            Start again
          </button>
        </div>
      </>
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
  for (const line of plan.basket.filter((b) => b.packs > 0)) {
    if (!byAisle.has(line.aisle)) byAisle.set(line.aisle, []);
    byAisle.get(line.aisle)!.push(line);
  }
  const picked = plan.basket
    .filter((b) => b.packs > 0 && ticked[b.item])
    .reduce((a, b) => a + b.line_cost, 0);

  return (
    <>
      <CostSplit
        plan={plan}
        period={periodWord(days)}
        periodNoun={periodNoun(days)}
      />

      <div className="flex gap-1 bg-surface-2 p-1 rounded-[9px] mb-4">
        {(["food", "shop"] as const).map((t) => (
          <button
            key={t}
            role="tab"
            aria-selected={tab === t}
            onClick={() => setTab(t)}
            className={`flex-1 text-[13px] font-semibold py-2 rounded-[7px] ${
              tab === t ? "bg-surface text-ink shadow-sm" : "text-muted"
            }`}
          >
            {t === "food" ? "The food" : "Shopping list"}
          </button>
        ))}
      </div>

      {tab === "food" ? (
        <div className="flex-1 overflow-y-auto max-h-[430px]">
          {meals.map((m) => {
            let head = null;
            if (!seen.has(m.slot)) {
              seen.add(m.slot);
              const n = meals
                .filter((o) => o.slot === m.slot)
                .reduce((a, o) => a + o.servings, 0);
              head = (
                <div className="flex justify-between items-baseline font-mono text-[10px] uppercase tracking-[0.09em] text-muted pt-4 pb-1.5">
                  {titles[m.slot]}
                  <span>{plural(n, "serving")}</span>
                </div>
              );
            }
            return (
              <div key={m.recipe}>
                {head}
                <div className="flex gap-3 items-baseline py-2.5 border-b border-line last:border-0">
                  <span className="font-mono text-[13px] font-semibold bg-accent text-accent-ink rounded px-1.5 py-0.5 shrink-0">
                    {m.servings}×
                  </span>
                  <span className="flex-1 text-sm font-medium tracking-tight">{m.name}</span>
                  <span className="font-mono text-[11px] text-muted text-right whitespace-nowrap tabular-nums">
                    {Math.round(m.protein_per_serving)}g · {Math.round(m.kcal_per_serving)} kcal
                    <br />
                    {m.minutes} min
                  </span>
                </div>
              </div>
            );
          })}
          <p className="text-[11.5px] text-muted mt-3.5 pt-3 border-t border-line leading-relaxed">
            {plan.protein_per_day.toFixed(0)}g protein and {plan.kcal_per_day.toFixed(0)} kcal
            a day, averaged over {days === 1 ? "the day" : plural(days, "day")}.
          </p>
        </div>
      ) : (
        <div className="flex-1 overflow-y-auto max-h-[430px]">
          {[...byAisle.entries()]
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([aisle, lines]) => (
              <div key={aisle}>
                <div className="font-mono text-[10px] uppercase tracking-[0.09em] text-muted pt-3.5 pb-1.5 border-b border-line sticky top-0 bg-surface">
                  {aisle}
                </div>
                {[...lines]
                  .sort((a, b) => b.line_cost - a.line_cost)
                  .map((b) => (
                    <label
                      key={b.item}
                      className={`flex gap-2.5 items-baseline py-2.5 border-b border-line cursor-pointer ${
                        ticked[b.item] ? "opacity-45" : ""
                      }`}
                    >
                      <input
                        type="checkbox"
                        checked={!!ticked[b.item]}
                        onChange={(e) =>
                          setTicked({ ...ticked, [b.item]: e.target.checked })
                        }
                        className="w-[15px] h-[15px] shrink-0 relative top-0.5 accent-[var(--good)]"
                      />
                      <span className={`flex-1 ${ticked[b.item] ? "line-through" : ""}`}>
                        <span className="text-[13.5px] tracking-tight">{b.name}</span>
                        {b.qty_carry_over > 0 && (
                          <span className="inline-block font-mono text-[9.5px] px-1.5 py-px rounded-sm ml-1.5 bg-good-bg text-good no-underline">
                            {qty(b.qty_carry_over, b.unit)} carries over
                          </span>
                        )}
                        {b.qty_wasted > 0 && (
                          <span
                            className="inline-block font-mono text-[9.5px] px-1.5 py-px rounded-sm ml-1.5 no-underline"
                            style={{ background: "var(--warn-bg)", color: "var(--warn)" }}
                          >
                            {qty(b.qty_wasted, b.unit)} wasted
                          </span>
                        )}
                        <span className="block font-mono text-[11px] text-muted mt-px no-underline">
                          {b.packs} × {qty(b.pack_size, b.unit)} @ {money(b.unit_price)}
                        </span>
                      </span>
                      <span className="font-mono text-[13px] font-semibold tabular-nums whitespace-nowrap">
                        {money(b.line_cost)}
                      </span>
                    </label>
                  ))}
              </div>
            ))}
          <div className="flex justify-between items-baseline mt-4 pt-3.5 border-t-2 border-ink font-mono font-semibold">
            <span className="text-[11px] uppercase tracking-[0.07em] font-medium text-muted">
              In the trolley
            </span>
            <span className="text-[21px] tabular-nums tracking-tight">
              {money(picked)} / {money(plan.spend)}
            </span>
          </div>
          <p className="text-[11.5px] text-muted mt-3.5 pt-3 border-t border-line leading-relaxed">
            Prices are seed estimates, <b>unverified</b>. Correcting one in the aisle writes
            a new price and re-solves.
          </p>
        </div>
      )}

      <div className="mt-auto pt-5">
        <button
          onClick={onRestart}
          className="w-full text-[15.5px] font-semibold py-3.5 rounded-[10px] border border-line hover:bg-surface-2"
        >
          Start again
        </button>
      </div>
    </>
  );
}
