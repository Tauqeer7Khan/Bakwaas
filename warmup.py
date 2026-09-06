"""
Bakwaas — Warmup Script
Run this once to preload the Whisper model into RAM/VRAM so your first dictation is fast.
"""

import sys
import torch
import warnings
from transformers import pipeline

warnings.filterwarnings("ignore")

MODEL_PATH = "openai/whisper-small"

def main():
    print("Preloading model...", end=" ", flush=True)
    if torch.backends.mps.is_available():
        device = "mps"
        print("[MPS Metal Acceleration]", flush=True)
    else:
        device = "cpu"
        print("[CPU Fallback]", flush=True)

    # Load pipeline
    _ = pipeline(
        "automatic-speech-recognition",
        model=MODEL_PATH,
        device=device,
        torch_dtype=torch.float16,
        chunk_length_s=30
    )
    print("Ready! 🗣️💨📝")

if __name__ == "__main__":
    main()
