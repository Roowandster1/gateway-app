import { Planner } from "@/components/Planner";

export default function Home() {
  return (
    <main className="max-w-[1080px] mx-auto px-5 pt-8 pb-16 w-full">
      <header className="flex flex-wrap items-baseline gap-x-4 gap-y-3 pb-4.5 mb-7 border-b-2 border-ink pb-4">
        <h1 className="text-[clamp(28px,4.5vw,40px)] font-bold tracking-[-0.025em]">
          Till Total
        </h1>
        <span className="font-mono text-[11px] uppercase tracking-[0.09em] px-2 py-0.5 border border-line rounded text-muted">
          Working title
        </span>
        <p className="text-sm text-muted max-w-[52ch]">
          Pick a shop, a length, a budget and a goal. Every number comes from the integer
          solver — nothing here is written by a language model.
        </p>
      </header>
      <div className="grid gap-9 items-start lg:grid-cols-[minmax(0,400px)_minmax(0,1fr)]">
        <Planner />
        <aside className="flex flex-col gap-5">
          <section className="bg-surface border border-line rounded-xl p-5">
            <h2 className="text-[15px] font-bold tracking-tight mb-1">
              Food is sold in packs, not grams
            </h2>
            <p className="text-[13px] text-muted leading-relaxed">
              A recipe needing 70g of lentils costs you a whole 99p bag. Cost is computed
              over whole packs bought, which is what forces a plan to reuse an ingredient
              rather than open a second one. That is an integer program, not a prompt.
            </p>
          </section>
          <section className="bg-surface border border-line rounded-xl p-5">
            <h2 className="text-[15px] font-bold tracking-tight mb-1">
              Leftovers split two ways
            </h2>
            <p className="text-[13px] text-muted leading-relaxed">
              Rice and oil carry over and make the next shop cheaper. Chicken and bread rot,
              and the objective is penalised for creating them. Anything that outlives the
              plan counts as an asset, not waste.
            </p>
          </section>
          <section className="bg-surface border border-line rounded-xl p-5">
            <h2 className="text-[15px] font-bold tracking-tight mb-1">
              When nothing fits, it says so
            </h2>
            <p className="text-[13px] text-muted leading-relaxed">
              An infeasible answer names the binding constraint and prices the cheapest week
              that would work. That is a real answer, not an error.
            </p>
          </section>
        </aside>
      </div>
    </main>
  );
}
