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
        if torch.backends.mps.is_available():
            device = "mps"
        else:
            device = "cpu"
            print("Warning: MPS (Metal) not available. Falling back to CPU.", file=sys.stderr)
            
        _pipeline = pipeline(
            "automatic-speech-recognition",
            model=MODEL_PATH,
            device=device,
            torch_dtype=torch.float16,
            chunk_length_s=30
        )
    return _pipeline

def record_audio_fixed(duration, filename="temp.wav"):
    recording = []
    frames_to_record = int(duration * SAMPLE_RATE)
    frames_recorded = 0
    try:
        with sd.InputStream(samplerate=SAMPLE_RATE, channels=CHANNELS, dtype='float32') as stream:
            while frames_recorded < frames_to_record:
                # Read in smaller chunks for responsiveness
                chunk_size = min(4000, frames_to_record - frames_recorded)
                data, _ = stream.read(chunk_size)
                recording.append(data)
                frames_recorded += chunk_size
    except sd.PortAudioError as e:
        print(f"Error: Could not open audio input device. Please check microphone permissions. ({e})", file=sys.stderr)
        sys.exit(1)

    audio_data = np.concatenate(recording, axis=0)
    save_wav(filename, audio_data)
    return filename

def record_audio_continuous(filename="temp.wav"):
    recording = []
    is_recording = True
    error_msg = None

    def _record():
        nonlocal error_msg
        try:
            with sd.InputStream(samplerate=SAMPLE_RATE, channels=CHANNELS, dtype='float32') as stream:
                while is_recording:
                    # Read 0.25s chunks for better responsiveness to stop event
                    data, _ = stream.read(4000)
                    recording.append(data)
        except sd.PortAudioError as e:
            error_msg = f"Error: Could not open audio input device. Please check microphone permissions. ({e})"

    thread = threading.Thread(target=_record)
    thread.start()

    if os.path.exists(STOP_FILE):
        os.remove(STOP_FILE)

    try:
        if sys.stdin and sys.stdin.isatty():
            input()
        else:
            while not os.path.exists(STOP_FILE) and error_msg is None:
                time.sleep(0.1)
    except (KeyboardInterrupt, EOFError):
        pass

    is_recording = False
    thread.join()
    
    if error_msg:
        print(error_msg, file=sys.stderr)
        sys.exit(1)

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
    try:
        if args.file:
            audio_file = args.file
        elif args.continuous:
            record_audio_continuous(audio_file)
        else:
            record_audio_fixed(args.duration, audio_file)

        text = transcribe(audio_file)
        copy_to_clipboard(text)
        print(text)
    finally:
        if not args.file and os.path.exists(audio_file):
            try:
                os.remove(audio_file)
            except Exception:
                pass

if __name__ == "__main__":
    main()