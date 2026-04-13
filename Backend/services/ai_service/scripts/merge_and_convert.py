#!/usr/bin/env python3

from __future__ import annotations

import argparse
import logging
import os
import subprocess
import sys
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
log = logging.getLogger(__name__)

REPO_ROOT = Path(__file__).resolve().parents[3] 
AI_SERVICE = Path(__file__).resolve().parents[1] 
LORA_PATH = AI_SERVICE / "workout_lora_model"
BASE_MODEL = os.getenv("BASE_MODEL_NAME", "Qwen/Qwen2.5-7B-Instruct")
HF_CACHE = os.getenv("HF_HOME", str(Path.home() / ".cache" / "huggingface"))


def merge_lora(out_dir: Path) -> None:
    """Load base model, apply LoRA, merge weights, save."""
    try:
        import torch
        from peft import PeftModel
        from transformers import AutoModelForCausalLM, AutoTokenizer
    except ImportError:
        log.error("Missing dependencies. Run: pip install torch transformers peft accelerate safetensors")
        sys.exit(1)

    log.info("Loading tokenizer from LoRA folder: %s", LORA_PATH)
    tokenizer = AutoTokenizer.from_pretrained(str(LORA_PATH), trust_remote_code=True)

    log.info("Loading base model %s in float16 — this may take a few minutes…", BASE_MODEL)
    base = AutoModelForCausalLM.from_pretrained(
        BASE_MODEL,
        torch_dtype=torch.float16,
        device_map="cpu",
        trust_remote_code=True,
        cache_dir=HF_CACHE,
    )

    log.info("Applying LoRA adapter from %s…", LORA_PATH)
    model = PeftModel.from_pretrained(base, str(LORA_PATH))

    log.info("Merging LoRA weights into base model…")
    model = model.merge_and_unload()
    model.eval()

    out_dir.mkdir(parents=True, exist_ok=True)
    log.info("Saving merged model to %s…", out_dir)
    model.save_pretrained(str(out_dir), safe_serialization=True)
    tokenizer.save_pretrained(str(out_dir))
    log.info("Merge complete. Size on disk: check %s", out_dir)


def convert_to_gguf(merged_dir: Path, gguf_f16: Path, gguf_q4km: Path, llama_cpp_dir: Path) -> None:
    """Convert HF checkpoint → GGUF f16, then quantise to Q4_K_M."""
    convert_script = llama_cpp_dir / "convert_hf_to_gguf.py"
    quantize_bin = llama_cpp_dir / "build" / "bin" / "llama-quantize"

    if not convert_script.exists():
        log.error(
            "llama.cpp not found at %s.\n"
            "Clone and build it first:\n"
            "  git clone https://github.com/ggerganov/llama.cpp\n"
            "  cd llama.cpp && cmake -B build -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS\n"
            "  cmake --build build --config Release -j$(nproc)",
            llama_cpp_dir,
        )
        sys.exit(1)

    if not quantize_bin.exists():
        log.error(
            "llama-quantize binary not found at %s.\n"
            "Build llama.cpp first (see instructions above).",
            quantize_bin,
        )
        sys.exit(1)

    log.info("Converting merged HF model → GGUF f16…")
    subprocess.run(
        [sys.executable, str(convert_script), str(merged_dir), "--outfile", str(gguf_f16), "--outtype", "f16"],
        check=True,
    )
    log.info("GGUF f16 written to %s", gguf_f16)

    log.info("Quantising f16 GGUF → Q4_K_M (~4.1 GB)…")
    subprocess.run(
        [str(quantize_bin), str(gguf_f16), str(gguf_q4km), "Q4_K_M"],
        check=True,
    )
    log.info("Q4_K_M GGUF written to %s", gguf_q4km)

    log.info("You can now delete the f16 intermediate: %s", gguf_f16)


def main() -> None:
    parser = argparse.ArgumentParser(description="Merge LoRA and convert to GGUF Q4_K_M")
    parser.add_argument("--out-dir", type=Path, default=AI_SERVICE / "workout_merged_model",
                        help="Directory to save the merged HF model (default: ai_service/workout_merged_model)")
    parser.add_argument("--gguf-f16", type=Path, default=AI_SERVICE / "workout_f16.gguf",
                        help="Intermediate GGUF f16 output path")
    parser.add_argument("--gguf-q4km", type=Path, default=AI_SERVICE / "workout_q4km.gguf",
                        help="Final Q4_K_M GGUF output path (used by the service)")
    parser.add_argument("--llama-cpp-dir", type=Path, default=Path.home() / "llama.cpp",
                        help="Path to cloned+built llama.cpp repository")
    parser.add_argument("--skip-merge", action="store_true",
                        help="Skip the HF merge step (if merged model already exists)")
    parser.add_argument("--skip-convert", action="store_true",
                        help="Skip the GGUF conversion step")
    args = parser.parse_args()

    if not args.skip_merge:
        merge_lora(args.out_dir)
    else:
        log.info("Skipping merge step (--skip-merge)")

    if not args.skip_convert:
        convert_to_gguf(args.out_dir, args.gguf_f16, args.gguf_q4km, args.llama_cpp_dir)
    else:
        log.info("Skipping GGUF conversion step (--skip-convert)")
        log.info(
            "\nTo convert manually:\n"
            "  python <llama.cpp>/convert_hf_to_gguf.py %s --outfile %s --outtype f16\n"
            "  <llama.cpp>/build/bin/llama-quantize %s %s Q4_K_M",
            args.out_dir, args.gguf_f16, args.gguf_f16, args.gguf_q4km,
        )

    log.info(
        "\nDone! Place %s at:\n  services/ai_service/workout_q4km.gguf\n"
        "then rebuild the Docker image.",
        args.gguf_q4km,
    )


if __name__ == "__main__":
    main()
