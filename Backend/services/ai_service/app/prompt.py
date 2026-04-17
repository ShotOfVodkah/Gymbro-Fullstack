from app.catalog import get_valid_ids

_INJURY_LABELS: dict[str, str] = {
    "knee_injury": "травма колена",
    "shoulder_injury": "травма плеча",
    "lower_back_pain": "боль в пояснице",
    "wrist_injury": "травма запястья",
    "neck_injury": "боль в шее",
    "ankle_injury": "травма лодыжки",
    "high_blood_pressure": "высокое давление",
    "elbow_injury": "травма локтя",
    "pregnancy": "беременность",
}

_INJURY_LABELS_EN: dict[str, str] = {
    "knee_injury": "knee injury",
    "shoulder_injury": "shoulder injury",
    "lower_back_pain": "lower back pain",
    "wrist_injury": "wrist injury",
    "neck_injury": "neck pain",
    "ankle_injury": "ankle injury",
    "high_blood_pressure": "high blood pressure",
    "elbow_injury": "elbow injury",
    "pregnancy": "pregnancy",
}

_SYSTEM_PROMPT_TEMPLATE = """You are a fitness AI trainer. Create safe workouts in JSON format.

CRITICAL RULES:
1. Return ONLY valid JSON, no other text, no markdown, no code fences
2. Use ONLY exercise_id values from the list below — never invent new ones
3. Every exercise MUST include ALL required fields for its type

STRENGTH: exercise_id, exercise_type="strength", sets(1-10), reps(1-50), weight_kg(number or null)
CARDIO:   exercise_id, exercise_type="cardio",   duration_minutes(1-120), pace(walk/jog/run/sprint/recovery)
YOGA:     exercise_id, exercise_type="yoga",     hold_seconds(5-300), breath_count(1-20)

Output shape:
{{"workout_name": "...", "type": "strength|cardio|yoga", "duration_min": <int>, "exercises": [...]}}

AVAILABLE exercise_id values (use only these):
{valid_ids}

LANGUAGE: Write the workout_name field in {workout_name_lang}."""


def build_messages(user_input: str, injuries: list[str], locale: str = "en") -> list[dict]:
    valid_ids_str = ", ".join(get_valid_ids())
    workout_name_lang = "Russian" if locale == "ru" else "English"
    system_content = _SYSTEM_PROMPT_TEMPLATE.format(
        valid_ids=valid_ids_str,
        workout_name_lang=workout_name_lang,
    )

    user_content = user_input.strip()
    if injuries:
        label_map = _INJURY_LABELS if locale == "ru" else _INJURY_LABELS_EN
        contra = "Противопоказания" if locale == "ru" else "Contraindications"
        labels = [label_map.get(inj, inj) for inj in injuries]
        user_content += f". {contra}: {', '.join(labels)}"

    return [
        {"role": "system", "content": system_content},
        {"role": "user", "content": user_content},
    ]
