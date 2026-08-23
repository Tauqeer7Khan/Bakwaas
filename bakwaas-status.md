---

# 🗣️💨📝 Bakwaas — Master Project Status File

> **"Bakwaas karo, kaam ho jaaye"**
> Last Updated: 2026-08-23
> Status: 🟡 IN PROGRESS — Scaffolding Complete, Building Today
> Plan: Complete entire project in 1 day 🔥

---

## 🧠 WHAT IS BAKWAAS?

Bakwaas is a free, fully local, Hinglish-optimized voice dictation tool built natively for macOS (Apple Silicon). It works exactly like Wispr Flow — hold a hotkey, speak, and your words are typed at the cursor — but it is 100% free, runs entirely on-device, and is specifically optimized for Hinglish (Hindi + English code-switching) speakers.

**One-liner:** Turn your bakwaas into text — free, local, Hinglish dictation for Mac.

**Tagline:** "Bakwaas karo, kaam ho jaaye"

**Logo:** 🗣️💨📝

---

## ❗ THE CORE PROBLEM (Why Bakwaas Was Built)

The builder was tired of typing. Tired of manually typing prompts to AI tools, tired of typing thoughts, messages, and ideas. Voice-to-text was the obvious solution.

The journey:
1. Tried multiple cloud-based STT (Speech-to-Text) tools — all had privacy concerns (voice data goes to external servers)
2. Tried Wispr Flow — great product, works well, but:
   - Costs $15/month
   - Has weekly usage LIMITS — hit the limit, can't use it for the rest of the week
   - When the limit was hit, there was NO good free alternative
3. Researched all alternatives:
   - SuperWhisper: $8.49/month or $249.99 lifetime
   - Weesper Neon Flow: €5/month
   - FreeFlow: Free but not Hinglish-optimized
   - VoiceInk: $25 one-time (best paid alternative)
   - Spokenly: Free, but limited Hinglish support
4. None of the free options were properly optimized for Hinglish (Hindi+English mixed speech)
5. Decision: Build it ourselves — free, local, Hinglish-native

**The builder speaks in Hinglish** — not pure Hindi, not pure English — a natural mix of both. This is the core use case Bakwaas is built for.

---

## 👤 PROJECT OWNER

- **Builder:** [YOUR NAME]
- **GitHub:** [YOUR GITHUB USERNAME]
- **LinkedIn:** [YOUR LINKEDIN URL]
- **Repo Name:** bakwaas
- **GitHub Repo:** https://github.com/[YOUR USERNAME]/bakwaas
- **License:** MIT

---

## 🛠️ TECH STACK

| Component | Tool | Details |
|---|---|---|
| Speech Engine | whisper.cpp | Fast C/C++ local implementation, Metal-accelerated |
| Hinglish Model | Oriserve/Whisper-Hindi2Hinglish-Apex | 800M params, trained on 1000+ hrs Indian audio, 8x faster than Apex baseline |
| System Hotkeys | Hammerspoon | macOS automation via Lua |
| Audio Capture | sounddevice + ffmpeg | 16kHz mono WAV recording |
| Text Cleanup | Ollama + Gemma 4 E4B | Optional, fully local LLM, removes filler words |
| Package Manager | Homebrew | All dependencies |
| Build Tools | Xcode CLI + CMake | Compiling whisper.cpp |
| Language | Python 3.11+ | Core pipeline |
| Virtual Env | venv | Isolated Python environment |

---

## 💻 SYSTEM REQUIREMENTS

- macOS 13+ (Ventura or later)
- Apple Silicon Mac — M1 / M2 / M3 / M4 (strongly recommended)
- Minimum 16GB RAM (for running model + optional Ollama together)
- ~15 GB free disk space (for model files + dependencies)
- Internet — only for initial setup; after that fully offline

---

## 📁 COMPLETE FILE STRUCTURE

