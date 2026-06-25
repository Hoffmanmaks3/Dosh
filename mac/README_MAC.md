# Dosh Language for macOS

A custom programming language interpreter for macOS that executes `.dosh` files.

**Made by Maks Hoffman**

## Installation

### Requirements
- Python 3.6 or higher
- macOS 10.10 or later

### Setup

1. **Open Terminal** and navigate to this folder:
   ```bash
   cd /path/to/dost/mac
   ```
### install backup:
cd mac
chmod +x install.sh
./install.sh
2. **Make the installer executable and run it:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

This will:
- Register `.dosh` files with macOS
- Make all scripts executable
- Create a Dosh.app bundle in your Applications folder

## Usage

### Running .dosh Files

After installation:
- **Double-click** any `.dosh` file (may need to right-click > Open With > Dosh on first use)
- **From Terminal**: `./dosh.sh yourfile.dosh`
- **Or**: `python3 dosh_interpreter.py yourfile.dosh`

### Managing Extensions

**Install an extension:**
```bash
./install_extension.sh
```
Or drag a folder onto it, or:
```bash
./install_extension.sh /path/to/extension_folder
```

**View installed extensions:**
```bash
./view_extensions.sh
```

**Uninstall an extension:**
```bash
./uninstall_extension.sh
```

## Language Syntax

Same syntax as the Windows version! See the main README.md in the parent folder for complete syntax documentation.

### Example Program

```dosh
print(Hello from macOS!)
var input What's your name? - name
print(Hello,)
print($name)

textcolor green
print(This text is green!)
```

## Platform-Specific Notes

### What Works on macOS:
✅ All basic language features (print, variables, functions, etc.)
✅ Text colors (using ANSI escape codes)
✅ File operations
✅ Extensions system
✅ Python and HTML embedding
✅ Pause, repeat, conditionals

### Limitations:
❌ **Key detection** (`if key` and `if lastkey`) - Not supported in terminal environment
   - These features are Windows-only due to platform limitations
   - The code will run but key checks will always return false

## Troubleshooting

**"Permission denied" errors:**
- Run: `chmod +x *.sh` to make all scripts executable

**Python not found:**
- Install Python 3 from https://www.python.org/
- Or use Homebrew: `brew install python3`

**.dosh files don't open:**
- Right-click file > Open With > Dosh (first time only)
- Or run from terminal: `./dosh.sh filename.dosh`

**Extensions not working:**
- Make sure extension has main.dosh and help.txt files
- Extensions are stored in the `extensions` folder

## Uninstallation

To remove Dosh:
```bash
./uninstall.sh
```

This removes the file association and Dosh.app bundle.

## File Structure

```
mac/
├── dosh_interpreter.py      # Main interpreter (cross-platform)
├── dosh.sh                  # Launcher script
├── install.sh               # Installer
├── uninstall.sh            # Uninstaller
├── install_extension.sh    # Extension installer
├── uninstall_extension.sh  # Extension uninstaller
├── view_extensions.sh      # View installed extensions
└── extensions/             # Installed extensions folder
```

## Creating Extensions

Extensions work the same on macOS as on Windows! See the example_extension in the parent folder.

## License

Free to use and modify!

**Made by Maks Hoffman**
