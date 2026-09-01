"""
Turn a person's answers into a set of recipes the solver may not use.

Filtering happens *before* the model runs and never touches the objective:
a recipe is either available or it is not. That keeps CLAUDE.md rule 1 intact —
nothing here scores or ranks anything, it only removes.

Every filter reports what it removed, because with 24 recipes a stacked filter
set empties a meal slot quickly and "infeasible" on its own is a useless answer.
Knowing that gluten-free removed all seven breakfasts is the answer.
"""
from dataclasses import dataclass, field

from .domain import Item, Recipe

# Allergen groups the catalogue can actually speak to. Anything absent from this
# list is absent because no item's name settles it, and an allergen that is
# guessed is worse than no allergen at all.
ALLERGENS = ("gluten", "dairy", "egg", "fish", "peanut")
APPLIANCES = ("hob", "oven", "microwave", "airfryer")
PROTEINS = ("beef", "chicken", "fish", "egg")
STYLES = ("speedy", "onepot", "veggie")


@dataclass(frozen=True)
class Diet:
    """What the user told us. Empty everywhere means "no filtering"."""
    avoid_allergens: frozenset[str] = frozenset()
    # Appliances owned. Empty means "assume everything", so the default answer
    # is never accidentally narrower than the catalogue.
    appliances: frozenset[str] = frozenset()
    avoid_proteins: frozenset[str] = frozenset()
    styles: frozenset[str] = frozenset()

    @classmethod
    def of(cls, allergens=(), appliances=(), proteins=(), styles=()) -> "Diet":
        return cls(frozenset(allergens), frozenset(appliances),
                   frozenset(proteins), frozenset(styles))

    @property
    def empty(self) -> bool:
        return not (self.avoid_allergens or self.appliances
                    or self.avoid_proteins or self.styles)


@dataclass
class FilterReport:
    """Which recipes each answer removed, and what survives per meal slot."""
    excluded: set[str] = field(default_factory=set)
    by_reason: dict[str, list[str]] = field(default_factory=dict)
    remaining_by_slot: dict[str, int] = field(default_factory=dict)
    total_remaining: int = 0

    @property
    def empty_slots(self) -> list[str]:
        """Slots the filters wiped out. These are the real blocker, not money."""
        return [slot for slot, n in self.remaining_by_slot.items() if n == 0]


def recipe_allergens(recipe: Recipe, items: dict[str, Item]) -> set[str]:
    out: set[str] = set()
    for slug in recipe.ingredients:
        item = items.get(slug)
        if item is not None:
            out |= set(item.allergens)
    return out


def apply(items: dict[str, Item], recipes: dict[str, Recipe],
          diet: Diet) -> FilterReport:
    """Returns what to exclude and why. Does not mutate its arguments."""
    report = FilterReport()

    def drop(reason: str, slug: str) -> None:
        report.excluded.add(slug)
        report.by_reason.setdefault(reason, []).append(slug)

    for slug, r in recipes.items():
        hit = recipe_allergens(r, items) & diet.avoid_allergens
        for allergen in sorted(hit):
            drop(f"{allergen}-free", slug)

        if diet.appliances:
            needed = {t[4:] for t in r.tags if t.startswith("app:")}
            # No appliance tag means no appliance needed — a no-cook snack is
            # available to everyone, including someone with an empty kitchen.
            if needed and not (needed & diet.appliances):
                drop("appliances", slug)

        for protein in sorted({t[4:] for t in r.tags if t.startswith("pro:")}
                              & diet.avoid_proteins):
            drop(f"no {protein}", slug)

        # A style shapes the MAIN meals only. Nobody asks for a one-pot
        # breakfast, and applying it to every slot wiped breakfast out entirely
        # the first time — an answer that was technically correct and plainly
        # not what anyone meant.
        if diet.styles and r.meal_slot == "main":
            # Satisfied by ANY of the chosen styles, never all of them: picking
            # a second one has to widen the choice, not narrow it.
            has = {t[4:] for t in r.tags if t.startswith("sty:")}
            if "vegetarian" in r.tags:
                has = has | {"veggie"}
            if not (has & diet.styles):
                drop("style", slug)

    for slug, r in recipes.items():
        if slug in report.excluded:
            continue
        report.remaining_by_slot[r.meal_slot] = \
            report.remaining_by_slot.get(r.meal_slot, 0) + 1
        report.total_remaining += 1
    for slot in ("breakfast", "main", "snack"):
        report.remaining_by_slot.setdefault(slot, 0)
    return report


def blocked_reason(report: FilterReport, diet: Diet,
                   recipes: dict[str, Recipe] | None = None) -> str | None:
    """
    Plain English for a filter set that cannot produce a plan at any budget.

    Checked before the solve. Handing CBC an empty breakfast list and reporting
    "budget too low" would name the wrong constraint, which is the one thing
    SPEC §2 says an infeasible answer must never do.

    The reason names the answer that actually emptied the slot, not every answer
    given — "once gluten-free is applied" is actionable, "once appliances, no
    beef, style is applied" is not.
    """
    dead = [s for s in ("breakfast", "main") if report.remaining_by_slot.get(s, 0) == 0]
    if not dead:
        return None
    slot = dead[0]

    culprit = None
    if recipes is not None:
        # Which single answer removed the most recipes from the dead slot?
        scored = [
            (sum(1 for sl in slugs if recipes[sl].meal_slot == slot), reason)
            for reason, slugs in report.by_reason.items()
        ]
        scored = [x for x in scored if x[0] > 0]
        if scored:
            culprit = max(scored)[1]
    if culprit is None:
        culprit = ", ".join(sorted(report.by_reason)) or "your filters"

    slots = " or ".join(dead)
    return (f"Nothing in the catalogue can be a {slots} once {culprit} is applied. "
            f"This is a gap in the 24 recipes, not a budget problem — "
            f"no amount of money fixes it.")
