"""
Bakwaas — Core Engine
Free, local, Hinglish-optimized voice dictation for Mac.
"""

import os
import sys

# Ensure Homebrew and standard binaries are in PATH for background GUI execution
os.environ["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:" + os.environ.get("PATH", "")

import time
import argparse
import subprocess
import re
import wave
import threading
import warnings
import numpy as np
import sounddevice as sd
import torch
from transformers import pipeline, WhisperProcessor
from indic_transliteration import sanscript
from indic_transliteration.sanscript import SchemeMap, SCHEMES, transliterate

warnings.filterwarnings("ignore")

# --- CONFIGURATION ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "models", "trelis-hinglish")
STOP_FILE = os.path.join(BASE_DIR, ".stop_bakwaas")
SAMPLE_RATE = 16000
CHANNELS = 1

# Lazy loading global variables
_pipeline = None
_processor = None
_device = None

# Custom corrections (Proper Nouns, Acronyms)
CORRECTIONS = {
    r"\bronin\b": "Ronin",
    r"\bjamshedpur\b": "Jamshedpur",
    r"\bbakwaas\b": "Bakwaas",
}

def save_wav(filename, audio_data):
    """Saves numpy float32 audio array to 16kHz mono 16-bit PCM WAV."""
    pcm_data = (audio_data * 32767).astype(np.int16).tobytes()
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(pcm_data)

def get_pipeline_and_processor():
    global _pipeline, _processor, _device
    if _pipeline is None:
        print("🧠 Loading Bakwaas model...")
        
        # Suppress transformers verbose logging
        import logging
        logging.getLogger("transformers").setLevel(logging.ERROR)
        
        _device = "mps" if torch.backends.mps.is_available() else "cpu"
        dtype = torch.float16 if _device == "mps" else torch.float32
        
        _processor = WhisperProcessor.from_pretrained(MODEL_PATH)
        
        _pipeline = pipeline(
            "automatic-speech-recognition",
            model=MODEL_PATH,
            device=_device,
            dtype=dtype
        )
        print("✅ Model ready! Bakwaas shuru karo! 🎤\n")
    return _pipeline, _processor, _device

def record_audio_fixed(duration, filename="temp.wav"):
    print(f"🎤 Recording for {duration} seconds... Bolo!")
    recording = sd.rec(int(duration * SAMPLE_RATE), samplerate=SAMPLE_RATE, channels=CHANNELS, dtype='float32')
    sd.wait()
    print("⏹️ Recording done!")
    save_wav(filename, recording)
    return filename

def record_audio_continuous(filename="temp.wav"):
    print("🎤 Recording continuously... Press ENTER to stop.")
    
    recording = []
    is_recording = True

    def _record():
        with sd.InputStream(samplerate=SAMPLE_RATE, channels=CHANNELS, dtype='float32') as stream:
            while is_recording:
                data, overflowed = stream.read(SAMPLE_RATE)
                recording.append(data)

    thread = threading.Thread(target=_record)
    thread.start()
    
    # In background (Hammerspoon), input() raises EOFError.
    # We poll for a stop file or catch KeyboardInterrupt.
    # We poll for a stop file or catch KeyboardInterrupt.
    if os.path.exists(STOP_FILE):
        os.remove(STOP_FILE)
        
    try:
        if sys.stdin and sys.stdin.isatty():
            input() # Wait for Enter key if in terminal
        else:
            while not os.path.exists(STOP_FILE):
                time.sleep(0.2)
    except (KeyboardInterrupt, EOFError):
        pass
        
    is_recording = False
    thread.join()
    
    print("⏹️ Recording stopped!")
    audio_data = np.concatenate(recording, axis=0)
    save_wav(filename, audio_data)
    return filename

def apply_corrections(text):
    for pattern, replacement in CORRECTIONS.items():
        text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)
    return text

def devanagari_to_roman(text):
    """Convert Devanagari script to Roman/Latin (Hinglish)."""
    roman_text = transliterate(text, sanscript.DEVANAGARI, sanscript.ITRANS)
    # Basic ITRANS cleanup: convert to lower to normalize long vowels like 'A', 'I'
    roman_text = roman_text.lower()
    return roman_text

def clean_hinglish_script(text):
    """Clean ITRANS artifacts to natural WhatsApp/Slack Hinglish."""
    # 1. Fix punctuation
    text = text.replace('|', '.')
    
    # 2. Nasalizations and specific words
    replacements = {
        r"hu\.n": "hoon",
        r"huu\.n": "hoon",
        r"maim": "main",
        r"nahim": "nahin",
        r"aura": "aur",
        r"nama": "naam",
        r"pasamda": "pasand",
        r"bilakula": "bilkul",
        r"birayani": "biryani",
        r"ronina": "Ronin",
        r"jamashedapura": "Jamshedpur",
        r"karana": "karna"
    }
    for wrong, right in replacements.items():
        text = re.sub(r'\b' + wrong + r'\b', right, text, flags=re.IGNORECASE)
        
    # 3. Generic cleanup
    text = text.replace('.n', 'n') # Any remaining generic nasal .n
    text = re.sub(r'\s+', ' ', text).strip() # Fix multiple spaces
    
    return text

def transcribe(audio_path):
    print("🔄 Transcribing...")
    pipe, processor, device = get_pipeline_and_processor()
    
    result = pipe(
        audio_path,
        generate_kwargs={
            "language": "en",
            "task": "transcribe"
        }
    )
    
    raw_text = result["text"].strip()
    roman_text = devanagari_to_roman(raw_text)
    cleaned_text = clean_hinglish_script(roman_text)
    return cleaned_text

def paste_to_cursor(text):
    subprocess.run("pbcopy", text=True, input=text, check=True)
    applescript = """
    tell application "System Events"
        keystroke "v" using command down
    end tell
    """
    subprocess.run(["osascript", "-e", applescript])
    print("\n📋 Text pasted at cursor!")

def main():
    print("\n🗣️💨📝 BAKWAAS — Bakwaas karo, kaam ho jaaye!\n")
    
    parser = argparse.ArgumentParser(description="Bakwaas Dictation Engine")
    parser.add_argument("-d", "--duration", type=int, default=5, help="Recording duration in seconds")
    parser.add_argument("-c", "--continuous", action="store_true", help="Record until Enter is pressed")
    parser.add_argument("-f", "--file", type=str, help="Transcribe existing WAV file")
    parser.add_argument("--no-paste", action="store_true", help="Do not paste to clipboard/cursor")
    
    args = parser.parse_args()

    audio_file = "temp.wav"
    
    if args.file:
        audio_file = args.file
        print(f"📂 Using existing file: {audio_file}")
    elif args.continuous:
        record_audio_continuous(audio_file)
    else:
        record_audio_fixed(args.duration, audio_file)

    text = transcribe(audio_file)
    text = apply_corrections(text)
    
    print(f"\n✅ Final: {text}")

    if not args.no_paste:
        paste_to_cursor(text)

if __name__ == "__main__":
    main()