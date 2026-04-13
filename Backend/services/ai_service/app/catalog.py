import json
from pathlib import Path
from typing import Optional

_BASE = Path(__file__).parent.parent
_EXERCISES_PATH = _BASE / "exercises.json"

_catalog: dict[str, dict] = {}


def _load() -> None:
    with open(_EXERCISES_PATH, encoding="utf-8") as f:
        entries = json.load(f)
    for entry in entries:
        _catalog[entry["id"]] = entry


_load()


def get_valid_ids() -> list[str]:
    return list(_catalog.keys())


def lookup(exercise_id: str) -> Optional[dict]:
    return _catalog.get(exercise_id)


def is_safe_for_injuries(exercise_id: str, injuries: list[str]) -> bool:
    entry = _catalog.get(exercise_id)
    if entry is None:
        return False
    contraindications: list[str] = entry.get("contraindications", [])
    return not any(inj in contraindications for inj in injuries)
