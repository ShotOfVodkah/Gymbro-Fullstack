
import pytest

from app.main import WEIGHT_RANGES, _get_random_weight, _map_exercise

def test_unknown_id_uses_default_range():
    for _ in range(20):
        w = _get_random_weight("nonexistent_exercise")
        assert 5 <= w <= 50


def test_catalog_ids_fall_through_to_default_range():
    for _ in range(20):
        w = _get_random_weight("bench-press")
        assert 5 <= w <= 50, (
            "bench-press falls through to default range because WEIGHT_RANGES "
            "uses 'bench_press' (underscore) instead of 'bench-press' (hyphen)"
        )


def test_underscore_id_uses_specific_range():
    min_w, max_w = WEIGHT_RANGES["bench_press"]
    for _ in range(20):
        w = _get_random_weight("bench_press")
        assert min_w <= w <= max_w


def test_bodyweight_only_exercise_returns_zero():
    assert _get_random_weight("push_up") == 0


def test_custom_default_range():
    for _ in range(20):
        w = _get_random_weight("unknown", default_min=10, default_max=20)
        assert 10 <= w <= 20

def test_unknown_exercise_id_returns_none():
    result = _map_exercise({"exercise_id": "nonexistent"}, [], "en")
    assert result is None


def test_contraindicated_exercise_returns_none():
    ai_ex = {"exercise_id": "squat", "sets": 3, "reps": 10, "weight_kg": 60}
    result = _map_exercise(ai_ex, ["knee_injury"], "en")
    assert result is None


def test_valid_exercise_with_explicit_weight():
    ai_ex = {"exercise_id": "squat", "sets": 3, "reps": 10, "weight_kg": 80}
    result = _map_exercise(ai_ex, [], "en")
    assert result is not None
    assert result.weightKg == 80


def test_strength_exercise_without_weight_gets_random():
    ai_ex = {"exercise_id": "squat", "sets": 3, "reps": 10, "weight_kg": None}
    result = _map_exercise(ai_ex, [], "en")
    assert result is not None
    assert result.weightKg is not None
    assert result.weightKg >= 0


def test_cardio_exercise_without_weight_keeps_none():
    ai_ex = {
        "exercise_id": "running",
        "exercise_type": "cardio",
        "duration_minutes": 30,
        "pace": "jog",
    }
    result = _map_exercise(ai_ex, [], "en")
    assert result is not None
    assert result.weightKg is None


def test_exercise_fields_mapped_correctly():
    ai_ex = {
        "exercise_id": "squat",
        "sets": 4,
        "reps": 12,
        "weight_kg": 70,
    }
    result = _map_exercise(ai_ex, [], "ru")
    assert result is not None
    assert result.id == "squat"
    assert result.name == "Приседания"
    assert result.type == "strength"
    assert result.muscleGroup == "legs"
    assert result.sets == 4
    assert result.reps == 12
    assert result.weightKg == 70


def test_cardio_fields_mapped_correctly():
    ai_ex = {
        "exercise_id": "running",
        "duration_minutes": 20,
        "pace": "run",
    }
    result = _map_exercise(ai_ex, [], "en")
    assert result is not None
    assert result.durationMinutes == 20
    assert result.pace == "run"
    assert result.sets is None
    assert result.reps is None


def test_yoga_fields_mapped_correctly():
    ai_ex = {
        "exercise_id": "cobra",
        "hold_seconds": 30,
        "breath_count": 5,
    }
    result = _map_exercise(ai_ex, [], "en")
    assert result is not None
    assert result.holdSeconds == 30
    assert result.breathCount == 5


def test_non_contraindicated_injury_allows_exercise():
    ai_ex = {"exercise_id": "deadlift", "sets": 3, "reps": 5, "weight_kg": 100}
    result = _map_exercise(ai_ex, ["shoulder_injury"], "en")
    assert result is not None


def test_missing_exercise_id_returns_none():
    result = _map_exercise({}, [], "en")
    assert result is None
