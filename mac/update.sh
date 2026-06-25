#!/bin/bash
# Dosh Update Manager for macOS
# Check for updates and install new versions
# Made by Maks Hoffman

echo "========================================"
echo "Dosh Update Manager (macOS)"
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

# Read current version from version.json
CURRENT_VERSION=$(python3 -c "import json; f=open('$VERSION_FILE', 'r'); data=json.load(f); print(data['version']); f.close()" 2>/dev/null)

if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Could not read version information"
    read -p "Press Enter to exit..."
    exit 1
fi

echo "Current Dosh version in this folder: $CURRENT_VERSION"
echo ""

# Check if Dosh is installed
if [ ! -f "$INSTALLED_VERSION_FILE" ]; then
    echo "Dosh is not installed on this machine."
    echo ""
    echo "To install, run: ./install.sh"
    echo ""
    read -p "Press Enter to exit..."
    exit 0
fi

# Read installed version
INSTALLED_VERSION=$(cat "$INSTALLED_VERSION_FILE")
echo "Installed Dosh version: $INSTALLED_VERSION"
echo ""

# Compare versions
if [ "$CURRENT_VERSION" = "$INSTALLED_VERSION" ]; then
    echo "========================================"
    echo "You have the latest version!"
    echo "========================================"
    echo ""
    echo "No update needed."
    echo ""
    read -p "Press Enter to exit..."
    exit 0
fi

echo "========================================"
echo "Update Available!"
echo "========================================"
echo ""
echo "New version: $CURRENT_VERSION"
echo "Your version: $INSTALLED_VERSION"
echo ""

# Show changelog
echo "Changes in version $CURRENT_VERSION:"
echo "--------------------"
python3 -c "import json; f=open('$VERSION_FILE', 'r'); data=json.load(f); [print('  - ' + change) for change in data.get('changes', [])] ; f.close()" 2>/dev/null
echo ""

read -p "Would you like to update? (Y/N): " UPDATE
if [ "$UPDATE" != "Y" ] && [ "$UPDATE" != "y" ]; then
    echo "Update cancelled."
    read -p "Press Enter to exit..."
    exit 0
fi

echo ""
echo "Updating Dosh..."
echo ""

# Check if app bundle exists
APP_DIR="$HOME/Applications/Dosh.app"
if [ -d "$APP_DIR" ]; then
    echo "Updating app bundle..."
    
    # Recreate launcher script with updated path
    cat > "$APP_DIR/Contents/MacOS/dosh_launcher" << EOF
#!/bin/bash
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd "$SCRIPT_DIR"
./dosh.sh "\$@"
EOF
    
    chmod +x "$APP_DIR/Contents/MacOS/dosh_launcher"
    
    # Re-register with LaunchServices
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_DIR"
    
    echo "App bundle updated successfully."
else
    echo "Note: App bundle not found. You may need to run ./install.sh first."
fi

echo ""
echo "Copying updated files..."

# Create backup directory
BACKUP_DIR="$SCRIPT_DIR/backup_$INSTALLED_VERSION"
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir "$BACKUP_DIR"
fi

# Backup current interpreter
if [ -f "$SCRIPT_DIR/dosh_interpreter.py" ]; then
    cp "$SCRIPT_DIR/dosh_interpreter.py" "$BACKUP_DIR/dosh_interpreter.py"
    echo "Backed up interpreter to: $BACKUP_DIR"
fi

# Update version file
echo "$CURRENT_VERSION" > "$INSTALLED_VERSION_FILE"

echo ""
echo "========================================"
echo "Update Complete!"
echo "========================================"
echo ""
echo "Dosh has been updated to version $CURRENT_VERSION"
echo ""
echo "Backup of previous version saved to: $BACKUP_DIR"
echo ""
read -p "Press Enter to exit..."
