# 🛠️ Bakwaas — Detailed Setup Guide

Follow bakwaas-status.md Phase by Phase. Full setup takes approximately 3.5 to 4.5 hours.

## Prerequisites

- macOS 13+ (Ventura or later)
- Apple Silicon Mac (M1/M2/M3/M4)
- 16GB RAM recommended
- 15GB free disk space
- Internet connection (for initial setup only)

## Step by Step Setup

1. **Install Dependencies:**
   Run the installation script in the root of the repository to automatically install required dependencies and setup symlinks:
   ```bash
   ./install.sh
   ```

2. **macOS Permissions:**
   Open **System Settings > Privacy & Security** and ensure the following are enabled:
   - **Accessibility:** Allow **Hammerspoon** (required to register hotkeys and paste text).
   - **Microphone:** Allow your terminal and **Hammerspoon** to access the microphone.

3. **Hammerspoon Setup:**
   - Launch Hammerspoon from your Applications folder.
   - The installer has already symlinked the configuration to `~/.hammerspoon/init.lua`.
   - Click the Hammerspoon icon in your macOS menu bar and select "Reload Config".

## User Experience

Bakwaas provides a seamless voice-to-text experience directly integrated with your OS using two intuitive modes:

- **Hold-to-Talk (Fn Key):** 
  Press and hold the `Fn` key. Speak your sentence. Release the `Fn` key to immediately stop recording. Your speech will be transcribed and pasted directly into your currently active text field.
  
- **Continuous Mode (Double-Tap Fn Key):** 
  Quickly double-tap the `Fn` key to start continuous recording. This mode is useful for long dictations. Double-tap the `Fn` key again to stop recording, transcribe, and paste the output.

Refer to bakwaas-status.md for the complete phase-by-phase breakdown with all technical details.