```text
bakwaas/ ← Root project directory
│
├── bakwaas-status.md ← THIS FILE — Master project status
├── README.md ← Public-facing documentation
├── LICENSE ← MIT License
├── requirements.txt ← Python dependencies
├── install.sh ← One-click installer script
├── .gitignore ← Ignores models/, venv/, etc.
│
├── bakwaas.py ← CORE ENGINE — main dictation script
├── download_model.py ← Downloads Hinglish Whisper model
├── test_model.py ← Tests if model is working
├── cleanup.py ← Optional Ollama text cleanup
│
├── hammerspoon/
│   └── init.lua ← Hammerspoon hotkey config
│
├── models/ ← Downloaded AI models (gitignored)
│   └── hinglish-apex/ ← Oriserve Apex model files
│
├── venv/ ← Python virtual environment (gitignored)
│
├── assets/
│   ├── logo.png ← Project logo
│   ├── demo.gif ← Demo screen recording GIF
│   └── architecture.png ← Architecture diagram image
│
└── docs/
    ├── SETUP.md ← Detailed setup guide
    ├── TROUBLESHOOTING.md ← Common issues and fixes
    └── CONTRIBUTING.md ← How to contribute
```

### ✅ Confirmed Structure — Scaffolding Done (2026-08-23)

```text
bakwaas/
├── .gitignore
├── LICENSE
├── README.md
├── requirements.txt
├── bakwaas-status.md
├── install.sh
├── bakwaas.py
├── download_model.py
├── test_model.py
├── cleanup.py
├── assets/
│   └── .gitkeep
├── docs/
│   ├── CONTRIBUTING.md
│   ├── SETUP.md
│   └── TROUBLESHOOTING.md
├── hammerspoon/
│   └── init.lua
└── models/
    └── .gitkeep
```

All folders and placeholder files are created.
Next step: Fill in the actual code, phase by phase.

---

## 🏗️ SYSTEM ARCHITECTURE

```text
🎤 MICROPHONE
↓
⌨️ HAMMERSPOON Hotkey trigger (Ctrl+Shift+B / D / T)
↓
🔊 SOUNDDEVICE Captures mic input → saves as 16kHz mono WAV file
↓
🧠 ORISERVE WHISPER HINDI2HINGLISH-APEX MODEL
Runs via Python transformers pipeline
Transcribes Hinglish audio → raw text (800M params, Apple MPS / CPU accelerated)
↓
🧹 OLLAMA + GEMMA 4 E4B [OPTIONAL]
Local LLM cleanup — removes filler words, fixes punctuation, keeps Hinglish style intact
↓
📋 APPLESCRIPT Copies final text to clipboard → Cmd+V pastes at cursor
↓
📝 ANY APP ON MAC
Notion / Slack / VS Code / Browser / Terminal / etc.
```

---

## ⌨️ HOTKEYS (Hammerspoon)

| Hotkey | Action |
|---|---|
| Ctrl + Shift + B | Toggle recording — press to start, press again to stop |
| Ctrl + Shift + D | Quick 5-second dictation |
| Ctrl + Shift + T | Long 10-second dictation |

---

## 🗺️ FULL ROADMAP — ALL PHASES

### PHASE 1 — Environment Setup
**Goal:** Install all tools and dependencies
**Estimated Time:** 30–45 minutes
**Status:** ⬜ NOT STARTED

Tasks:
- [ ] Install Xcode Command Line Tools (`xcode-select --install`)
- [ ] Install Homebrew
- [ ] Install dependencies: cmake, git, ffmpeg, python@3.11
- [ ] Install Hammerspoon (`brew install --cask hammerspoon`)
- [ ] Create project directory: `~/Projects/bakwaas`
- [ ] Create Python virtual environment (`python3 -m venv venv`)
- [ ] Install Python packages (`pip install -r requirements.txt`)
- [ ] Create `requirements.txt` file

---

### PHASE 2 — Build whisper.cpp
**Goal:** Compile whisper.cpp with Apple Silicon Metal acceleration
**Estimated Time:** 20–30 minutes
**Status:** ⬜ NOT STARTED

Tasks:
- [ ] Clone whisper.cpp repo from `https://github.com/ggml-org/whisper.cpp`
- [ ] Build with CMake (`cmake -B build && cmake --build build -j --config Release`)
- [ ] Verify build works (`./build/bin/whisper-cli --help`)
- [ ] Download test model (`bash models/download-ggml-model.sh base.en`)
- [ ] Test with sample audio file to confirm build is working

