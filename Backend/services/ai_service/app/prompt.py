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
{valid_ids}"""


def build_messages(user_input: str, injuries: list[str]) -> list[dict]:
    valid_ids_str = ", ".join(get_valid_ids())
    system_content = _SYSTEM_PROMPT_TEMPLATE.format(valid_ids=valid_ids_str)

    user_content = user_input.strip()
    if injuries:
        labels = [_INJURY_LABELS.get(inj, inj) for inj in injuries]
        user_content += f". Противопоказания: {', '.join(labels)}"

    return [
        {"role": "system", "content": system_content},
        {"role": "user", "content": user_content},
    ]
