-- 001_schema.sql — core schema, per SPEC.md §1.
--
-- Four deliberate departures from SPEC §1, all flagged for review in PROGRESS.md:
--   1. carb_per_100 / fat_per_100 are NULLable and seeded NULL. The prototype
--      catalogue carries only kcal and protein, and CLAUDE.md rule 3 says do not
--      invent data. Logged as a catalogue gap.
--   2. plan_basket_line gains qty_from_pantry. Without it the line cannot be
--      reconciled: qty_used may legitimately exceed what the packs supply.
--   3. item_price gets a partial unique index enforcing SPEC's "one current row
--      per item+store", plus a trigger making priced rows immutable.
--   4. shelf_life_days is populated for every perishable, because the
--      carry-over decision should key off shelf life vs plan horizon, not off
--      the binary keeps flag. See PROGRESS.md "Open decision 1".

BEGIN;

-- Stores ---------------------------------------------------------------
CREATE TABLE store (
  id      smallserial PRIMARY KEY,
  slug    text NOT NULL UNIQUE,
  name    text NOT NULL,
  country char(2) NOT NULL DEFAULT 'GB'
);

-- Catalogue ------------------------------------------------------------
CREATE TYPE item_unit     AS ENUM ('g', 'ml', 'unit');
CREATE TYPE item_keeps    AS ENUM ('staple', 'perishable');
CREATE TYPE item_category AS ENUM ('protein', 'carb', 'veg', 'dairy', 'flavour');

CREATE TABLE item (
  id              serial PRIMARY KEY,
  slug            text NOT NULL UNIQUE,
  name            text NOT NULL,
  unit            item_unit NOT NULL,
  aisle           text NOT NULL,
  kcal_per_100    numeric(8,2) NOT NULL,
  protein_per_100 numeric(8,2) NOT NULL,
  carb_per_100    numeric(8,2),
  fat_per_100     numeric(8,2),
  keeps           item_keeps NOT NULL,
  shelf_life_days integer CHECK (shelf_life_days > 0),
  category        item_category NOT NULL,
  CONSTRAINT shelf_life_matches_keeps CHECK (
    (keeps = 'staple'     AND shelf_life_days IS NULL) OR
    (keeps = 'perishable' AND shelf_life_days IS NOT NULL)
  )
);

COMMENT ON COLUMN item.kcal_per_100 IS
  'Per 100g/100ml, or per single unit where unit = ''unit'' (eggs, bananas, stock cubes).';
COMMENT ON COLUMN item.shelf_life_days IS
  'Unopened pack, UK, normal kitchen. NULL for staples. Drives carry-over vs waste.';

CREATE TABLE item_price (
  id          bigserial PRIMARY KEY,
  item_id     integer NOT NULL REFERENCES item(id) ON DELETE CASCADE,
  store_id    smallint NOT NULL REFERENCES store(id) ON DELETE CASCADE,
  pack_size   numeric(10,2) NOT NULL CHECK (pack_size > 0),
  price       numeric(10,2) NOT NULL CHECK (price >= 0),
  source      text NOT NULL CHECK (source IN ('seed', 'user', 'receipt')),
  observed_at timestamptz NOT NULL DEFAULT now(),
  reported_by uuid,
  is_current  boolean NOT NULL DEFAULT true
);

-- SPEC §1: "one current row per item+store".
CREATE UNIQUE INDEX item_price_one_current
  ON item_price (item_id, store_id) WHERE is_current;
CREATE INDEX item_price_history
  ON item_price (item_id, store_id, observed_at DESC);

-- SPEC §1: "Never UPDATE a price. Insert a new row, flip is_current."
-- Enforced rather than documented: everything except is_current/reported_by is frozen.
CREATE FUNCTION item_price_immutable() RETURNS trigger AS $$
BEGIN
  IF (NEW.item_id, NEW.store_id, NEW.pack_size, NEW.price, NEW.source, NEW.observed_at)
     IS DISTINCT FROM
     (OLD.item_id, OLD.store_id, OLD.pack_size, OLD.price, OLD.source, OLD.observed_at)
  THEN
    RAISE EXCEPTION
      'item_price rows are immutable: insert a new row and flip is_current instead';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER item_price_no_update
  BEFORE UPDATE ON item_price
  FOR EACH ROW EXECUTE FUNCTION item_price_immutable();

-- Recipes --------------------------------------------------------------
CREATE TYPE meal_slot AS ENUM ('breakfast', 'main', 'snack');

CREATE TABLE recipe (
  id          serial PRIMARY KEY,
  slug        text NOT NULL UNIQUE,
  name        text NOT NULL,
  minutes     integer NOT NULL CHECK (minutes > 0),
  meal_slot   meal_slot NOT NULL,
  method_md   text,
  serves_base integer NOT NULL DEFAULT 1 CHECK (serves_base > 0)
);

