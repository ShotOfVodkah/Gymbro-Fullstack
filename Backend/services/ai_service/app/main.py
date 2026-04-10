from __future__ import annotations

import json
import logging
import uuid
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Optional

import jsonschema
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from app import model as ai_model
from app.catalog import is_safe_for_injuries, lookup
from app.prompt import build_messages
from app.validation import validate_input

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

_SCHEMA_PATH = Path(__file__).parent.parent / "schema.json"
with open(_SCHEMA_PATH) as _f:
    _WORKOUT_SCHEMA: dict = json.load(_f)

class GenerateRequest(BaseModel):
    user_input: str = Field(..., description="Free-text workout request from the user")
    injuries: list[str] = Field(default_factory=list, description="List of injury codes")
    user_id: str = Field(..., description="ID of the requesting user")


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
    logger.info("Warming up model…")
    try:
        ai_model.get_model()
    except Exception as exc:
        logger.error("Model warm-up failed: %s", exc)
    yield


app = FastAPI(title="Gymbro AI Service", lifespan=lifespan)

def _map_exercise(ai_ex: dict, injuries: list[str]) -> Optional[ExerciseResponse]:
    """
    Convert a single AI-output exercise (snake_case) to ExerciseResponse.
    Returns None if the exercise_id is not in the catalog or is contraindicated.
    """
    ex_id: str = ai_ex.get("exercise_id", "")
    catalog_entry = lookup(ex_id)
    if catalog_entry is None:
        logger.warning("Skipping unknown exercise_id: %s", ex_id)
        return None

    if injuries and not is_safe_for_injuries(ex_id, injuries):
        logger.warning("Skipping contraindicated exercise: %s (injuries=%s)", ex_id, injuries)
        return None

    return ExerciseResponse(
        id=ex_id,
        name=catalog_entry["name"],
        type=catalog_entry["type"],
        muscleGroup=catalog_entry["muscleGroup"],
        sets=ai_ex.get("sets"),
        reps=ai_ex.get("reps"),
        weightKg=ai_ex.get("weight_kg"),
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
async def generate_workout(req: GenerateRequest) -> WorkoutResponse:
    validate_input(req.user_input, req.injuries)

    messages = build_messages(req.user_input, req.injuries)

    try:
        ai_data = ai_model.generate(messages)
    except ValueError as exc:
        logger.error("Inference error: %s", exc)
        raise HTTPException(status_code=503, detail="Model failed to generate a valid workout. Please try again.")

    _validate_schema(ai_data)

    exercises: list[ExerciseResponse] = []
    for raw_ex in ai_data.get("exercises", []):
        mapped = _map_exercise(raw_ex, req.injuries)
        if mapped is not None:
            exercises.append(mapped)

    if not exercises:
        raise HTTPException(
            status_code=422,
            detail="Generated workout contains no valid exercises for the given constraints.",
        )

    return WorkoutResponse(
        id=str(uuid.uuid4()),
        userId=req.user_id,
        name=ai_data["workout_name"],
        type=ai_data["type"],
        exercises=exercises,
    )

@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
