#!/bin/bash
# Dosh Extension Uninstaller for macOS
# Uninstall Dosh extensions
# Made by Maks Hoffman

echo "========================================"
echo "Dosh Extension Uninstaller (macOS)"
echo "Made by Maks Hoffman"
echo "========================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTENSIONS_DIR="$SCRIPT_DIR/extensions"

if [ ! -d "$EXTENSIONS_DIR" ]; then
    echo "No extensions directory found."
    echo "No extensions are currently installed."
    read -p "Press Enter to exit..."
    exit 0
fi

# Count extensions
count=0
for dir in "$EXTENSIONS_DIR"/*/ ; do
    if [ -d "$dir" ]; then
        ((count++))
    fi
done

if [ $count -eq 0 ]; then
    echo "No extensions are currently installed."
    read -p "Press Enter to exit..."
    exit 0
fi

echo "Installed Extensions:"
echo "--------------------"

# Build array of extension names
index=0
declare -a extensions
for dir in "$EXTENSIONS_DIR"/*/ ; do
    if [ -d "$dir" ]; then
        ((index++))
        ext_name=$(basename "$dir")
        extensions[$index]="$ext_name"
        echo "[$index] $ext_name"
    fi
done

echo ""
echo "[0] Cancel"
echo ""

read -p "Select extension to uninstall (enter number): " choice

if [ "$choice" = "0" ]; then
    echo "Cancelled."
    read -p "Press Enter to exit..."
    exit 0
fi

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $index ]; then
    echo "Invalid selection."
    read -p "Press Enter to exit..."
    exit 1
fi

selected_ext="${extensions[$choice]}"

echo ""
read -p "Are you sure you want to uninstall extension: $selected_ext? (type YES to confirm): " confirm

if [ "$confirm" != "YES" ]; then
    echo "Cancelled."
    read -p "Press Enter to exit..."
    exit 0
fi

# Delete the extension folder
ext_path="$EXTENSIONS_DIR/$selected_ext"
if [ -d "$ext_path" ]; then
    rm -rf "$ext_path"
    echo ""
    echo "Extension '$selected_ext' has been uninstalled successfully!"
else
    echo "Error: Extension folder not found."
fi

echo ""
read -p "Press Enter to exit..."
