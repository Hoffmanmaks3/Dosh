#!/bin/bash
# Dosh Extension Viewer for macOS
# View all installed Dosh extensions
# Made by Maks Hoffman

echo "========================================"
echo "Dosh Extension Viewer (macOS)"
echo "Made by Maks Hoffman"
echo "========================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTENSIONS_DIR="$SCRIPT_DIR/extensions"

if [ ! -d "$EXTENSIONS_DIR" ]; then
    echo "No extensions directory found."
    echo "No extensions are currently installed."
    echo ""
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
    echo ""
    echo "To install an extension, run: ./install_extension.sh"
    echo ""
    read -p "Press Enter to exit..."
    exit 0
fi

echo "Installed Extensions:"
echo "--------------------"
echo ""

for dir in "$EXTENSIONS_DIR"/*/ ; do
    if [ -d "$dir" ]; then
        ext_name=$(basename "$dir")
        echo "Extension: $ext_name"
        
        if [ -f "$dir/help.txt" ]; then
            echo "  - Has help file"
        else
            echo "  - No help file"
        fi
        
        if [ -f "$dir/main.dosh" ]; then
            echo "  - Has main.dosh"
        else
            echo "  - Missing main.dosh (INVALID)"
        fi
        
        echo "  - Path: $dir"
        echo ""
    fi
done

echo "--------------------"
echo "Total: $count extension(s) installed"
echo ""
echo "To use an extension in your .dosh file:"
echo "  import extensionname"
echo "  extensionname.functionname"
echo "  extensionname.help"
echo ""

read -p "Press Enter to exit..."
