# DESIGN.md — Till Total

How this product should look and feel. `CLAUDE.md` says how to build it; this
says how to draw it. Every value here is in use in `apps/web/app/globals.css`
and `demo/template.html` — this file is the reasoning, not a wish list.

---

## 1. Visual theme & atmosphere

**A shelf-edge ticket, not a food magazine.**

The product's entire claim is that the number on the phone is the number at the
till. A glossy, marketed interface undermines that claim before the user reads a
word — it looks like something with an incentive. So the design is plain,
dense, and slightly utilitarian, drawing on the vernacular of supermarket
shelf-edge labels and till receipts: high contrast, tabular figures, aisle
headings, no decoration that isn't carrying information.

Density is medium-tight. This is a tool operated in a supermarket aisle with one
hand, not a page read on a sofa. Whitespace is used to separate *kinds* of
information, never to make the page feel expensive.

**Never mimic Aldi's or Tesco's branding.** The app names them as data; it must
not dress as them.

---

## 2. Colour palette & roles

A cool paper ground with a faint green bias — groceries, chiller light — against
a near-black with the same bias. One accent: a price-ticket amber, used only for
the interactive thing on screen.

### Light (the base; `:root`)

| Token | Hex | Role |
|---|---|---|
| `--ground` | `#F4F6F3` | page behind everything |
| `--surface` | `#FFFFFF` | cards, the phone frame |
| `--surface-2` | `#EDF0EC` | headers, inset rows, tab strip |
| `--surface-3` | `#E3E8E3` | slider track, hover |
| `--ink` | `#141A18` | primary text, the "buy" button |
| `--muted` | `#5D6B66` | secondary text, captions, axis-like labels |
| `--line` | `#DCE2DD` | every border and rule |
| `--accent` | `#E0A806` | the live control only — slider thumb, serving count |
| `--accent-ink` | `#3A2A00` | text on the accent |
| `--good` / `--good-bg` | `#1C7A57` / `#E3F1EA` | carry-over: an asset |
| `--warn` / `--warn-bg` | `#AF5227` / `#F7E9E1` | waste: dead money |
| `--bad` / `--bad-bg` | `#A32C2C` / `#F7E6E4` | infeasible, below the floor |

### Dark (re-stepped, never inverted)

`#0E1211` ground, `#161B19` surface, `#1E2523` / `#28312E` raised, `#E7EDE9`
ink, `#93A29C` muted, `#2A322F` line, `#F0BE3A` accent on `#241900`,
`#4FBE92`/`#122A22` good, `#E08A57`/`#2C1D14` warn, `#E5726F`/`#2E1717` bad.

### Cost-split segments — computed, not chosen

The stacked spend bar carries three categories. These were run through the
dataviz palette validator against **both** surfaces:

```
light  #2A5FA8 eaten   #1C7A57 cupboard   #B0512A wasted
dark   #5590D6 eaten   #35A87C cupboard   #D0733F wasted
```

Two earlier attempts failed outright: a neutral grey "eaten" tripped the chroma
floor (it read as grey, not as a category) and sat below the deuteranopia
separation threshold against the green. **Do not adjust these by eye. Re-run the
validator.**

Semantic colour (good / warn / bad) is a separate axis from the accent and is
never reused as "a fourth series".

---

## 3. Typography

Two families, two jobs.

- **Archivo** — all interface text. A grotesque with enough character to avoid
  the default-SaaS look, without being a display face.
- **IBM Plex Mono** — **every number, without exception.** Prices, pack counts,
  grams, calories, minutes, percentages, constraint names.

That split is the whole typographic idea: prose is prose, and data looks like
data. It is what makes a shopping list read like a receipt.

| Use | Size / weight |
|---|---|
| Page title | `clamp(28px, 4.5vw, 40px)` / 700 / `-0.025em` |
| Screen question | 23px / 600 / `-0.02em`, `text-wrap: balance` |
| Hero number | 31–42px / 600 mono, tabular |
| Body | 13–14px / 400 |
| Caption, note | 11.5–12.5px / muted |
| Eyebrow, aisle, slot | 10–11px mono, uppercase, `0.08em` tracking |

**Rules.** Every column of digits gets `font-variant-numeric: tabular-nums`.
Money is always `£0.00`, two decimals, never rounded to whole pounds. Running
text stays near 65 characters.

---

## 4. Component stylings

