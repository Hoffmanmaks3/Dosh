#!/bin/bash
# Dosh Language Installer for macOS
# This script registers .dosh files to open with the dosh interpreter
# Made by Maks Hoffman

echo "========================================"
echo "Dosh Language Installer (macOS)"
echo "Made by Maks Hoffman"
echo "========================================"
echo ""

# Get the directory where this script is located
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Installing Dosh to: $INSTALL_DIR"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Please install Python from https://www.python.org/"
    read -p "Press Enter to exit..."
    exit 1
fi

echo "Python 3 found!"
echo ""

# Make scripts executable
chmod +x "$INSTALL_DIR/dosh.sh"
chmod +x "$INSTALL_DIR/install_extension.sh"
chmod +x "$INSTALL_DIR/uninstall_extension.sh"
chmod +x "$INSTALL_DIR/view_extensions.sh"
chmod +x "$INSTALL_DIR/uninstall.sh"
chmod +x "$INSTALL_DIR/update.sh"
chmod +x "$INSTALL_DIR/check_version.sh"

echo "Made scripts executable"
echo ""

# Create LaunchServices registration
# Create a simple app bundle structure
APP_DIR="$HOME/Applications/Dosh.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Dosh</string>
    <key>CFBundleDisplayName</key>
    <string>Dosh Language</string>
    <key>CFBundleIdentifier</key>
    <string>com.makshoffman.dosh</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>dosh_launcher</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>dosh</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Dosh Script File</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Owner</string>
        </dict>
    </array>
</dict>
</plist>
EOF

# Create launcher script
cat > "$APP_DIR/Contents/MacOS/dosh_launcher" << EOF
#!/bin/bash
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd "$INSTALL_DIR"
./dosh.sh "\$@"
EOF

chmod +x "$APP_DIR/Contents/MacOS/dosh_launcher"

echo "Created Dosh.app bundle"
echo ""

# Register with LaunchServices
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_DIR"

echo "========================================"
echo "Installation successful!"
echo "========================================"
echo ""
echo "You can now:"
echo "  1. Double-click .dosh files to run them (may need to select 'Open With > Dosh' first time)"
echo "  2. Run from terminal: ./dosh.sh yourfile.dosh"
echo ""

# Save installed version
VERSION_FILE="$INSTALL_DIR/version.json"
INSTALLED_VERSION_FILE="$INSTALL_DIR/installed_version.txt"

VERSION=$(python3 -c "import json; f=open('$VERSION_FILE', 'r'); data=json.load(f); print(data['version']); f.close()" 2>/dev/null)

if [ ! -z "$VERSION" ]; then
    echo "$VERSION" > "$INSTALLED_VERSION_FILE"
    echo "Installed version: $VERSION"
    echo ""
fi

echo "To uninstall, run: ./uninstall.sh"
echo "To check for updates, run: ./update.sh"
echo ""
read -p "Press Enter to exit..."
