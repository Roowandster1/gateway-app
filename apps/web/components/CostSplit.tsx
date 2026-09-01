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
    <section className="split">
      <div className="hero">
        <span data-testid="spend" className="tik n">
          {money(plan.spend)}
        </span>
        <span className="l">
          At the till
          <br />
          for {period}
        </span>
      </div>

      <div
        className="costbar"
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
          />
        ))}
      </div>

      <div className="key-list">
        {parts.map((p) => (
          <div key={p.seg}>
            <i aria-hidden style={{ background: `var(--seg-${p.seg})` }} />
            <span className="nm">{p.key}</span>
            <b>{money(p.v)}</b>
            <span className="pc">{Math.round((p.v / total) * 100)}%</span>
          </div>
        ))}
      </div>

      <p className="caption">
        {cupboardShare >= 40
          ? "Most of this shop is stock you keep. The next one buys far less."
          : `Cupboard stock carries into the next ${periodNoun}. Only the perishable leftover is really wasted.`}
      </p>
    </section>
  );
}
