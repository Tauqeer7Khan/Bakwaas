# 🗣️💨📝 Bakwaas

> **"Bakwaas karo, kaam ho jaaye"** — Turn your bakwaas into text.

![macOS](https://img.shields.io/badge/macOS-13%2B-000000?style=for-the-badge&logo=apple&logoColor=white)
![Apple Silicon](https://img.shields.io/badge/Apple_Silicon-M1%2F2%2F3%2F4%2F5-000000?style=for-the-badge&logo=apple&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11%2B-3776AB?style=for-the-badge&logo=python&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

## What is Bakwaas?
Bakwaas is a free, fully local, Hinglish-optimized voice dictation tool built natively for macOS (Apple Silicon). 

It works exactly like Wispr Flow — you hold a hotkey, speak your mind, and your words are instantly typed at your cursor. The magic? It runs entirely on your device, ensuring 100% privacy, and is specifically optimized for people who speak in **Hinglish** (a natural mix of Hindi and English).

## Why does it exist?
I was tired of typing. I felt like typing was slowing down my thinking, so I started looking for voice-to-text tools. 

I hit the weekly limits on Wispr Flow. I looked at alternatives like SuperWhisper, VoiceInk, and FreeFlow. But almost all of them were either heavily paid, had strict usage limits, or completely failed to understand how I actually talk (Hinglish).

None of the free options worked well for code-switching between Hindi and English in a single sentence. So, I decided to build it myself: a completely free, local, Hinglish-native dictation engine for Mac.

## How do I use it? (Quick Start)

Once installed, Bakwaas runs invisibly in the background. You interact with it entirely using the `Fn` key from *any* app on your Mac (Notion, VS Code, Browser, Terminal, etc.).

| Hotkey | Action |
|---|---|
| **Hold `Fn` key** | **Hold-to-Talk:** Starts recording when pressed down. Release to stop recording and instantly paste the transcribed text at your cursor. |
| **Double Tap `Fn` key** | **Continuous Mode:** Locks recording state ON. Speak freely, then tap `Fn` once more to stop recording and paste. |

> **Behavior Note:** Transcribed text is instantly pasted at the active cursor, AND simultaneously stored in the macOS clipboard (so you can `Cmd+V` paste it manually later if needed).

## How do I install it?
Because Bakwaas runs large AI models entirely on your local machine, setup takes a few steps. You'll need an Apple Silicon Mac (M1/M2/M3/M4/M5) with at least 16GB of RAM.

For a comprehensive step-by-step installation guide, check out:
👉 **[SETUP.md](docs/SETUP.md)**

*Having issues during installation? Check the **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)***

## What's under the hood? (System Architecture)
Bakwaas strings together several incredibly powerful open-source tools to create a seamless macOS experience:

```text
🎤 MICROPHONE
↓
⌨️ HAMMERSPOON (Intercepts Fn key presses globally)
↓
🔊 SOUNDDEVICE (Captures raw mic input as 16kHz mono WAV)
↓
🧠 HINGLISH WHISPER MODEL (Trelis/whisper-hinglish-preview)
   Transcribes Hinglish audio using Apple MPS hardware acceleration.
↓
🔤 INDIC-TRANSLITERATION (Post-processes Devanagari to clean Roman Hinglish)
↓
📋 APPLESCRIPT (Copies final text to clipboard & executes Cmd+V at the cursor)
↓
📝 ANY APP ON YOUR MAC
```

### Core Tech Stack
- **Speech Engine / Model:** [Trelis/whisper-hinglish-preview](https://huggingface.co/Trelis/whisper-hinglish-preview) (1.55B params, Whisper large-v3 based)
- **System Hotkeys:** Hammerspoon & Lua
- **Audio Capture:** `sounddevice` + `ffmpeg`
- **Text Processing:** `indic-transliteration` & Regex
- **Hardware Acceleration:** PyTorch with Apple Metal Performance Shaders (MPS)

## How can I contribute?
Contributions are incredibly welcome! Whether you want to improve the Hinglish regex corrections, optimize the Hammerspoon UI, or add new features, we'd love your help. Check out **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** for guidelines.

## Credits & Acknowledgments
A massive shoutout to the open-source community that makes this possible. Special thanks to the teams behind the **Oriserve** and **Trelis** Hinglish Whisper models, which form the absolute core brain of this dictation engine.

---
**Built by [Tauqeer Khan](https://www.linkedin.com/in/tauqeer7khan/)**  
[GitHub Repository](https://github.com/Tauqeer7Khan/Bakwaas)
