#!/bin/bash
# Dosh Language Uninstaller for macOS
# This script removes .dosh file association
# Made by Maks Hoffman

echo "========================================"
echo "Dosh Language Uninstaller (macOS)"
echo "Made by Maks Hoffman"
echo "========================================"
echo ""

echo "Removing Dosh application bundle..."

# Remove the app bundle
APP_DIR="$HOME/Applications/Dosh.app"
if [ -d "$APP_DIR" ]; then
    rm -rf "$APP_DIR"
    echo "Removed Dosh.app"
fi

# Rebuild LaunchServices database
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo ""
echo "========================================"
echo "Uninstallation successful!"
echo "========================================"
echo ""
echo ".dosh file association has been removed."

# Remove installed version file
INSTALLED_VERSION_FILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/installed_version.txt"
if [ -f "$INSTALLED_VERSION_FILE" ]; then
    rm "$INSTALLED_VERSION_FILE"
fi

echo "You can safely delete this folder now."
echo ""

read -p "Press Enter to exit..."
