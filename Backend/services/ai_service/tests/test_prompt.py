
import pytest

from app.catalog import get_valid_ids
from app.prompt import build_messages

def test_returns_two_messages():
    messages = build_messages("силовая тренировка", [])
    assert len(messages) == 2


def test_first_message_is_system():
    messages = build_messages("тренировка", [])
    assert messages[0]["role"] == "system"


def test_second_message_is_user():
    messages = build_messages("тренировка", [])
    assert messages[1]["role"] == "user"


def test_system_message_contains_all_exercise_ids():
    messages = build_messages("тренировка", [], "en")
    system_content = messages[0]["content"]
    for ex_id in get_valid_ids():
        assert ex_id in system_content, f"exercise_id '{ex_id}' missing from system prompt"
    assert "English" in system_content


def test_user_message_contains_input_text():
    user_text = "Силовая на спину, 40 минут"
    messages = build_messages(user_text, [])
    assert user_text in messages[1]["content"]

def test_injuries_appended_in_russian():
    messages = build_messages("тренировка", ["knee_injury"], "ru")
    user_content = messages[1]["content"]
    assert "Противопоказания" in user_content
    assert "травма колена" in user_content


def test_multiple_injuries_all_present():
    messages = build_messages("тренировка", ["knee_injury", "lower_back_pain"], "ru")
    user_content = messages[1]["content"]
    assert "травма колена" in user_content
    assert "боль в пояснице" in user_content


def test_no_injuries_no_contraindications_text():
    messages = build_messages("тренировка", [])
    assert "Противопоказания" not in messages[1]["content"]


def test_empty_injuries_list_no_contraindications_text():
    messages = build_messages("тренировка", [])
    assert "Противопоказания" not in messages[1]["content"]

def test_unknown_injury_code_used_as_fallback_label():
    messages = build_messages("тренировка", ["hip_injury"], "ru")
    user_content = messages[1]["content"]
    assert "hip_injury" in user_content

@pytest.mark.parametrize("code,expected_label", [
    ("knee_injury",        "травма колена"),
    ("shoulder_injury",    "травма плеча"),
    ("lower_back_pain",    "боль в пояснице"),
    ("wrist_injury",       "травма запястья"),
    ("neck_injury",        "боль в шее"),
    ("ankle_injury",       "травма лодыжки"),
    ("high_blood_pressure","высокое давление"),
    ("elbow_injury",       "травма локтя"),
    ("pregnancy",          "беременность"),
])
def test_injury_label_translation(code: str, expected_label: str):
    messages = build_messages("тренировка", [code], "ru")
    assert expected_label in messages[1]["content"]


def test_injuries_appended_in_english():
    messages = build_messages("workout", ["knee_injury"], "en")
    user_content = messages[1]["content"]
    assert "Contraindications" in user_content
    assert "knee injury" in user_content


def test_system_prompt_russian_workout_name_hint():
    messages = build_messages("тренировка", [], "ru")
    assert "Russian" in messages[0]["content"]
