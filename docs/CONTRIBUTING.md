# 🤝 Contributing to Bakwaas

First off, thank you for considering contributing to Bakwaas! 

## 🌟 Project Vision
Bakwaas is designed to solve a specific problem: **fast, free, local, and Hinglish-native voice dictation for macOS.** 
We are building a tool that respects user privacy (data never leaves the device) and understands the natural code-switching (Hindi + English) that Indian speakers use daily.

## 🏗️ Architecture Overview
Bakwaas uses a streamlined, modular architecture:
1. **Audio Capture**: `sounddevice` records 16kHz mono audio directly from the microphone.
2. **Transcription Engine**: `transformers` pipeline running `openai/whisper-small` (or the Hinglish fine-tune) accelerated via Apple Metal (MPS).
3. **OS Integration**: `Hammerspoon` (Lua) handles global hotkeys (Fn key taps) and rendering the Floating Pill UI.
4. **Text Injection**: Python's `subprocess` and Hammerspoon seamlessly utilize the macOS clipboard (`pbcopy`) and AppleScript (`Cmd+V`) to paste text instantly into any app.

## 🚀 Setting Up Your Dev Environment
We've made local setup as painless as possible:
1. Clone the repo and navigate to the root directory.
2. Run `make install` to create the virtual environment, install dependencies, and setup the Hammerspoon symlink.
3. Run `make warmup` to preload the Whisper model into RAM for a faster first run.
4. Verify your environment is healthy by running `make health-check`.

## 🧪 Testing Guidelines
When submitting a Pull Request, please ensure you have tested the following core flows:
- **Testing Backend Standalone**: Run `python3 bakwaas.py -d 5` (fixed duration) or `python3 bakwaas.py -c` (continuous, press Enter to stop). This isolates Python errors from Hammerspoon errors.
- **Testing Fn Hold (Hold-to-Talk)**: Press and hold `Fn`, speak, and release. The text should paste instantly.
- **Testing Continuous Mode**: Double-tap `Fn`, speak for an extended period, and double-tap `Fn` to stop.

## 📝 Code Style Guidelines
- **Python Version**: Target Python 3.11+. Use type hints where appropriate.
- **No Cloud APIs**: We are strictly a local-first application. Do not introduce dependencies on external cloud services (e.g., OpenAI API, Google Cloud).
- **Simplicity**: Favor simple, readable code over clever abstractions.
- **Error Handling**: Fail gracefully. Use `sys.stderr` for errors and ensure hardware resources (like the microphone via context managers) are correctly released.

We look forward to your Pull Requests! 🗣️💨📝
