"""
The /solve contract from SPEC §2, as types. The model that fills these in
lands in Session 2 — this file exists so the shape is agreed first.
"""
from typing import Literal

from pydantic import BaseModel, Field

from . import config

Objective = Literal["protein", "cheapest", "variety"]


class SolveRequest(BaseModel):
    store: str
    budget: float = Field(gt=0)
    days: int = Field(default=config.DEFAULT_DAYS, ge=1, le=14)
    meals_per_day: int = Field(default=config.DEFAULT_MEALS_PER_DAY, ge=1, le=5)
    household_size: int = Field(default=1, ge=1)
    min_protein_per_day: float = config.DEFAULT_MIN_PROTEIN_PER_DAY
    kcal_band: tuple[float, float] = config.DEFAULT_KCAL_BAND
    max_cook_minutes_per_day: float = config.DEFAULT_MAX_COOK_MINUTES_PER_DAY
    max_repeat: int = config.DEFAULT_MAX_REPEAT
    max_snacks_per_day: float = config.DEFAULT_MAX_SNACKS_PER_DAY
    min_distinct_mains: int = config.DEFAULT_MIN_DISTINCT_MAINS
    # Free stock, keyed by item slug, in the item's unit.
    pantry: dict[str, float] = Field(default_factory=dict)
    exclude_items: list[str] = Field(default_factory=list)
    exclude_recipes: list[str] = Field(default_factory=list)
    objective: Objective = "protein"


class PlanMeal(BaseModel):
    recipe: str
    name: str
    servings: int
    slot: Literal["breakfast", "main", "snack"]
    minutes: int
    kcal_per_serving: float
    protein_per_serving: float
    image_url: str | None = None


class BasketLine(BaseModel):
    """
    Invariant, mirrored by the basket_line_balances CHECK in 001_schema.sql:
        packs * pack_size + qty_from_pantry
            == qty_used + qty_carry_over + qty_wasted
    """
    item: str
    name: str
    aisle: str
    unit: Literal["g", "ml", "unit"]
    packs: int
    pack_size: float
    unit_price: float
    line_cost: float
    qty_from_pantry: float
    qty_used: float
    qty_carry_over: float
    qty_wasted: float
    carries: bool


class SolveResponse(BaseModel):
    status: Literal["ok"] = "ok"
    store: str
    budget: float
    # SPEC §3(e): three numbers, never one.
    spend: float
    consumed_value: float
    carry_over_value: float
    wasted_value: float
    cupboard_value: float
    protein_per_day: float
    kcal_per_day: float
    meals: list[PlanMeal]
    basket: list[BasketLine]
    closing_pantry: dict[str, float]


class InfeasibleResponse(BaseModel):
    """SPEC §2: infeasibility is a headline feature, not an error path."""
    status: Literal["infeasible"] = "infeasible"
    binding: str
    suggestion: str
    min_feasible_budget: float | None = None
