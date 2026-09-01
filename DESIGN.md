# DESIGN.md — Till Total

How this product should look and feel. `CLAUDE.md` says how to build it; this
says how to draw it. Every value here is in use in `apps/web/app/globals.css`
and `demo/template.html` — this file is the reasoning, not a wish list.

The two files carry the **same rules**: `globals.css` is generated from the demo
template's style block, so the shipped app and the demo cannot drift apart.

---

## 1. Visual theme & atmosphere

**Quiet surface, loud numbers.**

The product's entire claim is that the number on the phone is the number at the
till. A glossy, marketed interface undermines that claim before the user reads a
word — it looks like something with an incentive. So the surface stays quiet:
light paper, hairline rules, soft corners, one brand colour. The character comes
from the **content** — condensed ticket numerals for prices, monospaced receipt
data, aisle groupings, honest labels — not from the chrome.

Density is medium-tight. This is a tool operated in a supermarket aisle with one
hand, not a page read on a sofa. Whitespace separates *kinds* of information; it
never makes the page feel expensive.

**Two failed passes are recorded here, because both are instructive.**

1. *The sage wellness app.* Soft off-white ground, grey-green surfaces, 26px
   radii, a blurred drop shadow under a floating card, essayistic sub-copy under
   every heading. That combination — pastel neutrals, rounded everything, soft
   shadow, explanatory prose — is the house style of machine-generated
   interfaces, and it read as one.
2. *The over-correction.* Hard 1.5px black borders on everything, reversed-out
   black bars for every heading, a full-bleed black masthead and a saturated
   price-flash yellow. Owner's verdict: **"too blocky, weird colours."** Fixing
   "it looks generated" by making it shout is not fixing it.

The landing point is between them: light and calm, with the interest carried by
type and data density. **Do not swing again.**

**Never mimic Aldi's or Tesco's branding.** The app names them as data; it must
not dress as them.

---

## 2. Colour palette & roles

Light paper on a barely-tinted ground, near-black ink, hairline rules, and one
brand colour that carries selection, the primary action, and the filled part of
a slider. Nothing else is coloured.

### Light (the base; `:root`)

| Token | Hex | Role |
|---|---|---|
| `--board` | `#F2F4F1` | the page behind the card |
| `--paper` | `#FFFFFF` | the app card, and every panel |
| `--paper-2` | `#F6F7F5` | inset fills: aisle chips, slot headings, the floor note |
| `--ink` | `#16181C` | primary text |
| `--ink-2` | `#5E626C` | secondary text, mono labels, units |
| `--rule` | `#E3E5E4` | every border and hairline |
| `--accent` | `#12805A` | selection, primary button, slider fill. **Never decoration** |
| `--soft` | `#E3F2EB` | the accent's tint: selected row, serving badge |
| `--on-accent` | `#FFFFFF` | text on the accent |
| `--red` / `--red-bg` | `#C4342E` / `#FBEBEA` | below the floor, infeasible, solver down |
| `--green` | `#12805A` | carry-over: an asset, not waste |

### Dark (re-stepped, never inverted)

`#0D0E10` board, `#16181B` paper, `#1E2125` inset, `#EDEEF0` ink, `#9AA0A9`
secondary, `#2A2D32` rule, `#3DBE8C` accent on `#122A22`, `#F0736C`/`#2B1514`
red.

### The accent is not settled yet

`demo/template.html` carries a **palette picker** — green, blue, orange, violet —
switchable at runtime via `[data-palette]` on the root, persisted in
`localStorage`. It exists so the owner can choose rather than be guessed at. It
is a decision aid, not a product feature: once a colour is picked, the picker
comes out and the app ships one palette. `apps/web` already ships only the
default.

### Cost-split segments — computed, not chosen

The stacked spend bar carries three categories, validated with the dataviz
palette checker against **both** surfaces. They are unchanged through the
redesign because the surface they sit on is still `#FFFFFF` / `#111110`:

```
light  #2A5FA8 eaten   #1C7A57 cupboard   #B0512A wasted
dark   #5590D6 eaten   #35A87C cupboard   #D0733F wasted
```

Two earlier attempts failed outright: a neutral grey "eaten" tripped the chroma
floor (it read as grey, not as a category) and sat below the deuteranopia
separation threshold against the green. **Do not adjust these by eye. Re-run the
validator.**

---

## 3. Typography

Two families, three jobs.

- **Archivo**, loaded **as a variable font with its width axis** (`wdth`
  62–125). Interface text sits at normal width; every price a shopper reads at a
  glance is set at `wdth 82 / wght 750` — the `.tik` class — which is how a
  ticket is printed.
- **IBM Plex Mono** — small print and spec data. Pack maths, macros, aisle
  headings, constraint names, the solver readout.

