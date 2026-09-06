# 🚨 Bakwaas — Troubleshooting Guide

A practical guide to fixing common issues you might hit during setup or daily use.

## Hammerspoon config not loading / wrong path
**Issue:** `~/.hammerspoon/init.lua` is not syncing with the project `hammerspoon/init.lua`.
✅ **Fix:** The `install.sh` script automatically symlinks it, but you can do it manually:
```bash
ln -sf ~/Documents/Projects/BAKWAAS/hammerspoon/init.lua ~/.hammerspoon/init.lua
```
Then click the Hammerspoon menu bar icon and select "Reload Config".

## Missing Permissions (Hotkeys / Mic not working)
**Issue:** Fn key doesn't work, nothing gets pasted, or audio isn't recorded.
✅ **Fix:** macOS requires strict permissions. Go to System Settings → Privacy & Security:
- **Accessibility:** Enable **Hammerspoon** (required for `hs.eventtap` and auto-pasting).
- **Microphone:** Enable **Hammerspoon** AND your **Terminal** app.

## Error 1002: osascript is not allowed to send keystrokes
**Issue:** You might see this error if you try to use AppleScript for keystrokes.
✅ **Fix:** We sidestep this completely. Bakwaas copies the text to your clipboard (`pbcopy`) and uses Hammerspoon's native `hs.eventtap.keyStroke({"cmd"}, "v")` to paste. Ensure Accessibility permissions are granted to Hammerspoon!

## First words cut off / No mic indicator immediately
**Issue:** The heavy `torch` and `transformers` imports delay the start of the recording if placed at the top of the script.
✅ **Fix:** We lazy-load the pipeline *after* recording is complete, so the mic opens instantly. However, the first transcription of the day is slow as the model loads into memory.
✅ **Pro-Tip:** Run `python3 warmup.py` to preload the model into RAM before your first dictation.

## Hammerspoon `hs.canvas` crash
**Issue:** `ignoreMouseEvents` is nil or causes a crash.
✅ **Fix:** Don't use `ignoreMouseEvents()`. Instead, use `c:clickActivating(false)` which is the modern correct way to make the canvas click-through. (This is already implemented in `init.lua`).

## Continuous mode doesn't stop
**Issue:** You double-tap Fn but the process hangs.
✅ **Fix:** Continuous mode relies on a `.stop_bakwaas` file being created to signal the Python process to stop. Ensure Hammerspoon has file write permissions. You can manually stop it by running:
```bash
touch .stop_bakwaas
```

## How to test the backend alone
**Issue:** Trying to isolate whether Hammerspoon or Python is the problem.
✅ **Fix:** Run the python script directly in terminal:
- Fixed 5-second dictation: `python3 bakwaas.py -d 5`
- Continuous dictation (press Enter to stop): `python3 bakwaas.py -c`
