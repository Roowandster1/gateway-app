import type { Plan } from "@/lib/solver";

const money = (n: number) => `£${n.toFixed(2)}`;

/**
 * The money split, as one bar rather than three numbers.
 *
 * This is the product's whole argument made visible: a one-day shop is mostly
 * stock you still own tomorrow, and reporting only the till total reads as
 * "£15 for one day". Segment colours were validated against both surfaces with
 * the dataviz palette checker. Identity never rests on colour — every segment
 * is named with its value and share in the key, segments carry a 2px gap, and
 * the bar carries an aria-label spelling the split out.
 */
export function CostSplit({
  plan,
  period,
  periodNoun,
}: {
  plan: Plan;
  period: string;
  periodNoun: string;
}) {
  const parts = [
    { seg: "eaten", key: "Food you'll eat", v: plan.consumed_value },
    { seg: "cupboard", key: "Stays in the cupboard", v: plan.carry_over_value },
    { seg: "wasted", key: "Wasted", v: plan.wasted_value },
  ].filter((p) => p.v > 0.005);

  const total = plan.spend || 1;
  const cupboardShare = Math.round((plan.carry_over_value / total) * 100);

  return (
    <section className="mb-5">
      <div className="flex items-baseline gap-2.5 mb-3">
        <span
          data-testid="spend"
          className="font-mono text-[31px] font-semibold tracking-tight leading-none tabular-nums"
        >
          {money(plan.spend)}
        </span>
        <span className="text-xs text-muted">at the till, for {period}</span>
      </div>

      <div
        className="flex items-stretch h-[15px] gap-0.5 rounded"
        role="img"
        aria-label={`Of ${money(plan.spend)} spent, ${parts
          .map((p) => `${money(p.v)} ${p.key.toLowerCase()}`)
          .join(", ")}.`}
      >
        {parts.map((p) => (
          <span
            key={p.seg}
            title={`${p.key} ${money(p.v)}`}
            style={{ flex: `${p.v / total} 1 0`, background: `var(--seg-${p.seg})` }}
            className="block h-full min-w-[3px] rounded-sm"
          />
        ))}
      </div>

      <div className="flex flex-wrap gap-x-4 gap-y-1 mt-3">
        {parts.map((p) => (
          <div key={p.seg} className="flex items-center gap-2 text-xs text-muted">
            <i
              aria-hidden
              style={{ background: `var(--seg-${p.seg})` }}
              className="w-2.5 h-2.5 rounded-sm shrink-0"
            />
            {p.key}{" "}
            <b className="font-mono text-[12.5px] font-semibold text-ink tabular-nums">
              {money(p.v)}
            </b>
            <span className="font-mono text-[10.5px]">
              {Math.round((p.v / total) * 100)}%
            </span>
          </div>
        ))}
      </div>

      <p className="text-[11.5px] text-muted mt-3 leading-relaxed">
        {cupboardShare >= 40
          ? `Most of this shop is stock you keep. Rice, oil and tins do not run out with the ${periodNoun}, so the next shop buys far less.`
          : `Cupboard stock carries into the next ${periodNoun} and makes it cheaper. Only the perishable leftover is really wasted.`}
      </p>
    </section>
  );
}
