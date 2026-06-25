#!/bin/bash
# Dosh Extension Installer for macOS
# Install a Dosh extension globally
# Made by Maks Hoffman

echo "========================================"
echo "Dosh Extension Installer (macOS)"
echo "Made by Maks Hoffman"
echo "========================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ]; then
    # Use AppleScript to show folder picker
    EXT_PATH=$(osascript -e 'tell application "Finder"
        set folderPath to choose folder with prompt "Select Extension Folder"
        return POSIX path of folderPath
    end tell' 2>/dev/null)
    
    if [ -z "$EXT_PATH" ]; then
        echo "No folder selected. Exiting."
        read -p "Press Enter to exit..."
        exit 1
    fi
    # Remove trailing slash
    EXT_PATH="${EXT_PATH%/}"
else
    EXT_PATH="$1"
fi

if [ ! -d "$EXT_PATH" ]; then
    echo "Error: Path '$EXT_PATH' does not exist or is not a directory"
    read -p "Press Enter to exit..."
    exit 1
fi

echo "Installing extension from: $EXT_PATH"
echo ""

python3 "$SCRIPT_DIR/dosh_interpreter.py" --install-extension "$EXT_PATH"

echo ""
read -p "Press Enter to exit..."
