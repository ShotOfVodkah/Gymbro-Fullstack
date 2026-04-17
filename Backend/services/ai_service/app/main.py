from __future__ import annotations

import json
import logging
import uuid
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Dict, Optional, Tuple

import jsonschema
from fastapi import Depends, FastAPI, HTTPException
from pydantic import BaseModel, Field

from app import model as ai_model
from app.auth import get_authenticated_user_id, require_jwt_secret
from app.catalog import is_safe_for_injuries, lookup
from app.prompt import build_messages
from app.validation import validate_input

import random

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

_SCHEMA_PATH = Path(__file__).parent.parent / "schema.json"
with open(_SCHEMA_PATH) as _f:
    _WORKOUT_SCHEMA: dict = json.load(_f)

class GenerateRequest(BaseModel):
    user_input: str = Field(..., description="Free-text workout request from the user")
    injuries: list[str] = Field(default_factory=list, description="List of injury codes")
    user_id: str = Field(..., description="ID of the requesting user")
    locale: str = Field(
        default="en",
        description='UI language for exercise names and prompts: "ru" or "en" (default en)',
    )


class ExerciseResponse(BaseModel):
    id: str
    name: str
    type: str
    muscleGroup: str
    sets: Optional[int] = None
    reps: Optional[int] = None
    weightKg: Optional[float] = None
    durationMinutes: Optional[int] = None
    pace: Optional[str] = None
    holdSeconds: Optional[int] = None
    breathCount: Optional[int] = None


class WorkoutResponse(BaseModel):
    id: str
    userId: str
    name: str
    type: str
    exercises: list[ExerciseResponse]

@asynccontextmanager
async def lifespan(app: FastAPI):
    require_jwt_secret()
    logger.info("Warming up model…")
    try:
        ai_model.get_model()
    except Exception as exc:
        logger.error("Model warm-up failed: %s", exc)
    yield


app = FastAPI(title="Gymbro AI Service", lifespan=lifespan)

WEIGHT_RANGES: Dict[str, Tuple[int, int]] = {
    "bench_press": (40, 100),
    "squat": (50, 120),
    "deadlift": (60, 140),
    "shoulder_press": (20, 60),
    "bicep_curl": (8, 25),
    "triceps_extension": (10, 30),
    "pull_up": (0, 20),
    "push_up": (0, 0),
    "lunge": (10, 40),
    "leg_press": (80, 200),
}

def _normalize_generate_locale(locale: str) -> str:
    t = (locale or "en").strip().lower()
    if t == "ru":
        return "ru"
    return "en"


def _exercise_display_name(catalog_entry: dict, locale: str) -> str:
    if locale == "ru":
        return catalog_entry["name"]
    return catalog_entry.get("name_en") or catalog_entry["name"]


def _get_random_weight(exercise_id: str, default_min: int = 5, default_max: int = 50) -> int:
    if exercise_id in WEIGHT_RANGES:
        min_w, max_w = WEIGHT_RANGES[exercise_id]
        if min_w == max_w == 0:
            return 0
        return random.randint(min_w, max_w)
    return random.randint(default_min, default_max)

def _map_exercise(ai_ex: dict, injuries: list[str], locale: str) -> Optional[ExerciseResponse]:
    ex_id: str = ai_ex.get("exercise_id", "")
    catalog_entry = lookup(ex_id)
    if catalog_entry is None:
        logger.warning("Skipping unknown exercise_id: %s", ex_id)
        return None

    if injuries and not is_safe_for_injuries(ex_id, injuries):
        logger.warning("Skipping contraindicated exercise: %s (injuries=%s)", ex_id, injuries)
        return None

    weight_kg = ai_ex.get("weight_kg")
    
    if catalog_entry.get("type") == "strength" and weight_kg is None:
        weight_kg = _get_random_weight(ex_id)
        logger.info("Generated random weight for %s: %d kg", ex_id, weight_kg)
        
        if weight_kg == 0:
            logger.info("Exercise %s is bodyweight only", ex_id)

    return ExerciseResponse(
        id=ex_id,
        name=_exercise_display_name(catalog_entry, locale),
        type=catalog_entry["type"],
        muscleGroup=catalog_entry["muscleGroup"],
        sets=ai_ex.get("sets"),
        reps=ai_ex.get("reps"),
        weightKg=weight_kg,
        durationMinutes=ai_ex.get("duration_minutes"),
        pace=ai_ex.get("pace"),
        holdSeconds=ai_ex.get("hold_seconds"),
        breathCount=ai_ex.get("breath_count"),
    )


def _validate_schema(data: dict) -> None:
    try:
        jsonschema.validate(instance=data, schema=_WORKOUT_SCHEMA)
    except jsonschema.ValidationError as exc:
        raise HTTPException(
            status_code=422,
            detail=f"Model output failed schema validation: {exc.message}",
        )

@app.post("/ai/generate", response_model=WorkoutResponse)
async def generate_workout(
    req: GenerateRequest,
    jwt_user_id: str = Depends(get_authenticated_user_id),
) -> WorkoutResponse:
    if req.user_id != jwt_user_id:
        raise HTTPException(status_code=403, detail="forbidden")

    validate_input(req.user_input, req.injuries)
    locale = _normalize_generate_locale(req.locale)

    messages = build_messages(req.user_input, req.injuries, locale)

    try:
        ai_data = ai_model.generate(messages)
    except ValueError as exc:
        logger.error("Inference error: %s", exc)
        raise HTTPException(status_code=503, detail="Model failed to generate a valid workout. Please try again.")

    _validate_schema(ai_data)

    exercises: list[ExerciseResponse] = []
    for raw_ex in ai_data.get("exercises", []):
        mapped = _map_exercise(raw_ex, req.injuries, locale)
        if mapped is not None:
            exercises.append(mapped)

    if not exercises:
        raise HTTPException(
            status_code=422,
            detail="Generated workout contains no valid exercises for the given constraints.",
        )

    return WorkoutResponse(
        id=str(uuid.uuid4()),
        userId=jwt_user_id,
        name=ai_data["workout_name"],
        type=ai_data["type"],
        exercises=exercises,
    )

@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
