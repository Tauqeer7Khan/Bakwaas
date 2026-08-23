"""
Bakwaas — Model Downloader
Downloads Trelis/whisper-hinglish-preview model locally.
"""

import os
from huggingface_hub import snapshot_download

MODEL_ID = "Trelis/whisper-hinglish-preview"
LOCAL_DIR = "./models/trelis-hinglish"

def download():
    print(f"🚀 Downloading model '{MODEL_ID}'...")
    print(f"📁 Target directory: {os.path.abspath(LOCAL_DIR)}\n")
    
    os.makedirs(LOCAL_DIR, exist_ok=True)
    
    snapshot_download(
        repo_id=MODEL_ID,
        local_dir=LOCAL_DIR,
        local_dir_use_symlinks=False,
        resume_download=True
    )
    
    print("\n✅ Model successfully downloaded to:", LOCAL_DIR)

if __name__ == "__main__":
    download()
