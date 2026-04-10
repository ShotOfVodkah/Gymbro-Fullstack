import json

import pytest

from app.model import _extract_json

def test_clean_json_object():
    raw = '{"workout_name": "Test", "type": "strength"}'
    result = _extract_json(raw)
    assert result is not None
    assert json.loads(result) == {"workout_name": "Test", "type": "strength"}


def test_clean_json_with_leading_trailing_whitespace():
    raw = '  \n{"key": "value"}\n  '
    result = _extract_json(raw)
    assert result is not None
    assert json.loads(result)["key"] == "value"

def test_json_in_prose_extracted():
    payload = {"workout_name": "Legs Day", "type": "strength", "exercises": []}
    raw = f'Here is your workout: {json.dumps(payload)} Enjoy!'
    result = _extract_json(raw)
    assert result is not None
    assert json.loads(result)["workout_name"] == "Legs Day"


def test_json_after_preamble():
    payload = {"a": 1}
    raw = f"Sure, here you go:\n{json.dumps(payload)}"
    result = _extract_json(raw)
    assert result is not None
    assert json.loads(result) == {"a": 1}


def test_json_with_nested_objects():
    payload = {
        "workout_name": "Full Body",
        "exercises": [{"exercise_id": "squat", "sets": 3}],
    }
    raw = json.dumps(payload)
    result = _extract_json(raw)
    assert result is not None
    parsed = json.loads(result)
    assert parsed["exercises"][0]["exercise_id"] == "squat"

def test_plain_text_returns_none():
    assert _extract_json("No JSON here at all") is None


def test_empty_string_returns_none():
    assert _extract_json("") is None


def test_whitespace_only_returns_none():
    assert _extract_json("   ") is None


def test_incomplete_json_returns_none():
    assert _extract_json('{"key": "value"') is None


def test_json_array_returned_as_is():
    result = _extract_json('[1, 2, 3]')
    assert result == '[1, 2, 3]'

def test_multiple_json_objects_returns_outermost():
    raw = '{"outer": {"inner": 1}}'
    result = _extract_json(raw)
    assert result is not None
    parsed = json.loads(result)
    assert "outer" in parsed


def test_json_with_unicode():
    payload = {"workout_name": "Силовая тренировка", "type": "strength"}
    raw = json.dumps(payload, ensure_ascii=False)
    result = _extract_json(raw)
    assert result is not None
    assert json.loads(result)["workout_name"] == "Силовая тренировка"
