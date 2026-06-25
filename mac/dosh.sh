#!/bin/bash
# Dosh Language Launcher for macOS
# This script runs .dosh files using Python
# Made by Maks Hoffman

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
python3 "$SCRIPT_DIR/dosh_interpreter.py" "$@"

# Keep terminal open
echo ""
read -p "Press Enter to close..."