- **Choice card** — full-width, 12px radius, 1px `--line`. Selected takes an
  `--ink` border, `--surface-2` fill, and a 3px `--accent` inset rail on the
  left. Name 17px/600, detail 12.5px muted, a right-aligned mono figure.
- **Slider** — 5px `--surface-3` track, 26px `--accent` thumb with a 3px
  `--surface` ring. Always paired with a hero readout above and min/max labels
  below. A slider never appears without its current value in words.
- **Cost bar** — 15px tall, 4px radius, three segments with a **2px surface gap**
  between them. Every segment is named with its value and share in the key
  beneath, and the bar carries an `aria-label` spelling out the whole split.
- **Meal row** — 46–56px square photo, accent serving badge, name, right-aligned
  mono macros. Expands to reveal method steps.
- **Shopping line** — checkbox, name, a `carries over` / `wasted` pill, pack
  maths on a second line (`2 × 500g @ £0.45`), right-aligned line cost. Grouped
  under sticky mono aisle headings, closed by a 2px `--ink` rule above the total.
- **Floor note** — a left-rule callout. Neutral (`--muted`) when the budget
  works, `--bad` when it doesn't, and it always states the number.
- **Primary button** — `--ink` fill, `--ground` text, 10px radius, full width.
  One per screen. Secondary is the same shape, transparent, `--line` border.

---

## 5. Layout principles

The app is a **single 400px column** — a phone, framed at 26px radius, even on a
desktop, because that is where it is used. Beside it on wide screens sits an
explanatory rail; below 860px the rail stacks underneath and the frame goes
full-width.

Spacing runs on a 4px base, with 20–24px screen padding and 11–18px between
related rows. Groups are laid out with flex/grid `gap`, never per-element
margins. Any wide content scrolls inside its own container; the page body never
scrolls sideways.

Each onboarding screen holds exactly one decision, with its call to action
pinned to the bottom by `margin-top: auto`, so the button lands in the same
place on every screen.

---

## 6. Depth & elevation

Almost none. Borders do the work.

One real shadow exists — `0 18px 44px -18px` under the phone frame — plus a
hairline lift on the selected tab. No shadows on cards, rows, or buttons. In
dark mode the shadow deepens rather than the surfaces glowing.

---

## 7. Do's and don'ts

**Do**

- Show two numbers where one would mislead. Spend *and* what stays in the
  cupboard; the first-shop floor *and* the ongoing one. A single figure is how
  this product lies.
- State the blocker in plain English, then name the constraint in mono. An
  infeasible answer is a result, and it gets designed like one.
- Label price confidence. A seed price says `unverified` and stays saying it.
- Let numbers be ugly. £29.66 is £29.66.

**Don't**

- Don't encode anything in colour alone. Every coloured segment, pill, or status
  carries a label.
- Don't invert for dark mode. Re-step each token against the dark surface and
  re-validate.
- Don't define a colour only inside a media or `[data-theme]` block. Tokens live
  on bare `:root`; only their values change.
- Don't reuse a generic class name. `.bar` was already the phone's top bar, and
  its `align-items: center` silently collapsed the cost bar to zero height —
  invisible in the source, obvious only in the DOM.
- Don't style food photography as marketing. Overhead, plain crockery, natural
  light, no garnish. It should look like Tuesday.
- Don't spend the accent on decoration. If everything is amber, nothing is.

---

## 8. Responsive behaviour

One breakpoint that matters: **860px**, where the two-column grid becomes one.
The phone frame is `minmax(0, 400px)` above it and fluid below.

Touch targets are at least 44px in the aisle — checkboxes get a full-row label,
and the slider thumb is 26px. Scrollable panes are capped at 430px so the
primary button stays visible without scrolling. `prefers-reduced-motion` kills
every transition; the only animation is a 0.2s bar resize and a chevron rotate.

---

## 9. Agent prompt guide

Reusable prompts that stay on-system:

- *"Add a [screen] to Till Total. Use the tokens in `apps/web/app/globals.css`,
  Archivo for text and IBM Plex Mono for every number, one decision per screen
  with the primary button pinned to the bottom."*
- *"Show [quantity] as a stat. Two numbers if one would mislead. Money as £0.00
  in tabular mono."*
- *"Add a chart. Categorical colours must pass the dataviz validator against both
  surfaces; label every series; never rely on colour alone."*
- *"Handle the empty/failed state as a designed result: plain-English cause, the
  constraint named in mono, and the action that would fix it."*
