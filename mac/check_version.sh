#!/bin/bash
# Dosh Version Checker for macOS
# Displays current and installed versions
# Made by Maks Hoffman

echo "========================================"
echo "Dosh Version Information (macOS)"
echo "Made by Maks Hoffman"
echo "========================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION_FILE="$SCRIPT_DIR/version.json"
INSTALLED_VERSION_FILE="$SCRIPT_DIR/installed_version.txt"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    read -p "Press Enter to exit..."
    exit 1
fi

# Read current version
CURRENT_VERSION=$(python3 -c "import json; f=open('$VERSION_FILE', 'r'); data=json.load(f); print(data['version']); f.close()" 2>/dev/null)

if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Could not read version information"
    read -p "Press Enter to exit..."
    exit 1
fi

echo "Package Version: $CURRENT_VERSION"

# Read release date
RELEASE_DATE=$(python3 -c "import json; f=open('$VERSION_FILE', 'r'); data=json.load(f); print(data['release_date']); f.close()" 2>/dev/null)
echo "Release Date: $RELEASE_DATE"
echo ""

# Check if Dosh is installed
if [ -f "$INSTALLED_VERSION_FILE" ]; then
    INSTALLED_VERSION=$(cat "$INSTALLED_VERSION_FILE")
    echo "Installed Version: $INSTALLED_VERSION"
    echo ""
    
    if [ "$CURRENT_VERSION" = "$INSTALLED_VERSION" ]; then
        echo "Status: Up to date"
    else
        echo "Status: Update available - run ./update.sh"
    fi
else
    echo "Installed Version: Not installed"
    echo ""
    echo "Status: Not installed - run ./install.sh"
fi

echo ""
echo "Changes in version $CURRENT_VERSION:"
echo "--------------------"
python3 -c "import json; f=open('$VERSION_FILE', 'r'); data=json.load(f); [print('  - ' + change) for change in data.get('changes', [])] ; f.close()" 2>/dev/null

echo ""
read -p "Press Enter to exit..."
