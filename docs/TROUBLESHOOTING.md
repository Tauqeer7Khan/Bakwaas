# 🚨 Bakwaas — Troubleshooting Guide

## Common Issues

### Model not loading
- Check that `models/hinglish-apex/` folder exists
- Re-run: `python3 download_model.py`

### Hammerspoon hotkeys not working
- System Settings → Privacy → Accessibility → Enable Hammerspoon
- System Settings → Privacy → Microphone → Enable Hammerspoon
- Reload Hammerspoon config

### Audio not recording
- System Settings → Privacy → Microphone → Enable Terminal
- Try: `python3 bakwaas.py --no-cleanup`

### MPS / GPU errors on Mac
- Replace `device = "mps"` with `device = "cpu"` in `bakwaas.py` temporarily

### Ollama not responding
- Run: `ollama serve`
- Check: `curl http://localhost:11434/api/tags`
