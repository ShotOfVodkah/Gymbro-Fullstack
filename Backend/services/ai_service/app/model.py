from __future__ import annotations

import json
import logging
import os
import re
import threading
from pathlib import Path
from typing import TYPE_CHECKING, Optional

if TYPE_CHECKING:
    from llama_cpp import Llama

logger = logging.getLogger(__name__)

_GGUF_PATH = Path(__file__).parent.parent / "workout_q4km.gguf"

_lock = threading.Lock()
_model: Optional[Llama] = None


def _load_model() -> Llama:
    from llama_cpp import Llama

    logger.info("Loading GGUF model from %s…", _GGUF_PATH)
    if not _GGUF_PATH.exists():
        raise FileNotFoundError(
            f"GGUF model not found at {_GGUF_PATH}. "
            "Run scripts/merge_and_convert.py to generate workout_q4km.gguf first."
        )
    model = Llama(
        model_path=str(_GGUF_PATH),
        n_ctx=2048,
        n_threads=int(os.getenv("LLAMA_N_THREADS", str(os.cpu_count() or 4))),
        n_gpu_layers=0,
        verbose=False,
        chat_format="chatml",
    )
    logger.info("GGUF model loaded successfully.")
    return model


def get_model() -> Llama:
    global _model
    if _model is None:
        with _lock:
            if _model is None:
                _model = _load_model()
    return _model


def _extract_json(raw: str) -> Optional[str]:
    raw = raw.strip()
    try:
        json.loads(raw)
        return raw
    except json.JSONDecodeError:
        pass
    match = re.search(r"\{.*\}", raw, re.DOTALL)
    if match:
        candidate = match.group(0)
        try:
            json.loads(candidate)
            return candidate
        except json.JSONDecodeError:
            pass
    return None


def generate(messages: list[dict], max_retries: int = 2) -> dict:
    model = get_model()

    last_error: Exception = ValueError("no attempts made")

    for attempt in range(1, max_retries + 2):
        logger.info("Inference attempt %d/%d", attempt, max_retries + 1)

        response = model.create_chat_completion(
            messages=messages,
            max_tokens=512,
            temperature=0.0,
        )

        raw: str = response["choices"][0]["message"]["content"]
        logger.debug("Raw model output: %s", raw[:300])

        json_str = _extract_json(raw)
        if json_str is not None:
            try:
                return json.loads(json_str)
            except json.JSONDecodeError as exc:
                last_error = exc
        else:
            last_error = ValueError(f"No JSON object found in output: {raw[:200]}")

        logger.warning("Attempt %d produced invalid JSON, retrying…", attempt)

    raise ValueError(
        f"Model failed to produce valid JSON after {max_retries + 1} attempts: {last_error}"
    )
