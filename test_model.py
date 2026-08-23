#!/usr/bin/env python3
"""
Test loading the Trelis/whisper-hinglish-preview model.
"""
import os
import torch
from transformers import AutoModelForSpeechSeq2Seq, AutoProcessor

def test_model_load():
    MODEL_PATH = os.path.join(os.path.dirname(__file__), "models", "trelis-hinglish")
    
    print(f"🔍 Testing model load from: {MODEL_PATH}")
    
    if not os.path.exists(MODEL_PATH):
        print(f"❌ Error: Model directory not found. Please run download_model.py first.")
        return

    if torch.backends.mps.is_available():
        device = "mps"
        torch_dtype = torch.float16
        print("⚡ Using Apple Metal Performance Shaders (MPS)")
    else:
        device = "cpu"
        torch_dtype = torch.float32
        print("🐢 Using CPU")

    try:
        print("1️⃣ Loading Processor and Tokenizer...")
        processor = AutoProcessor.from_pretrained(MODEL_PATH)
        print("✅ Processor loaded successfully.")

        print("2️⃣ Loading Model...")
        model = AutoModelForSpeechSeq2Seq.from_pretrained(
            MODEL_PATH,
            dtype=torch_dtype,
            low_cpu_mem_usage=True,
            use_safetensors=True
        )
        model.to(device)
        print("✅ Model loaded successfully.")
        
        print("\n🎉 Model is ready to use!")
    except Exception as e:
        print(f"\n❌ Error loading model: {e}")

if __name__ == "__main__":
    test_model_load()
