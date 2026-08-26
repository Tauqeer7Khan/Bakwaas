# 🗣️💨📝 Bakwaas

> **"Bakwaas karo, kaam ho jaaye"**
>
> Turn your bakwaas into text — free, local, Hinglish dictation for Mac

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS-blue.svg)]()
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-Optimized-green.svg)]()
[![Status](https://img.shields.io/badge/Status-In%20Progress-yellow.svg)]()

---

## 🤔 The Problem

I was tired of typing — tired of typing prompts to AI, tired of typing messages, ideas, and thoughts. Voice-to-text was the solution.

But every tool I tried was either:
- **Paid** (Wispr Flow $15/mo, Superwhisper $8.49/mo)
- **Had usage limits** (hit Wispr Flow's weekly limit)
- **Cloud-based** (voice data leaves your device)
- **Didn't understand Hinglish** (Hindi + English mixed speech)

So I built Bakwaas.

---

## ✅ What is Bakwaas?

Bakwaas is a **free, fully local, Hinglish-optimized** voice dictation tool for Mac. Hold a hotkey → speak → text appears at your cursor. Works in any app.

- 🆓 **100% Free** — no subscription, no limits, ever
- 🔒 **100% Local** — your voice never leaves your Mac
- 🇮🇳 **Hinglish-native** — trained on 1000+ hours of Indian audio
- ⌨️ **System-wide** — Notion, Slack, VS Code, browser, anywhere
- ⚡ **Fast** — Apple Silicon Metal acceleration
- 🧹 **AI cleanup** — optional local LLM removes filler words

---

## 🛠️ Tech Stack

| Component | Tool |
|---|---|
| Speech Engine | whisper.cpp (Metal accelerated) |
| Hinglish Model | Trelis/whisper-hinglish-preview (1.55B params, Whisper large-v3 based) |
| Hotkeys | Hammerspoon (Fn key event tap) |
| Audio Capture | sounddevice + ffmpeg |
| Text Cleanup | indic-transliteration + regex (local, instant) |

---

## 🚀 Quick Start

```bash
git clone https://github.com/Tauqeer7Khan/Bakwaas
cd bakwaas
bash install.sh
```

## ⌨️ Hotkeys

| Hotkey | Action |
|---|---|
| Hold `Fn` key | Hold-to-Talk: Starts recording when pressed, stops and transcribes when released |
| Double Tap `Fn` key | Continuous Mode: Locks recording on. Tap `Fn` once more to stop and transcribe |

**Behavior:** Transcribed text is instantly pasted at the active cursor using AppleScript, AND is simultaneously stored in the macOS clipboard (via pbcopy) for manual pasting later.

## 💻 Requirements

- macOS 13+ (Ventura or later)
- Apple Silicon Mac — M1 / M2 / M3 / M4 / M5
- 16GB RAM (recommended)
- ~15GB free disk space

## 🏗️ Architecture

```text
🎤 Mic → Hammerspoon → sounddevice → Oriserve Hinglish Model → [Ollama Cleanup] → AppleScript → 📝 Any App
```

## 📁 Project Structure

```text
bakwaas/
├── bakwaas.py ← Core dictation engine
├── download_model.py ← Model downloader
├── test_model.py ← Model test script
├── cleanup.py ← Ollama text cleanup
├── install.sh ← One-click installer
├── requirements.txt ← Python dependencies
├── hammerspoon/
│   └── init.lua ← Hotkey config
└── docs/ ← Documentation
```

## 🗺️ Roadmap

- [x] Project scaffolding
- [x] Phase 1 — Environment setup
- [x] Phase 2 — whisper.cpp build
- [x] Phase 3 — Hinglish model download
- [x] Phase 4 — Core dictation engine
- [x] Phase 5 — Hammerspoon Fn key hotkeys
- [ ] Phase 5.5 — Visual Indicator (Floating Pill UI)
- [ ] Phase 6 — Ollama text cleanup (optional)
- [x] Phase 7 — GitHub publish
- [ ] Phase 8 — LinkedIn post

## 🙏 Credits

- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) — Georgi Gerganov
- [Oriserve](https://huggingface.co/Oriserve) — Hinglish Whisper model
- [Trelis Research](https://huggingface.co/Trelis) — Hinglish Whisper large-v3 model
- [Hammerspoon](https://www.hammerspoon.org/) — macOS automation
- [Ollama](https://ollama.com/) — local LLM inference

## 📄 License

MIT — use it, fork it, build on it. Bakwaas karo! 🗣️💨📝
