import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pytest

from app.catalogue import load


@pytest.fixture(scope="session")
def aldi():
    items, recipes, _ = load("aldi")
    return items, recipes


@pytest.fixture(scope="session")
def tesco():
    items, recipes, _ = load("tesco")
    return items, recipes
