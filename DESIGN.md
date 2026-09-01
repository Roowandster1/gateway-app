# DESIGN.md — Till Total

How this product should look and feel. `CLAUDE.md` says how to build it; this
says how to draw it. Every value here is in use in `apps/web/app/globals.css`
and `demo/template.html` — this file is the reasoning, not a wish list.

The two files carry the **same rules**: `globals.css` is generated from the demo
template's style block, so the shipped app and the demo cannot drift apart.

---

## 1. Visual theme & atmosphere

**A shelf-edge ticket, not a food magazine.**

The product's entire claim is that the number on the phone is the number at the
till. A glossy, marketed interface undermines that claim before the user reads a
word — it looks like something with an incentive. So the design is plain, dense
and printed, drawing on the vernacular of supermarket shelf-edge labels and till
receipts: hard black rules, tabular figures, aisle headings in reversed-out
bars, and one price-flash yellow.

Density is medium-tight. This is a tool operated in a supermarket aisle with one
hand, not a page read on a sofa. Whitespace separates *kinds* of information; it
never makes the page feel expensive.

**The first version claimed this theme and did not build it.** It said
"shelf-edge ticket" at the top of this file and then rendered a sage-green
wellness app: soft off-white ground, 26px radii, a blurred drop shadow under a
floating card, essayistic sub-copy under every heading. That combination —
pastel neutrals, rounded everything, soft shadow, explanatory prose — is the
house style of machine-generated interfaces, and it read as one. The fix was not
new tokens; it was committing to the theme already written down.

**Never mimic Aldi's or Tesco's branding.** The app names them as data; it must
not dress as them.

---

## 2. Colour palette & roles

Paper white on card grey, near-black ink, and a single saturated yellow that
means one thing only: **this one**.

### Light (the base; `:root`)

| Token | Hex | Role |
|---|---|---|
| `--board` | `#D5D2C9` | the page — the shelf rail the tickets sit on |
| `--paper` | `#FFFFFF` | the ticket itself, and every card |
| `--paper-2` | `#F2F1ED` | inset fills: the amount window, the floor note |
| `--ink` | `#0A0A0A` | text, borders, reversed-out header bars, the button |
| `--ink-2` | `#57544E` | secondary text, mono labels, units |
| `--rule` | `#CBC7BE` | hairline between rows and around idle controls |
| `--flash` | `#FFE81A` | **selection only.** Chosen chip, chosen shop, hover on the primary button |
| `--flash-ink` | `#0A0A0A` | text on the flash |
| `--red` / `--red-bg` | `#CE1B22` / `#FBE4E4` | below the floor, infeasible, solver down |
| `--green` | `#0B6E4F` | carry-over: an asset, not waste |

The ground is deliberately a **mid grey**, not off-white. White tickets have to
sit *on* something to read as tickets, and a near-white page with near-white
cards is the soft look the theme rejects.

### Dark (re-stepped, never inverted)

`#000000` board, `#111110` paper, `#1B1A18` inset, `#F3F1EB` ink, `#9C988E`
secondary, `#332F2A` rule, `#FF6F66`/`#2C1312` red, `#4FBE92` green. The flash
stays `#FFE81A` with black text — it is the one token that does not move,
because a price flash is a price flash on any ground.

Reversed bars invert with the tokens: a black-on-white aisle heading in light
becomes white-on-black in dark, which is correct, not a bug.

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
  glance is set at `wdth 68 / wght 800` — the `.tik` class — which is how a shelf
  ticket is actually printed.
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
| Masthead | 26px / `wdth 70`, 800, uppercase |
| Screen question | 27px / 700 / `-0.02em` |
| Hero price | 56–60px `.tik` |
| Chip numeral | 32px `.tik` |
| Body | 12.5–14.5px / 400–600 |
| Mono labels, aisles, eyebrows | **10.5px minimum**, uppercase, `0.10–0.13em` |

**Rules.** Every column of digits gets `font-variant-numeric: tabular-nums`.
Money in a list or a total is `£0.00`, two decimals. Money you are *entering* is
whole pounds — a keypad that demands pence is a keypad nobody uses.

**Nothing renders below 10.5px.** The redesign briefly shipped 9-9.5px tracked
caps; they are unreadable on a phone and were caught only by measuring the
smallest rendered text in the DOM. Check it, don't eyeball it.

---

## 4. Component stylings

- **The ticket** — the whole app is one `1.5px solid --ink` rectangle on
  `--board`. No radius. No shadow. `min-height: 648px`.