The split: **ticket numerals for prices, mono for receipt data, Archivo for
prose.** A price is something you read across a room; a pack size is something
you read in your hand.

> The width axis is load-bearing. Without it the numerals silently fall back to
> a normal-width face and the whole system quietly stops working — which is
> exactly what happened the first time, because the Google Fonts stylesheet
> never loaded and nothing said so. The demo now carries both faces as inlined
> woff2 data URIs; the app loads them through `next/font` with
> `axes: ["wdth"]`.

| Use | Size / weight |
|---|---|
| Masthead | 25px / 700 / `-0.03em` |
| Screen question | 25px / 700 / `-0.03em` |
| Hero price / slider readout | 50–52px `.tik` |
| Body | 12.5–14.5px / 400–600 |
| Mono labels, aisles, eyebrows | **10.5px minimum**, uppercase, `0.09–0.10em` |

**Rules.** Every column of digits gets `font-variant-numeric: tabular-nums`.
Money in a list or a total is `£0.00`, two decimals; a slider readout drops a
trailing `.00`, because nobody sets a budget of £29.00.

**Nothing renders below 10.5px.** A pass briefly shipped 9–9.5px tracked caps;
they are unreadable on a phone and were caught only by measuring the smallest
rendered text in the DOM. Check it, don't eyeball it.

---

## 4. Component stylings

- **The card** — the whole app is one `1px --rule` panel on `--board`, 14px
  radius, `min-height: 566px`. No shadow.
- **Top bar** — light, ruled off below: back arrow, step name in mono caps,
  `3 of 4` on the right. Under it a four-segment progress rail in the accent,
  hidden once the plan is on screen.
- **Choice row** — full-width, 11px radius, `1.5px --rule`. Selected takes an
  accent border and the `--soft` tint. Name 18px/700, detail 12.5px, a
  right-aligned mono figure.
- **Slider** — 8px rounded track filled to the value, 28px thumb ringed in the
  accent. Always paired with a `.tik` readout above and min/max below. The days
  slider steps through six stops (1, 2, 3, 5 days, 1, 2 weeks); the budget
  slider steps through 19 and carries the floor pin.
- **Cost bar** — 14px tall, pill-rounded, three segments with a **2px gap**. Every segment is named with its value and share in the key
  beneath, and the bar carries an `aria-label` spelling out the whole split.
- **Meal row** — 50px rounded photo, a `--soft` serving badge in mono, name,
  right-aligned mono macros.
- **Shopping line** — checkbox, name, an outlined `carries` / `wasted` pill,
  pack maths on a second line (`2 × 500g @ £0.45`), right-aligned line cost.
  Grouped under sticky `--paper-2` aisle chips, closed by a rule above the
  total.
- **Floor note** — a 4px left-rule block. `--ink` when the budget works, `--red`
  when it doesn't, and it always states the number.
- **Primary button** — solid `--accent`, 11px radius, full width, sentence case.
  One per screen, pinned to the bottom. Secondary is the same shape in
  `--paper` with a `--rule` border.

**Sliders, with the floor pinned on the track.** A slider was briefly replaced
with a keypad on the theory that its two ends are a claim about what is possible
that the solver has not made. The owner asked for the sliders back, and he is
right — the problem was never the control, it was the *range*. The old build
started it at £25 and implied that was the minimum; it now runs from half the
measured floor to two and a half times it, so £10 is reachable at Aldi and
simply comes back as infeasible with the real floor attached. The measured floor
is drawn as a pin on the track, because it is a solved number and belongs on the
control rather than only in a sentence underneath.

---

## 5. Layout principles

The app is a **single ~400px column** — a phone, even on a desktop, because that
is where it is used. Beside it on wide screens sits the proof panel, **collapsed by default**: on a
phone it stacked underneath as a wall of text with no obvious job, which read as
debris rather than evidence. It is a `<details>` you open when you want it.

Spacing runs on a 4px base, with 18–20px screen padding and 7–12px between
related rows. Groups are laid out with flex/grid `gap`, never per-element
margins. Any wide content scrolls inside its own container; the page body never
scrolls sideways.

Each onboarding screen holds exactly one decision, with its call to action
pinned to the bottom by `margin-top: auto`, so the button lands in the same
place on every screen.

---

## 6. Depth & elevation

Almost none. Hairline rules and light fills do the work. The only shadows in the
system are a 1px lift under the selected tab and a soft ring under the slider
thumb, both barely visible — they say "this is grabbable", not "this is
expensive". No shadow on the app card, on rows, or on buttons.

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
- Keep sub-copy to one short line, or cut it. A heading that needs a paragraph
  under it is a heading that hasn't been written yet.

**Don't**

- Don't encode anything in colour alone. Every coloured segment, pill or status
  carries a label.