---

### PHASE 3 — Download Hinglish Model
**Goal:** Download and verify the Oriserve Hinglish Whisper model
**Estimated Time:** 20–30 minutes (plus download time)
**Status:** ⬜ NOT STARTED

Tasks:
- [ ] Create HuggingFace account (if not already done)
- [ ] Create `download_model.py` script
- [ ] Run download script — downloads `Oriserve/Whisper-Hindi2Hinglish-Apex`
- [ ] Verify model downloaded to `./models/hinglish-apex/`
- [ ] Create `test_model.py` script
- [ ] Run test script with a sample WAV file to verify model loads correctly

Model Details:
- Model ID: `Oriserve/Whisper-Hindi2Hinglish-Apex`
- Parameters: 800 Million
- Training Data: 1000+ hours of Indian audio
- Specialty: Hindi, Hinglish, Indian-accented English
- Speed: 8x faster than baseline while maintaining accuracy
- Architecture: Based on OpenAI Whisper (fine-tuned)

---

### PHASE 4 — Core Dictation Engine
**Goal:** Build the main `bakwaas.py` script
**Estimated Time:** 45–60 minutes
**Status:** ⬜ NOT STARTED

Tasks:
- [ ] Create `bakwaas.py` with full argument parser
- [ ] Implement lazy model loading (load once, keep in memory)
- [ ] Implement `record_audio()` function — fixed duration recording
- [ ] Implement `record_until_keypress()` function — manual stop
- [ ] Implement `transcribe()` function — runs Hinglish model
- [ ] Implement `cleanup_text()` function — Ollama integration
- [ ] Implement `paste_to_cursor()` function — AppleScript clipboard paste
- [ ] Test all modes:
  - [ ] `python3 bakwaas.py` — 5 second recording
  - [ ] `python3 bakwaas.py -d 10` — 10 second recording
  - [ ] `python3 bakwaas.py -c` — continuous until Enter
  - [ ] `python3 bakwaas.py -f file.wav` — transcribe existing file
  - [ ] `python3 bakwaas.py --no-cleanup` — skip Ollama
  - [ ] `python3 bakwaas.py --no-paste` — just print

---

### PHASE 5 — Hammerspoon Hotkey Integration
**Goal:** System-wide hotkeys that trigger dictation from any app
**Estimated Time:** 15–20 minutes
**Status:** ⬜ NOT STARTED

Tasks:
- [ ] Create `hammerspoon/init.lua` config file
- [ ] Set up Mode 1: Ctrl+Shift+B — toggle start/stop recording
- [ ] Set up Mode 2: Ctrl+Shift+D — quick 5-second dictation
- [ ] Set up Mode 3: Ctrl+Shift+T — long 10-second dictation
- [ ] Open Hammerspoon → reload config
- [ ] Grant Hammerspoon Accessibility permission (System Settings)
- [ ] Grant Hammerspoon Microphone permission (System Settings)
- [ ] Test hotkeys work from:
  - [ ] Notion
  - [ ] Browser (Chrome/Safari)
  - [ ] VS Code / Cursor
  - [ ] Terminal

---

### PHASE 6 — Ollama Text Cleanup (Optional)
**Goal:** Local LLM to clean up raw transcription output
**Estimated Time:** 20 minutes
**Status:** ⬜ NOT STARTED