- **Top bar** — reversed `--ink` strip: back arrow, step name in mono caps, and
  `03/04` in flash on the right. Under it a four-segment progress rail, filled
  in flash, hidden once the plan is on screen.
- **Choice ticket** — full-width, square, `1.5px --rule`. Selected fills solid
  `--flash` with a `--ink` border. Name 19px/700, detail 12px, a right-aligned
  mono figure.
- **Day chips** — a 3×2 grid of discrete stops (1, 2, 3, 5 days, 1, 2 weeks),
  big `.tik` numeral over a mono unit. Tapped, not dragged.
- **Budget keypad** — an amount window (`.tik` 56px, plus who and how long, in
  mono) over a 3×4 keypad: 1–9, Clear, 0, Del. Driven by a real keyboard too.
- **Cost bar** — 16px tall, square, inside a `1.5px --ink` frame, three segments
  with a **2px gap**. Every segment is named with its value and share in the key
  beneath, and the bar carries an `aria-label` spelling out the whole split.
- **Meal row** — 50px square photo with a hairline, a flash serving badge in
  ticket numerals, name, right-aligned mono macros.
- **Shopping line** — checkbox, name, an outlined `carries` / `wasted` pill,
  pack maths on a second line (`2 × 500g @ £0.45`), right-aligned line cost.
  Grouped under sticky reversed aisle bars, closed by a 3px `--ink` rule above
  the total.
- **Floor note** — a 4px left-rule block. `--ink` when the budget works, `--red`
  when it doesn't, and it always states the number.
- **Primary button** — solid `--ink`, uppercase, tracked, full width, square.
  Hover flips it to flash. One per screen, pinned to the bottom. Secondary is
  the same shape in `--paper`.

**No sliders.** A slider has to invent a range before the floor is known, and
its two ends are a claim about what is possible that the solver has not made
yet. That is how the old build ended up telling people the minimum was £25 when
the real Aldi floor is £19.38 and plenty of people feed themselves for less. A
keypad claims nothing and accepts any number; the floor note, which comes from
an actual solve, does the arguing.

---

## 5. Layout principles

The app is a **single ~400px column** — a phone, even on a desktop, because that
is where it is used. Beside it on wide screens sits one proof panel; below 860px
it stacks underneath.

Spacing runs on a 4px base, with 18–20px screen padding and 7–12px between
related rows. Groups are laid out with flex/grid `gap`, never per-element
margins. Any wide content scrolls inside its own container; the page body never
scrolls sideways.

Each onboarding screen holds exactly one decision, with its call to action
pinned to the bottom by `margin-top: auto`, so the button lands in the same
place on every screen.

---

## 6. Depth & elevation

**None.** Borders and reversed bars do all the work. There is no `box-shadow`
anywhere in the system, and there should not be one. Hierarchy comes from
contrast and rule weight: 1px hairline between rows, 1.5px around a control,
3px under a total.

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
- Don't spend the flash on decoration. If everything is yellow, nothing is
  selected.
- Don't add a radius or a shadow "to soften it". Softness is the tell.
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
get a full-row label and keypad keys are 46px tall. Scrollable panes are capped
at 424px so the primary button stays visible without scrolling. A capped pane
fades its bottom 26px **only while there is more below it**: a row sliced flat
at the boundary reads as the end of the list, and a fade that never lifts makes
the real last row look unfinished. The pane carries its own `tabIndex` and label
so a keyboard can reach the scroll.

A tab is white when idle and black when selected, so neither an ink nor a flash
focus ring is visible in both states — focus repaints the whole tab instead.

`prefers-reduced-motion` kills every transition.

---

## 9. Agent prompt guide

Reusable prompts that stay on-system:

- *"Add a [screen] to Till Total. Use the classes in
  `apps/web/app/globals.css` — square corners, 1.5px ink borders, no shadows —
  Archivo for text, `.tik` for prices, IBM Plex Mono for spec data, one decision
  per screen with the primary button pinned to the bottom."*
- *"Show [quantity] as a stat. Two numbers if one would mislead. Money as £0.00
  in tabular figures."*
- *"Replace this slider. Discrete stops become chips; an open amount becomes a
  keypad. A control must not imply a range the solver has not confirmed."*
- *"Add a chart. Categorical colours must pass the dataviz validator against both
  surfaces; label every series; never rely on colour alone."*
- *"Handle the empty/failed state as a designed result: plain-English cause, the
  constraint named in mono, and the action that would fix it."*