- Don't spend the accent on decoration. It marks selection, the primary action,
  and the filled part of a slider. Nothing else.
- Don't reach for heavy black slabs, hard square corners or a saturated accent
  to look "designed". That was the over-correction, and it reads as brutalist,
  not honest.
- Don't invert for dark mode. Re-step each token against the dark surface and
  re-validate.
- Don't define a colour only inside a media or `[data-theme]` block. Tokens live
  on bare `:root`; only their values change.
- Don't reuse a generic class name. `.bar` was already the phone's top bar, and
  its `align-items: center` silently collapsed the cost bar to zero height —
  invisible in the source, obvious only in the DOM. It is `.topbar` and
  `.costbar` now.
- Don't depend on a webfont stylesheet you cannot verify. If the face carries a
  variable axis the design needs, self-host it and check the rendered width.
- Don't style food photography as marketing. Overhead, plain crockery, natural
  light, no garnish. It should look like Tuesday.
- Don't render a failed fetch as if it were data. A 502 body is not a `Floor`;
  storing it put `undefined` where a number belonged and the budget screen died
  on the first `money()` call. Narrow on the response's shape, then say the
  solver is down in the place the number would have been.

---

## 8. Responsive behaviour

One breakpoint that matters: **860px**, where the two-column grid becomes one.
The ticket is `minmax(0, 398px)` above it and fluid below. Verified clean at
320 / 360 / 414px and at the 195px 200%-zoom equivalent.

Touch targets are at least 24px, and in practice 44px+ in the aisle — checkboxes
get a full-row label and the slider thumb is 28px in a 30px row. Scrollable panes
are capped at 420px so the primary button stays visible without scrolling. A capped pane
fades its bottom 26px **only while there is more below it**: a row sliced flat
at the boundary reads as the end of the list, and a fade that never lifts makes
the real last row look unfinished. The pane carries its own `tabIndex` and label
so a keyboard can reach the scroll.

`prefers-reduced-motion` kills every transition.

---

## 9. Agent prompt guide

Reusable prompts that stay on-system:

- *"Add a [screen] to Till Total. Use the classes in
  `apps/web/app/globals.css` — light paper, hairline rules, soft corners, the
  accent only for selection and the primary action — Archivo for text, `.tik`
  for prices, IBM Plex Mono for spec data, one decision per screen with the
  primary button pinned to the bottom."*
- *"Show [quantity] as a stat. Two numbers if one would mislead. Money as £0.00
  in tabular figures."*
- *"Give this slider an honest range. Span it around a number the solver
  measured, and pin that number on the track."*
- *"Add a chart. Categorical colours must pass the dataviz validator against both
  surfaces; label every series; never rely on colour alone."*
- *"Handle the empty/failed state as a designed result: plain-English cause, the
  constraint named in mono, and the action that would fix it."*

---

## 10. Pick-many screens

The dietary, kitchen and style questions use **pastel tiles**, not the ruled
choice rows the single-answer screens use. The shape carries the meaning: a row
is "pick one", a tile grid is "tap as many as apply".

- 2-column grid, 16px radius, 10px gap, solid pastel fill, ~96px tall.
- Emoji, then a 15px/700 label, then an optional 11px sub.
- Selected takes a **2.5px accent border**. Nothing else changes — no fill
  swap, because the fill is already carrying the tile's identity.
- Nine pastels (`.c1`–`.c9`) plus `.c0` for a disabled tile. **The colours mean
  nothing.** Every tile is labelled, and a viewer who sees no colour at all
  loses nothing.
- Tile text is fixed dark (`--ink` for the label, `#43474F` for the sub) rather
  than tokenised, because the pastel fills do not change between themes.
  `--ink-2` measured **4.47:1** on the lightest fill — under AA at 11px — which
  is why the sub is its own value. Re-measure if a pastel changes.

Two rules that are about honesty rather than looks:

- **An option that cannot be honoured is not offered.** No pork toggle (the
  catalogue has no pork). No soy, sesame or shellfish (no product name settles
  them). No "family favourite" or "gut friendly" (that is a language model's
  opinion dressed as data, and CLAUDE.md rule 1 keeps opinions out of the
  selection path). The seven unpriced supermarkets are *shown but disabled*, so
  the gap is visible rather than hidden.
- **Every filter screen carries a live count.** `18 of 24 recipes still fit`,
  in a strip under the tiles, turning red with the actual reason the moment a
  meal slot empties. With a catalogue this small a stacked filter set runs out
  of breakfasts fast, and discovering that four screens later is a dead end.

Allergen tiles additionally carry a standing caveat: the tags are derived from
product names, not from labels. That is enough to filter a plan and not enough
to trust with a real allergy, and the screen says exactly that.