Tasks:
- [ ] Install Ollama (`brew install ollama`)
- [ ] Start Ollama server (`ollama serve`)
- [ ] Pull Gemma 4 E4B model (`ollama pull gemma4:e4b`)
- [ ] Create `cleanup.py` script
- [ ] Test cleanup with sample Hinglish raw transcription
- [ ] Integrate cleanup into main `bakwaas.py` pipeline
- [ ] Verify cleanup preserves Hinglish style (doesn't translate to pure English or Hindi)

Note on RAM:
- 8GB RAM → use `gemma4:e2b` (~3GB model)
- 16GB RAM → use `gemma4:e4b` (~5GB model) — recommended

---

### PHASE 7 — GitHub Repository Setup
**Goal:** Set up clean public repo, push all code
**Estimated Time:** 30 minutes
**Status:** ⬜ NOT STARTED

Tasks:
- [ ] Create `README.md` with full documentation
- [ ] Create `LICENSE` (MIT)
- [ ] Create `install.sh` one-click installer
- [ ] Create `.gitignore` — must ignore: models/, venv/, *.wav, *.bin, *.safetensors
- [ ] Create `docs/SETUP.md`
- [ ] Create `docs/TROUBLESHOOTING.md`
- [ ] Create assets/ folder — logo, demo GIF, architecture image
- [ ] Git init, add all, commit with message:
      `🗣️💨📝 feat: Initial release — Bakwaas v1.0.0`
- [ ] Create repo on GitHub (name: `bakwaas`)
- [ ] Push to main branch
- [ ] Add repo description: "Free, local, Hinglish-optimized voice dictation for Mac 🗣️💨📝"
- [ ] Add topics/tags on GitHub: `macos`, `whisper`, `hinglish`, `voice-dictation`, `apple-silicon`, `open-source`, `python`

---

### PHASE 8 — LinkedIn Post (Optional but planned)
**Goal:** Share the build story on LinkedIn — human-sounding, short
**Estimated Time:** 15 minutes
**Status:** ⬜ NOT STARTED

LinkedIn Post Draft (human tone, short, not AI-sounding):
```text
I was tired of typing.

Not lazy — just felt like typing slows down thinking. So I started using voice-to-text tools.

Hit Wispr Flow's weekly limit. Checked alternatives — all either paid or didn't understand how I actually talk (Hinglish — hindi+english mixed).

So I built my own. Called it Bakwaas.

Free. Local. Works in any app. Understands Hinglish. Code on GitHub → [link]

#buildinpublic #opensource #macos #hinglish
```

Note: Post should feel like a person wrote it at 11pm after finishing the build — not a product launch. Short lines. No buzzwords. No "excited to share" or "thrilled to announce".

---

## 📊 OVERALL PROGRESS TRACKER

| Phase | Name | Status | % Done |
|---|---|---|---|
| Scaffolding | Project structure + all files created | ✅ Complete | 100% |
| Phase 1 | Environment Setup | ⬜ Not Started | 0% |
| Phase 2 | whisper.cpp Build | ⬜ Not Started | 0% |
| Phase 3 | Hinglish Model Download | ⬜ Not Started | 0% |
| Phase 4 | Core Dictation Engine | ⬜ Not Started | 0% |
| Phase 5 | Hammerspoon Hotkeys | ⬜ Not Started | 0% |
| Phase 6 | Ollama Text Cleanup | ⬜ Not Started | 0% |
| Phase 7 | GitHub Repository Push | ⬜ Not Started | 0% |
| Phase 8 | LinkedIn Post | ⬜ Not Started | 0% |
| **TOTAL** | | 🟡 **In Progress** | **~5%** |

Status Key:
- ⬜ Not Started
- 🟡 In Progress  
- ✅ Complete
- ❌ Blocked

---

## 🎯 CURRENT NEXT STEP

**→ START PHASE 1: Environment Setup**

Run these commands in order:

```bash
# Step 1: Xcode CLI tools
xcode-select --install

# Step 2: Homebrew (skip if already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Step 3: Dependencies
brew install cmake git ffmpeg python@3.11
brew install --cask hammerspoon

# Step 4: Python virtual environment
cd ~/Documents/Projects/BAKWAAS
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

When Phase 1 is done:
- Update Phase 1 status to ✅ Complete in the Progress Tracker
- Update % to reflect progress
- Move CURRENT NEXT STEP to Phase 2

---

## 📅 1-DAY EXECUTION PLAN — 2026-08-23

> Goal: Build, push to GitHub, and post on LinkedIn — all in one day.
> Estimated total time: 4–5 hours of focused work.

| Time Block | Phase | Tasks | Status |
|---|---|---|---|
| Morning | Phase 1 + 2 | Environment setup + whisper.cpp build | ⬜ |
| Morning | Phase 3 | Hinglish model download | ⬜ |
| Afternoon | Phase 4 | Core engine — bakwaas.py | ⬜ |
| Afternoon | Phase 5 | Hammerspoon hotkey setup | ⬜ |
| Evening | Phase 6 | Ollama text cleanup (optional) | ⬜ |
| Evening | Phase 7 | GitHub push — go live | ⬜ |
| Night | Phase 8 | LinkedIn post | ⬜ |

### Why 1 Day?
- Project scope is focused and well-defined
- All code is already planned out
- Scaffolding is already done — zero time wasted
- LinkedIn signal is stronger when built fast:
  "Problem aayi → same day fix kar diya"

### End of Day Goal:
- ✅ Bakwaas fully working locally on Mac
- ✅ Repo live on GitHub (public)
- ✅ LinkedIn post published
- ✅ First open-source Hinglish dictation tool for Mac

---

## 🚨 KNOWN RISKS & GOTCHAS

1. **Model conversion:** The Oriserve model is in HuggingFace transformers format. If using whisper.cpp directly, a GGML conversion step is needed. Alternative: use Python transformers pipeline directly — avoids conversion entirely.

2. **First run latency:** Model takes 30–60 seconds to load on first run. After that it stays cached in memory.

3. **RAM constraint:** Running the Whisper model + Ollama simultaneously uses a lot of unified memory on Apple Silicon. Recommended: 16GB RAM minimum. If 8GB, skip Ollama or use the smallest model (gemma4:e2b).

4. **macOS permissions:** Hammerspoon needs Accessibility + Microphone. Terminal also needs Microphone. These must be manually granted in System Settings → Privacy & Security.

5. **Audio format:** Model expects 16kHz mono WAV. sounddevice records in this format natively so no conversion needed.

6. **Git large files:** models/ folder contains files 1–2GB in size. NEVER push to GitHub. Always in .gitignore.

7. **MPS vs CPU:** On Mac, `torch.backends.mps.is_available()` should return True on Apple Silicon. Use MPS for faster inference. Fallback to CPU if MPS causes issues.

---

## 🔮 FUTURE IDEAS (Post v1.0)

- [ ] Menu bar app with native Swift UI (instead of Hammerspoon)
- [ ] Continuous ambient mode — always listening, activate with wake word
- [ ] Custom vocabulary training for personal Hinglish patterns
- [ ] iOS companion app
- [ ] Streaming transcription (real-time word-by-word)
- [ ] Integration with Raycast as an extension
- [ ] Support for other Indian language mixes (Tanglish, Manglish, etc.)

---

## 📝 NOTES FOR AI ASSISTANTS READING THIS FILE

If you are an AI reading this file to help with development:

1. The project is called Bakwaas — not Whispr, not anything else
2. The core pipeline is: Mic → sounddevice → Oriserve Whisper Model → optional Ollama cleanup → AppleScript paste
3. We are NOT building a UI — this is a hotkey-triggered background tool. Hammerspoon handles the UX.
4. The Hinglish model is the most important component — do not replace it with a generic English Whisper model. It MUST be Oriserve/Whisper-Hindi2Hinglish-Apex.
5. Everything must run locally — no cloud APIs, no external calls except initial model download from HuggingFace.
6. Primary language of the builder: Hinglish. Primary platform: macOS Apple Silicon.
7. Check the Progress Tracker above to know what is done and what needs to be done next before suggesting or making changes.
8. When a phase is completed, update the status in the Progress Tracker and add the completion date next to it.

---

*This file should be updated every time work is done on Bakwaas. Update the status emoji, % done, and check off completed tasks.*

*"Bakwaas karo, kaam ho jaaye" 🗣️💨📝*

---
📋 CHANGE LOG

### 2026-08-23 — PLAN UPDATE
- 🔄 Changed timeline from 2-day to 1-day execution plan
- 🎯 Goal: Build + GitHub + LinkedIn all in one day
- ✅ Scaffolding confirmed complete — directory tree verified
- 🟡 Phase 1 starting next — Environment Setup

2026-08-23
✅ bakwaas-status.md created — master project status file
✅ Full project scaffolding complete — all folders and placeholder files created
✅ README.md written
✅ LICENSE added (MIT)
✅ .gitignore configured
✅ requirements.txt created
✅ docs/ folder created with SETUP, TROUBLESHOOTING, CONTRIBUTING
🟡 Ready to begin Phase 1 — Environment Setup