CREATE TABLE recipe_ingredient (
  recipe_id       integer NOT NULL REFERENCES recipe(id) ON DELETE CASCADE,
  item_id         integer NOT NULL REFERENCES item(id) ON DELETE RESTRICT,
  qty_per_serving numeric(10,2) NOT NULL CHECK (qty_per_serving > 0),
  optional        boolean NOT NULL DEFAULT false,
  PRIMARY KEY (recipe_id, item_id)
);

CREATE TABLE recipe_tag (
  recipe_id integer NOT NULL REFERENCES recipe(id) ON DELETE CASCADE,
  tag       text NOT NULL,
  PRIMARY KEY (recipe_id, tag)
);

-- Users ----------------------------------------------------------------
CREATE TABLE app_user (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email      text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE user_prefs (
  user_id             uuid PRIMARY KEY REFERENCES app_user(id) ON DELETE CASCADE,
  store_id            smallint NOT NULL REFERENCES store(id),
  weekly_budget       numeric(10,2) NOT NULL CHECK (weekly_budget > 0),
  household_size      integer NOT NULL DEFAULT 1 CHECK (household_size > 0),
  days_per_plan       integer NOT NULL DEFAULT 7 CHECK (days_per_plan BETWEEN 1 AND 14),
  meals_per_day       integer NOT NULL DEFAULT 3 CHECK (meals_per_day BETWEEN 1 AND 5),
  kcal_target         integer CHECK (kcal_target > 0),
  protein_target      integer CHECK (protein_target > 0),
  max_cook_minutes    integer CHECK (max_cook_minutes > 0),
  dietary_tags        text[] NOT NULL DEFAULT '{}',
  excluded_item_ids   integer[] NOT NULL DEFAULT '{}',
  excluded_recipe_ids integer[] NOT NULL DEFAULT '{}'
);

-- The pantry ledger (retention mechanic) -------------------------------
CREATE TABLE pantry_stock (
  user_id       uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  item_id       integer NOT NULL REFERENCES item(id) ON DELETE CASCADE,
  qty_remaining numeric(12,2) NOT NULL CHECK (qty_remaining >= 0),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, item_id)
);

-- Plans ----------------------------------------------------------------
CREATE TYPE plan_status AS ENUM ('draft', 'active', 'shopped', 'archived');

CREATE TABLE plan (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  store_id        smallint NOT NULL REFERENCES store(id),
  week_start      date NOT NULL,
  budget          numeric(10,2) NOT NULL CHECK (budget > 0),
  status          plan_status NOT NULL DEFAULT 'draft',
  projected_cost  numeric(10,2),
  actual_cost     numeric(10,2),
  protein_per_day numeric(8,2),
  kcal_per_day    numeric(8,2),
  created_at      timestamptz NOT NULL DEFAULT now()
);

COMMENT ON COLUMN plan.actual_cost IS
  'Till receipt total. projected_cost vs actual_cost is the honesty metric, SPEC §6.';

CREATE TABLE plan_meal (
  id        bigserial PRIMARY KEY,
  plan_id   uuid NOT NULL REFERENCES plan(id) ON DELETE CASCADE,
  recipe_id integer NOT NULL REFERENCES recipe(id),
  servings  integer NOT NULL CHECK (servings > 0),
  day_index integer CHECK (day_index BETWEEN 0 AND 13),
  slot      meal_slot NOT NULL
);

CREATE TABLE plan_basket_line (
  id              bigserial PRIMARY KEY,
  plan_id         uuid NOT NULL REFERENCES plan(id) ON DELETE CASCADE,
  item_id         integer NOT NULL REFERENCES item(id),
  packs           integer NOT NULL CHECK (packs >= 0),
  pack_size       numeric(10,2) NOT NULL CHECK (pack_size > 0),
  unit_price      numeric(10,2) NOT NULL CHECK (unit_price >= 0),
  qty_from_pantry numeric(12,2) NOT NULL DEFAULT 0 CHECK (qty_from_pantry >= 0),
  qty_used        numeric(12,2) NOT NULL CHECK (qty_used >= 0),
  qty_carry_over  numeric(12,2) NOT NULL DEFAULT 0 CHECK (qty_carry_over >= 0),
  qty_wasted      numeric(12,2) NOT NULL DEFAULT 0 CHECK (qty_wasted >= 0),
  -- Conservation: nothing is created or destroyed. Tolerance absorbs 2dp rounding.
  CONSTRAINT basket_line_balances CHECK (
    abs((packs * pack_size + qty_from_pantry)
        - (qty_used + qty_carry_over + qty_wasted)) < 0.01
  ),
  UNIQUE (plan_id, item_id)
);

COMMENT ON COLUMN plan_basket_line.qty_from_pantry IS
  'Free stock drawn from pantry_stock. Not in SPEC §1; required to reconcile the line.';

COMMIT;
