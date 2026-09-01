"""
Plain data for the optimiser. No database, no framework — so the model can be
tested without either.
"""
from dataclasses import dataclass, field


@dataclass(frozen=True)
class Item:
    slug: str
    name: str
    unit: str                    # 'g' | 'ml' | 'unit'
    aisle: str
    kcal_per_100: float
    protein_per_100: float
    keeps: str                   # 'staple' | 'perishable'
    shelf_life_days: int | None
    category: str
    pack_size: float
    price: float
    # Name-derived allergen groups, never label data. See 012_diet_filters.sql.
    allergens: frozenset[str] = frozenset()

    @property
    def unit_cost(self) -> float:
        """Display and objective weighting only — never a planning price.
        CLAUDE.md rule 2: packs are what get bought."""
        return self.price / self.pack_size

    def carries(self, horizon_days: int, by_shelf_life: bool) -> bool:
        """
        Does leftover survive to the next plan, i.e. is it an asset or is it bin?

        Staples always carry. For perishables it depends on the rule in force:
        under CARRY_BY_SHELF_LIFE, anything outliving the horizon carries —
        a 400g cheddar block is not waste on day 8. Under a literal reading of
        SPEC §3(c), no perishable carries.
        """
        if self.keeps == "staple":
            return True
        if not by_shelf_life:
            return False
        return self.shelf_life_days is not None and self.shelf_life_days >= horizon_days

    def macros_for(self, qty: float) -> tuple[float, float]:
        """kcal and protein for qty in this item's unit."""
        mult = qty if self.unit == "unit" else qty / 100.0
        return self.kcal_per_100 * mult, self.protein_per_100 * mult


@dataclass(frozen=True)
class Recipe:
    slug: str
    name: str
    minutes: int
    meal_slot: str               # 'breakfast' | 'main' | 'snack'
    ingredients: dict[str, float] = field(default_factory=dict)
    # Decorative dish photography. Never used in selection, pricing or
    # quantities; a recipe without one simply renders without a picture.
    image_url: str | None = None
    # 'app:hob', 'pro:beef', 'sty:speedy', 'vegetarian', ... See filters.py.
    # Tags only ever remove a recipe from consideration before the solve; they
    # never enter the objective.
    tags: frozenset[str] = frozenset()

    def macros(self, items: dict[str, Item]) -> tuple[float, float]:
        kcal = protein = 0.0
        for slug, qty in self.ingredients.items():
            k, p = items[slug].macros_for(qty)
            kcal += k
            protein += p
        return kcal, protein
