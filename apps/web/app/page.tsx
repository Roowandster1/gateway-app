import { Planner } from "@/components/Planner";

/**
 * Five short facts, not three paragraphs of prose. Each one is a claim the app
 * has to keep, so it is written as a spec line with a label — the same register
 * as the shelf tickets next to it.
 */
const FACTS: [string, React.ReactNode][] = [
  [
    "Packs",
    <>
      70g of lentils costs a whole 99p bag. Cost is counted over{" "}
      <b>whole packs bought</b>, which is what forces reuse.
    </>,
  ],
  [
    "Leftovers",
    <>
      Rice and oil <b>carry over</b>. Chicken and bread <b>rot</b>. The solver
      is penalised only for the second.
    </>,
  ],
  [
    "No fit",
    <>
      It returns <b>infeasible</b> and names the binding constraint. That is an
      answer.
    </>,
  ],
  [
    "Prices",
    <>
      Seed estimates with a source and a date, flagged <b>unverified</b>.
      Nothing is guessed.
    </>,
  ],
  [
    "The model",
    <>
      Writes cooking steps and nothing else. A checker rejects any step stating
      an amount.
    </>,
  ],
];

export default function Home() {
  return (
    <main className="wrap">
      <header className="masthead">
        <h1>Till Total</h1>
        <p>Meals for what you said you&apos;d spend.</p>
      </header>
      <div className="cols">
        <Planner />
        <aside className="side">
          {/* Collapsed by default: on a phone this sat under the app as a wall
                of text with no obvious job. It is proof, not chrome. */}
          <details className="card">
            <summary>
              Why this is not a chatbot<span className="mark">▶</span>
            </summary>
            <div className="body">
              <ul className="facts">
                {FACTS.map(([label, text]) => (
                  <li key={label}>
                    <span className="h">{label}</span>
                    <span>{text}</span>
                  </li>
                ))}
              </ul>
            </div>
          </details>
        </aside>
      </div>
    </main>
  );
}
