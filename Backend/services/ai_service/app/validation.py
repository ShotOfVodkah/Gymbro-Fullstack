import re
from fastapi import HTTPException

MAX_INPUT_LENGTH = 500

_JAILBREAK_PATTERNS: list[re.Pattern] = [
    re.compile(r"ignore\s+(previous|all|prior)\s+instructions?", re.I),
    re.compile(r"forget\s+(your\s+)?(previous\s+)?instructions?", re.I),
    re.compile(r"you\s+are\s+now\s+", re.I),
    re.compile(r"pretend\s+(you\s+are|to\s+be)", re.I),
    re.compile(r"\bdan\b", re.I),
    re.compile(r"act\s+as\s+(if\s+you\s+(are|were)|a\b)", re.I),
    re.compile(r"\bsystem\s*:", re.I),
    re.compile(r"<\|im_start\|>", re.I),
    re.compile(r"<\|im_end\|>", re.I),
    # Prompt-injection via embedded JSON or angle brackets
    re.compile(r"<\s*/?[a-z]", re.I),
    # Multi-line injection attempt
    re.compile(r"\\n\s*(system|assistant|user)\s*:", re.I),
    re.compile(r"jailbreak", re.I),
    re.compile(r"do\s+anything\s+now", re.I),
]

ALLOWED_INJURIES = {
    "knee_injury",
    "shoulder_injury",
    "lower_back_pain",
    "wrist_injury",
    "neck_injury",
    "ankle_injury",
    "high_blood_pressure",
    "elbow_injury",
    "pregnancy",
}


def validate_input(user_input: str, injuries: list[str]) -> None:
    if not user_input or not user_input.strip():
        raise HTTPException(status_code=400, detail="user_input must not be empty")
    if len(user_input) > MAX_INPUT_LENGTH:
        raise HTTPException(
            status_code=400,
            detail=f"user_input exceeds maximum length of {MAX_INPUT_LENGTH} characters",
        )
    for pattern in _JAILBREAK_PATTERNS:
        if pattern.search(user_input):
            raise HTTPException(
                status_code=400,
                detail="Input contains disallowed content",
            )
    unknown = [inj for inj in injuries if inj not in ALLOWED_INJURIES]
    if unknown:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown injury codes: {unknown}. Allowed: {sorted(ALLOWED_INJURIES)}",
        )
