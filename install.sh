#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}    Bakwaas Installer 🗣️💨📝   ${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is not installed. Please install it first from https://brew.sh/${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Homebrew is installed${NC}"

# Check Python 3.11+
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 is not installed. Please install Python 3.11+${NC}"
    exit 1
fi
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
if awk "BEGIN {exit !($PYTHON_VERSION < 3.11)}"; then
    echo -e "${RED}Python version $PYTHON_VERSION is installed. Bakwaas requires Python 3.11+${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python 3.11+ is installed ($PYTHON_VERSION)${NC}"

# Check ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${YELLOW}ffmpeg is not installed. Installing via Homebrew...${NC}"
    brew install ffmpeg
else
    echo -e "${GREEN}✓ ffmpeg is installed${NC}"
fi

# Check Hammerspoon
if [ ! -d "/Applications/Hammerspoon.app" ]; then
    echo -e "${YELLOW}Hammerspoon is not installed. Installing via Homebrew Cask...${NC}"
    brew install --cask hammerspoon
else
    echo -e "${GREEN}✓ Hammerspoon is installed${NC}"
fi

# Set up Python venv
if [ ! -d "venv" ]; then
    echo -e "${BLUE}Creating Python virtual environment...${NC}"
    python3 -m venv venv
fi
echo -e "${BLUE}Activating venv and installing dependencies...${NC}"
source venv/bin/activate
pip install --upgrade pip
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo -e "${YELLOW}Warning: requirements.txt not found.${NC}"
fi

# Symlink Hammerspoon config
echo -e "${BLUE}Setting up Hammerspoon configuration...${NC}"
mkdir -p ~/.hammerspoon
if [ -e "${HOME}/.hammerspoon/init.lua" ] || [ -L "${HOME}/.hammerspoon/init.lua" ]; then
    echo -e "${YELLOW}Existing ~/.hammerspoon/init.lua found. Backing it up to ~/.hammerspoon/init.lua.bak${NC}"
    mv ~/.hammerspoon/init.lua ~/.hammerspoon/init.lua.bak
fi
ln -sf "$(pwd)/hammerspoon/init.lua" ~/.hammerspoon/init.lua
echo -e "${GREEN}✓ Hammerspoon configuration symlinked${NC}"

echo ""
echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}       Installation Complete     ${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: macOS Permissions Required ⚠️${NC}"
echo -e "To make Bakwaas work properly, please ensure you grant the following permissions in System Settings > Privacy & Security:"
echo -e "1. ${GREEN}Accessibility${NC}: Allow 'Hammerspoon' to control your computer (required for keystrokes)."
echo -e "2. ${GREEN}Microphone${NC}: Allow your terminal (e.g., Terminal, iTerm) or Hammerspoon to access the microphone."
echo ""
echo -e "Start Hammerspoon and reload its config if it was already running."
echo -e "Enjoy Bakwaas! 🗣️💨📝"
