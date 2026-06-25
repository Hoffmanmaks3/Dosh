# Dosh Language Interpreter

A custom programming language interpreter for Windows that executes `.dosh` files.

## Features

- **Print statements**: Output text and variables
- **Variables**: Store and manipulate data
- **User input**: Get input from users
- **Functions**: Define reusable code blocks
- **Conditionals**: If statements with various conditions
- **Lists**: Work with arrays of data
- **Key detection**: Check if keys are pressed (Windows only)

## Installation

### Requirements
- Python 3.6 or higher
- Windows OS

### Setup

1. **Install Python** (if not already installed):
   - Download from https://www.python.org/
   - Make sure to check "Add Python to PATH" during installation

2. **Install Dosh**:
   - Right-click `install.bat`
   - Select "Run as administrator"
   - Follow the prompts

This will register `.dosh` files with Windows so you can double-click them to run.

## Usage

### Running .dosh Files

After installation, simply double-click any `.dosh` file to run it!

Alternatively, you can run from command line:
```
dosh.bat example.dosh
```

Or directly with Python:
```
python dosh_interpreter.py example.dosh
```

### Language Syntax

#### Comments
```
#This is a comment#
```

#### Print
```
print(Hello, World!)
print($variable)
```

#### Variables
```
var Hello - greeting
var 42 - number
var $existing_var - new_var
```

#### User Input
```
var input Enter your name: - username
```

#### Lists
```
list ["item1", "item2", $variable] - mylist
```

#### Functions
```
var function myFunction:
print(Inside function!)
print(More code...)
/function

myFunction
```

#### Conditionals

**Value comparison:**
```
if "value1" = "value2":
print(They match!)
/if
```

**Check if value in list:**
```
if "apple" $fruits:
print(Found apple!)
/if
```

**Key press detection:**
```
if key "a":
print(A is pressed!)
/if
```

Supported special keys: `cmd`, `ctrl`, `alt`, `tab`, `enter`, `backspace`, `shift`

**Last key pressed:**
```
if lastkey "enter":
print(Enter was last pressed!)
/if
```

## Example Program

See `example.dosh` for a complete example demonstrating all features.

## Uninstallation

To remove the file association:
1. Right-click `uninstall.bat`
2. Select "Run as administrator"

## Troubleshooting

**"Python is not installed or not in PATH"**
- Install Python and make sure it's added to your system PATH
- Restart your computer after installing Python

**File association doesn't work**
- Make sure you ran `install.bat` as administrator
- Try logging out and back in to Windows

**Permission errors**
- The installer needs administrator privileges to modify the Windows Registry
- Right-click the batch file and select "Run as administrator"

## File Structure

```
dost/
├── dosh_interpreter.py  # Main interpreter
├── dosh.bat            # Launcher script
├── install.bat         # Installer (run as admin)
├── uninstall.bat       # Uninstaller (run as admin)
├── example.dosh        # Example program
├── syntax.txt          # Language syntax reference
└── README.md           # This file
```

## License

Free to use and modify!
