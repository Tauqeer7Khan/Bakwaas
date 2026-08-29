"""
Bakwaas — Core Engine
Free, local, Hinglish-optimized voice dictation for Mac.
"""

import os
import sys
import time
import argparse
import subprocess
import wave
import threading
import warnings
import numpy as np
import sounddevice as sd

os.environ["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:" + os.environ.get("PATH", "")
warnings.filterwarnings("ignore")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = "openai/whisper-small"
STOP_FILE = os.path.join(BASE_DIR, ".stop_bakwaas")
SAMPLE_RATE = 16000
CHANNELS = 1

_pipeline = None

def save_wav(filename, audio_data):
    pcm_data = (audio_data * 32767).astype(np.int16).tobytes()
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(pcm_data)

def get_pipeline():
    global _pipeline
    if _pipeline is None:
        import logging
        import torch
        from transformers import pipeline
        
        logging.getLogger("transformers").setLevel(logging.ERROR)
        device = "mps" if torch.backends.mps.is_available() else "cpu"
        _pipeline = pipeline(
            "automatic-speech-recognition",
            model=MODEL_PATH,
            device=device,
            torch_dtype=torch.float16,
            chunk_length_s=30
        )
    return _pipeline

def record_audio_fixed(duration, filename="temp.wav"):
    recording = sd.rec(int(duration * SAMPLE_RATE), samplerate=SAMPLE_RATE, channels=CHANNELS, dtype='float32')
    sd.wait()
    save_wav(filename, recording)
    return filename

def record_audio_continuous(filename="temp.wav"):
    recording = []
    is_recording = True

    def _record():
        with sd.InputStream(samplerate=SAMPLE_RATE, channels=CHANNELS, dtype='float32') as stream:
            while is_recording:
                data, _ = stream.read(SAMPLE_RATE)
                recording.append(data)

    thread = threading.Thread(target=_record)
    thread.start()

    if os.path.exists(STOP_FILE):
        os.remove(STOP_FILE)

    try:
        if sys.stdin and sys.stdin.isatty():
            input()
        else:
            while not os.path.exists(STOP_FILE):
                time.sleep(0.1)
    except (KeyboardInterrupt, EOFError):
        pass

    is_recording = False
    thread.join()

    audio_data = np.concatenate(recording, axis=0)
    save_wav(filename, audio_data)
    return filename

def transcribe(audio_path):
    pipe = get_pipeline()
    result = pipe(audio_path)
    return result["text"].strip()

def copy_to_clipboard(text):
    subprocess.run("pbcopy", text=True, input=text, check=True)

def main():
    parser = argparse.ArgumentParser(description="Bakwaas Engine")
    parser.add_argument("-d", "--duration", type=int, default=5)
    parser.add_argument("-c", "--continuous", action="store_true")
    parser.add_argument("-f", "--file", type=str)
    args = parser.parse_args()

    audio_file = "temp.wav"
    if args.file:
        audio_file = args.file
    elif args.continuous:
        record_audio_continuous(audio_file)
    else:
        record_audio_fixed(args.duration, audio_file)

    text = transcribe(audio_file)
    copy_to_clipboard(text)
    print(text)

if __name__ == "__main__":
    main()