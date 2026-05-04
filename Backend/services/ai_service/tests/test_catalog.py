import pytest

from app.catalog import get_valid_ids, is_safe_for_injuries, lookup

def test_lookup_known_exercise_returns_dict():
    entry = lookup("running")
    assert entry is not None
    assert entry["id"] == "running"
    assert "name" in entry
    assert "type" in entry
    assert "muscleGroup" in entry


def test_lookup_unknown_exercise_returns_none():
    assert lookup("nonexistent_exercise") is None


def test_lookup_returns_all_expected_fields():
    entry = lookup("squat")
    assert entry is not None
    for field in ("id", "name", "type", "muscleGroup", "difficulty", "contraindications"):
        assert field in entry, f"Missing field: {field}"

def test_get_valid_ids_is_nonempty():
    ids = get_valid_ids()
    assert len(ids) > 0


def test_get_valid_ids_count():
    assert len(get_valid_ids()) == 30


def test_get_valid_ids_no_duplicates():
    ids = get_valid_ids()
    assert len(ids) == len(set(ids))


def test_get_valid_ids_contains_known_exercises():
    ids = get_valid_ids()
    for expected in ("running", "squat", "deadlift", "cobra", "cycling"):
        assert expected in ids

def test_safe_exercise_no_injuries():
    assert is_safe_for_injuries("running", []) is True


def test_contraindicated_exercise_rejected():
    assert is_safe_for_injuries("running", ["knee_injury"]) is False


def test_non_contraindicated_injury_passes():
    assert is_safe_for_injuries("running", ["shoulder_injury"]) is True


def test_unknown_exercise_is_not_safe():
    assert is_safe_for_injuries("nonexistent", ["knee_injury"]) is False


def test_multiple_injuries_one_contraindicated():
    assert is_safe_for_injuries("squat", ["shoulder_injury", "knee_injury"]) is False


def test_multiple_injuries_none_contraindicated():
    assert is_safe_for_injuries("cycling", ["shoulder_injury", "wrist_injury"]) is True


def test_yoga_exercise_contraindication():
    assert is_safe_for_injuries("cobra", ["lower_back_pain"]) is False
    assert is_safe_for_injuries("cobra", ["knee_injury"]) is True


@pytest.mark.parametrize("exercise_id,injury,expected", [
    ("deadlift", "lower_back_pain", False),
    ("deadlift", "knee_injury", False),
    ("deadlift", "shoulder_injury", True),
    ("deadlift", "high_blood_pressure", False),
    ("bench-press", "shoulder_injury", False),
    ("bench-press", "wrist_injury", False),
    ("bench-press", "knee_injury", True),
    ("overhead-press", "high_blood_pressure", False),
    ("crunch", "pregnancy", False),
    ("crunch", "wrist_injury", True),
    ("jump-rope", "pregnancy", False),
    ("jump-rope", "shoulder_injury", True),
    ("downward-dog", "shoulder_injury", False),
    ("downward-dog", "wrist_injury", False),
    ("downward-dog", "knee_injury", True),
])
def test_specific_contraindications(exercise_id: str, injury: str, expected: bool):
    assert is_safe_for_injuries(exercise_id, [injury]) is expected
