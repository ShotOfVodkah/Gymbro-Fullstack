
from __future__ import annotations

import json
import logging
import os
import re
import threading
from pathlib import Path
from typing import Optional

import torch
from huggingface_hub import snapshot_download
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer

logger = logging.getLogger(__name__)

_BASE_MODEL_NAME = os.getenv("BASE_MODEL_NAME", "Qwen/Qwen2.5-7B-Instruct")
_LORA_PATH = Path(__file__).parent.parent / "workout_lora_model"
_HF_CACHE = os.getenv("HF_HOME", "/root/.cache/huggingface")

_lock = threading.Lock()
_tokenizer: Optional[AutoTokenizer] = None
_model: Optional[PeftModel] = None


def _load_model() -> tuple[AutoTokenizer, PeftModel]:
    logger.info("Step 1/4 — Checking/downloading model files for %s…", _BASE_MODEL_NAME)
    local_path = snapshot_download(
        repo_id=_BASE_MODEL_NAME,
        cache_dir=_HF_CACHE,
        # Skip non-PyTorch checkpoints to save bandwidth
        ignore_patterns=["*.msgpack", "flax_model*", "tf_model*", "rust_model*"],
    )
    logger.info("Step 1/4 — Model files ready at %s", local_path)
    logger.info("Step 2/4 — Loading tokenizer from LoRA adapter folder…")
    tokenizer = AutoTokenizer.from_pretrained(
        str(_LORA_PATH),
        trust_remote_code=True,
    )
    logger.info("Step 2/4 — Tokenizer ready (vocab size: %d)", len(tokenizer))
    logger.info("Step 3/4 — Loading base model weights into RAM (float16, CPU) — this takes a few minutes…")
    base = AutoModelForCausalLM.from_pretrained(
        local_path,
        torch_dtype=torch.float16,
        device_map="cpu",
        trust_remote_code=True,
    )
    logger.info("Step 3/4 — Base model loaded (%d parameters)", sum(p.numel() for p in base.parameters()))
    logger.info("Step 4/4 — Applying LoRA adapter from %s…", _LORA_PATH)
    model = PeftModel.from_pretrained(base, str(_LORA_PATH))
    model.eval()
    logger.info("Step 4/4 — Model ready. Startup complete.")
    return tokenizer, model


def get_model() -> tuple[AutoTokenizer, PeftModel]:
    global _tokenizer, _model
    if _model is None:
        with _lock:
            if _model is None:
                _tokenizer, _model = _load_model()
    return _tokenizer, _model


def _extract_json(raw: str) -> Optional[str]:
    for marker in ("assistant\n", "<|im_start|>assistant\n"):
        if marker in raw:
            raw = raw.split(marker)[-1]

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
    tokenizer, model = get_model()

    text = tokenizer.apply_chat_template(
        messages,
        tokenize=False,
        add_generation_prompt=True,
    )

    last_error: Exception = ValueError("no attempts made")

    for attempt in range(1, max_retries + 2):
        logger.info("Inference attempt %d/%d", attempt, max_retries + 1)
        inputs = tokenizer(text, return_tensors="pt")

        with torch.no_grad():
            output_ids = model.generate(
                **inputs,
                max_new_tokens=512,
                do_sample=False,
                pad_token_id=tokenizer.pad_token_id or tokenizer.eos_token_id,
            )

        new_ids = output_ids[0][inputs["input_ids"].shape[1]:]
        raw = tokenizer.decode(new_ids, skip_special_tokens=True)
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

    raise ValueError(f"Model failed to produce valid JSON after {max_retries + 1} attempts: {last_error}")
