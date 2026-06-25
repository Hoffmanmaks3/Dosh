#!/usr/bin/env python3
"""
Dosh Language Interpreter
Interprets and executes .dosh files
"""

import sys
import re
import msvcrt
import os
import ctypes
import time
import json
import shutil
from typing import Dict, List, Any, Optional

class DoshInterpreter:
    def __init__(self):
        self.variables: Dict[str, Any] = {}
        self.functions: Dict[str, List[str]] = {}
        self.last_key_pressed: str = ""
        self.kernel32 = ctypes.windll.kernel32
        self.std_output_handle = self.kernel32.GetStdHandle(-11)
        self.show_errors: bool = False
        self.errors: List[str] = []
        self.html_imported: bool = False
        self.python_imported: bool = False
        self.extensions: Dict[str, Dict[str, Any]] = {}
        self.extensions_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'extensions')
        self.current_file_dir = os.getcwd()
        
        # Create extensions directory if it doesn't exist
        if not os.path.exists(self.extensions_dir):
            os.makedirs(self.extensions_dir)
    
    def load_extension(self, ext_name: str, ext_path: str) -> bool:
        """Load an extension from a directory"""
        try:
            main_dosh = os.path.join(ext_path, 'main.dosh')
            help_txt = os.path.join(ext_path, 'help.txt')
            
            if not os.path.exists(main_dosh):
                error_msg = f"Extension '{ext_name}' missing main.dosh"
                self.errors.append(error_msg)
                if not self.show_errors:
                    print(f"\nError: {error_msg}")
                return False
            
            # Read the main.dosh file to extract functions
            with open(main_dosh, 'r', encoding='utf-8') as f:
                ext_code = f.read()
            
            # Read help.txt if it exists
            help_text = ""
            if os.path.exists(help_txt):
                with open(help_txt, 'r', encoding='utf-8') as f:
                    help_text = f.read()
            
            # Store extension info
            self.extensions[ext_name] = {
                'path': ext_path,
                'code': ext_code,
                'help': help_text,
                'functions': {}
            }
            
            # Parse extension code to find functions
            self.parse_extension_functions(ext_name, ext_code)
            
            return True
        except Exception as e:
            error_msg = f"Failed to load extension '{ext_name}': {str(e)}"
            self.errors.append(error_msg)
            if not self.show_errors:
                print(f"\nError: {error_msg}")
            return False
    
    def parse_extension_functions(self, ext_name: str, code: str):
        """Parse extension code to extract function definitions"""
        code = self.remove_comments(code)
        lines = code.split('\n')
        
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            if line.startswith('var function '):
                func_match = re.match(r'var function\s+(\w+):', line)
                if func_match:
                    func_name = func_match.group(1)
                    func_body = []
                    i += 1
                    while i < len(lines):
                        func_line = lines[i].strip()
                        if func_line == '/function':
                            self.extensions[ext_name]['functions'][func_name] = func_body
                            break
                        func_body.append(lines[i])
                        i += 1
            i += 1
    
    def call_extension_function(self, ext_name: str, func_name: str):
        """Call a function from an extension"""
        if ext_name not in self.extensions:
            error_msg = f"Extension '{ext_name}' not imported"
            self.errors.append(error_msg)
            if not self.show_errors:
                print(f"\nError: {error_msg}")
            return
        
        if func_name not in self.extensions[ext_name]['functions']:
            error_msg = f"Function '{func_name}' not found in extension '{ext_name}'"
            self.errors.append(error_msg)
            if not self.show_errors:
                print(f"\nError: {error_msg}")
            return
        
        # Execute the function body
        func_body = self.extensions[ext_name]['functions'][func_name]
        for line in func_body:
            self.execute_line_simple(line)
    
    def show_extension_help(self, ext_name: str):
        """Show help text for an extension"""
        if ext_name not in self.extensions:
            error_msg = f"Extension '{ext_name}' not imported"
            self.errors.append(error_msg)
            if not self.show_errors:
                print(f"\nError: {error_msg}")
            return
        
        help_text = self.extensions[ext_name]['help']
        if help_text:
            print(help_text)
        else:
            print(f"No help available for extension '{ext_name}'")
    
    def find_extension_path(self, ext_name: str) -> Optional[str]:
        """Find extension in current directory or installed extensions"""
        # Check in current file directory
        local_path = os.path.join(self.current_file_dir, ext_name)
        if os.path.exists(local_path) and os.path.isdir(local_path):
            return local_path
        
        # Check in installed extensions directory
        installed_path = os.path.join(self.extensions_dir, ext_name)
        if os.path.exists(installed_path) and os.path.isdir(installed_path):
            return installed_path
        
        return None
        
    def set_text_color(self, color: str):
        """Set console text color"""
        color = color.strip().lower()
        
        # Color name to Windows console color code mapping
        color_map = {
            'black': 0,
            'blue': 1,
            'green': 2,
            'cyan': 3,
            'red': 4,
            'magenta': 5,
            'yellow': 6,
            'white': 7,
            'gray': 8,
            'grey': 8,
            'lightblue': 9,
            'lightgreen': 10,
            'lightcyan': 11,
            'lightred': 12,
            'lightmagenta': 13,
            'lightyellow': 14,
            'brightwhite': 15,
            'orange': 6,  # closest to yellow
        }
        
        if color in color_map:
            self.kernel32.SetConsoleTextAttribute(self.std_output_handle, color_map[color])
        elif color.isalnum() and len(color) == 6:
            # Hex color - for simplicity, map to closest basic color
            # Full RGB would require ANSI escape codes
            try:
                r = int(color[0:2], 16)
                g = int(color[2:4], 16)
                b = int(color[4:6], 16)
                # Simple mapping to closest Windows console color
                if r > g and r > b:
                    self.kernel32.SetConsoleTextAttribute(self.std_output_handle, 4)  # red
                elif g > r and g > b:
                    self.kernel32.SetConsoleTextAttribute(self.std_output_handle, 2)  # green
                elif b > r and b > g:
                    self.kernel32.SetConsoleTextAttribute(self.std_output_handle, 1)  # blue
                elif r > 200 and g > 200 and b > 200:
                    self.kernel32.SetConsoleTextAttribute(self.std_output_handle, 7)  # white
                else:
                    self.kernel32.SetConsoleTextAttribute(self.std_output_handle, 7)  # default white
            except:
                pass
        
    def execute_html(self, html_code: str):
        """Execute HTML code by opening it in default browser"""
        import tempfile
        import webbrowser
        
        # Create a temporary HTML file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False, encoding='utf-8') as f:
            f.write(html_code)
            temp_path = f.name
        
        # Open in default browser
        webbrowser.open('file://' + temp_path)
    
    def execute_python(self, python_code: str):
        """Execute Python code"""
        try:
            # Execute in the current context
            exec(python_code, {'__builtins__': __builtins__}, self.variables)
        except Exception as e:
            error_msg = f"Python execution error: {str(e)}"
            self.errors.append(error_msg)
            if not self.show_errors:
                print(f"\n{error_msg}")
                import traceback
                traceback.print_exc()
    
    def is_key_pressed(self, key: str) -> bool:
        """Check if a specific key is currently pressed (Windows only)"""
        key_codes = {
            'cmd': 0x5B,      # Left Windows key
            'ctrl': 0x11,     # Ctrl
            'alt': 0x12,      # Alt
            'tab': 0x09,      # Tab
            'enter': 0x0D,    # Enter
            'backspace': 0x08,# Backspace
            'shift': 0x10,    # Shift
        }
        
        if key.lower() in key_codes:
            try:
                import ctypes
                return bool(ctypes.windll.user32.GetAsyncKeyState(key_codes[key.lower()]) & 0x8000)
            except:
                return False
        elif len(key) == 1:
            try:
                import ctypes
                return bool(ctypes.windll.user32.GetAsyncKeyState(ord(key.upper())) & 0x8000)
            except:
                return False
        return False
    
    def resolve_value(self, value: str) -> Any:
        """Resolve a value (could be a string, variable, or number)"""
        value = value.strip()
        
        # Check if it's a variable reference
        if value.startswith('$'):
            var_name = value[1:]
            if var_name in self.variables:
                return self.variables[var_name]
            else:
                return f"undefined_variable_{var_name}"
        
        # Check if it's a number
        try:
            if '.' in value:
                return float(value)
            return int(value)
        except ValueError:
            pass
        
        # Return as string
        return value
    
    def parse_list(self, list_str: str) -> List[Any]:
        """Parse a list definition like ["value", $var, 123]"""
        list_str = list_str.strip()
        if not list_str.startswith('[') or not list_str.endswith(']'):
            return []
        
        content = list_str[1:-1]
        items = []
        current_item = ""
        in_quotes = False
        
        for char in content:
            if char == '"':
                in_quotes = not in_quotes
            elif char == ',' and not in_quotes:
                item = current_item.strip()
                if item.startswith('"') and item.endswith('"'):
                    item = item[1:-1]
                items.append(self.resolve_value(item))
                current_item = ""
            else:
                current_item += char
        
        # Add last item
        if current_item.strip():
            item = current_item.strip()
            if item.startswith('"') and item.endswith('"'):
                item = item[1:-1]
            items.append(self.resolve_value(item))
        
        return items
    
    def execute_print(self, line: str):
        """Execute print statement"""
        match = re.match(r'print\((.+)\)', line.strip())
        if match:
            content = match.group(1)
            value = self.resolve_value(content)
            print(value)
    
    def create_file(self, filename: str):
        """Create a new file"""
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                pass  # Create empty file
        except Exception as e:
            error_msg = f"Failed to create file '{filename}': {str(e)}"
            self.errors.append(error_msg)
            if not self.show_errors:
                print(f"\nError: {error_msg}")
    
    def write_to_file(self, filename: str, content: str):
        """Write content to a file"""
        try:
            with open(filename, 'a', encoding='utf-8') as f:
                f.write(str(content) + '\n')
        except Exception as e:
            error_msg = f"Failed to write to file '{filename}': {str(e)}"
            self.errors.append(error_msg)
            if not self.show_errors:
                print(f"\nError: {error_msg}")
    
    def execute_var(self, line: str):
        """Execute variable assignment"""
        line = line.strip()
        
        # var input <prompt> <variable>
        if line.startswith('var input '):
            parts = line[10:].split(' ')
            if len(parts) >= 2:
                var_name = parts[-1]
                prompt = ' '.join(parts[:-1])
                user_input = input(self.resolve_value(prompt) + " ")
                self.variables[var_name] = user_input
            return
        
        # var function <name>:
        if line.startswith('var function '):
            func_match = re.match(r'var function\s+(\w+):', line)
            if func_match:
                return func_match.group(1)
            return None
        
        # var <value> - <variable>
        # var $<variable> - <variable>
        match = re.match(r'var\s+(.+?)\s*-\s*(\w+)', line)
        if match:
            value_str = match.group(1)
            var_name = match.group(2)
            
            # Check if it's a list
            if value_str.strip().startswith('['):
                self.variables[var_name] = self.parse_list(value_str)
            else:
                value = self.resolve_value(value_str)
                self.variables[var_name] = value
    
    def execute_if(self, lines: List[str], start_idx: int) -> tuple[bool, int]:
        """Execute if statement, returns (condition_met, end_index)"""
        if_line = lines[start_idx].strip()
        
        # if "<value>" = "<value>":
        match = re.match(r'if\s+"(.+?)"\s*=\s*"(.+?)":', if_line)
        if match:
            value1 = self.resolve_value(match.group(1))
            value2 = self.resolve_value(match.group(2))
            condition = (str(value1) == str(value2))
            return self.execute_if_block(lines, start_idx, condition)
        
        # if "<value>" $<variable>:
        match = re.match(r'if\s+"(.+?)"\s+\$(\w+):', if_line)
        if match:
            value = self.resolve_value(match.group(1))
            var_name = match.group(2)
            condition = var_name in self.variables and value in self.variables[var_name]
            return self.execute_if_block(lines, start_idx, condition)
        
        # if key "<key>":
        match = re.match(r'if\s+key\s+"(.+?)":', if_line)
        if match:
            key = match.group(1)
            condition = self.is_key_pressed(key)
            return self.execute_if_block(lines, start_idx, condition)
        
        # if lastkey "":
        match = re.match(r'if\s+lastkey\s+"(.+?)":', if_line)
        if match:
            key = match.group(1)
            condition = (self.last_key_pressed.lower() == key.lower())
            return self.execute_if_block(lines, start_idx, condition)
        
        return False, start_idx
    
    def execute_if_block(self, lines: List[str], start_idx: int, condition: bool) -> tuple[bool, int]:
        """Execute the body of an if block"""
        i = start_idx + 1
        while i < len(lines):
            line = lines[i].strip()
            if line == '/if':
                return condition, i
            if condition:
                self.execute_line(lines, i)
            i += 1
        return condition, i
    
    def execute_function_call(self, func_name: str):
        """Execute a user-defined function"""
        if func_name in self.functions:
            for line in self.functions[func_name]:
                self.execute_line_simple(line)
    
    def execute_line_simple(self, line: str):
        """Execute a single line without nested structure"""
        line = line.strip()
        if not line or line.startswith('#'):
            return
        
        if line.startswith('print('):
            self.execute_print(line)
        elif line.startswith('createfile '):
            match = re.match(r'createfile\s+"(.+?)"', line)
            if match:
                filename = match.group(1)
                self.create_file(filename)
        elif line.startswith('writeto '):
            match = re.match(r'writeto\s+"(.+?)"', line)
            if match:
                filename = match.group(1)
                rest = line[line.index('"', line.index('"')+1)+1:].strip()
                if rest:
                    content = self.resolve_value(rest)
                    self.write_to_file(filename, content)
        elif line.startswith('var '):
            self.execute_var(line)
        elif line.startswith('textcolor '):
            color = line[10:].strip()
            self.set_text_color(color)
        elif line.startswith('pause '):
            ms = line[6:].strip()
            try:
                ms_value = int(self.resolve_value(ms))
                time.sleep(ms_value / 1000.0)
            except:
                pass
        elif line == 'close()':
            sys.exit(0)
        elif line in self.functions:
            self.execute_function_call(line)
    
    def execute_line(self, lines: List[str], idx: int) -> int:
        """Execute a single line or block, returns next line index"""
        line = lines[idx].strip()
        
        # Skip empty lines and comments
        if not line or line.startswith('#'):
            return idx + 1
        
        # showerror statement
        if line == 'showerror':
            self.show_errors = True
            return idx + 1
        
        # import html statement
        if line == 'import html':
            self.html_imported = True
            return idx + 1
        
        # import python statement
        if line == 'import python':
            self.python_imported = True
            return idx + 1
        
        # import extension statement
        if line.startswith('import ') and line != 'import html' and line != 'import python':
            ext_name = line[7:].strip()
            ext_path = self.find_extension_path(ext_name)
            if ext_path:
                self.load_extension(ext_name, ext_path)
            else:
                error_msg = f"Extension '{ext_name}' not found"
                self.errors.append(error_msg)
                if not self.show_errors:
                    print(f"\nError: {error_msg}")
            return idx + 1
        
        # extension function call (ext.function)
        if '.' in line and not line.startswith('var '):
            match = re.match(r'(\w+)\.(\w+)', line)
            if match:
                ext_name = match.group(1)
                func_or_cmd = match.group(2)
                
                if func_or_cmd == 'help':
                    self.show_extension_help(ext_name)
                else:
                    self.call_extension_function(ext_name, func_or_cmd)
                return idx + 1
        
        # html block
        if line == 'html':
            if not self.html_imported:
                error_msg = "HTML not imported. Use 'import html' first."
                self.errors.append(error_msg)
                if not self.show_errors:
                    print(f"\nError: {error_msg}")
                return idx + 1
            
            # Collect HTML code
            html_code = []
            i = idx + 1
            while i < len(lines):
                html_line = lines[i]
                if html_line.strip() == '/html':
                    self.execute_html('\n'.join(html_code))
                    return i + 1
                html_code.append(html_line)
                i += 1
            return i
        
        # python block
        if line == 'python':
            if not self.python_imported:
                error_msg = "Python not imported. Use 'import python' first."
                self.errors.append(error_msg)
                if not self.show_errors:
                    print(f"\nError: {error_msg}")
                return idx + 1
            
            # Collect Python code
            python_code = []
            i = idx + 1
            while i < len(lines):
                py_line = lines[i]
                if py_line.strip() == '/python':
                    self.execute_python('\n'.join(python_code))
                    return i + 1
                python_code.append(py_line)
                i += 1
            return i
        
        # close() statement
        if line == 'close()':
            sys.exit(0)
        
        # textcolor statement
        if line.startswith('textcolor '):
            color = line[10:].strip()
            self.set_text_color(color)
            return idx + 1
        
        # pause statement
        if line.startswith('pause '):
            ms = line[6:].strip()
            try:
                ms_value = int(self.resolve_value(ms))
                time.sleep(ms_value / 1000.0)
            except:
                pass
            return idx + 1
        
        # repeat statement
        if line.startswith('repeat '):
            match = re.match(r'repeat\s+(.+?):', line)
            if match:
                repeat_count_str = match.group(1).strip()
                try:
                    repeat_count = int(self.resolve_value(repeat_count_str))
                except:
                    repeat_count = 0
                
                # Collect repeat body
                repeat_body = []
                i = idx + 1
                while i < len(lines):
                    repeat_line = lines[i].strip()
                    if repeat_line == '/rep':
                        # Execute the repeat body repeat_count times
                        for _ in range(repeat_count):
                            j = 0
                            temp_lines = repeat_body.copy()
                            while j < len(temp_lines):
                                j = self.execute_line_in_context(temp_lines, j)
                        return i + 1
                    repeat_body.append(lines[i])
                    i += 1
                return i
        
        # print statement
        if line.startswith('print('):
            self.execute_print(line)
            return idx + 1
        
        # createfile statement
        if line.startswith('createfile '):
            match = re.match(r'createfile\s+"(.+?)"', line)
            if match:
                filename = match.group(1)
                self.create_file(filename)
            return idx + 1
        
        # writeto statement
        if line.startswith('writeto '):
            match = re.match(r'writeto\s+"(.+?)"', line)
            if match:
                filename = match.group(1)
                # Next lines until we find content should be written
                # For simplicity, we'll look for the content on the same line after the filename
                # Or we could make it so the next print() goes to the file
                # Let's make it: writeto "file.txt" writes the next value
                # We need to get what to write - let's check if there's content after
                rest = line[line.index('"', line.index('"')+1)+1:].strip()
                if rest:
                    content = self.resolve_value(rest)
                    self.write_to_file(filename, content)
            return idx + 1
        
        # var statement
        if line.startswith('var '):
            func_name = self.execute_var(line)
            if func_name:  # Function definition
                # Collect function body
                func_body = []
                i = idx + 1
                while i < len(lines):
                    func_line = lines[i].strip()
                    if func_line == '/function':
                        self.functions[func_name] = func_body
                        return i + 1
                    func_body.append(func_line)
                    i += 1
                return i
            return idx + 1
        
        # if statement
        if line.startswith('if '):
            _, end_idx = self.execute_if(lines, idx)
            return end_idx + 1
        
        # Function call
        if line in self.functions:
            self.execute_function_call(line)
            return idx + 1
        
        return idx + 1
    
    def execute_line_in_context(self, lines: List[str], idx: int) -> int:
        """Execute a line within a specific context (used for repeat blocks)"""
        if idx >= len(lines):
            return idx + 1
        return self.execute_line(lines, idx)
    
    def remove_comments(self, code: str) -> str:
        """Remove comments from code (#...#)"""
        return re.sub(r'#[^#]*#', '', code)
    
    def execute(self, code: str):
        """Execute dosh code"""
        # Remove comments
        code = self.remove_comments(code)
        
        # Split into lines
        lines = code.split('\n')
        
        # Execute line by line
        i = 0
        while i < len(lines):
            try:
                i = self.execute_line(lines, i)
            except Exception as e:
                error_msg = f"Error at line {i + 1}: {str(e)}"
                self.errors.append(error_msg)
                if not self.show_errors:
                    # If showerror is not set, print error immediately
                    print(f"\nRuntime Error: {error_msg}")
                    import traceback
                    traceback.print_exc()
                    break
                i += 1
        
        # Print collected errors if showerror was set
        if self.show_errors and self.errors:
            print("\n=== Errors ===")
            for error in self.errors:
                print(error)

def main():
    if len(sys.argv) < 2:
        print("Usage: dosh_interpreter.py <file.dosh>")
        print("       dosh_interpreter.py --install-extension <path>")
        sys.exit(1)
    
    # Handle extension installation
    if sys.argv[1] == '--install-extension':
        if len(sys.argv) < 3:
            print("Error: Please specify extension path")
            sys.exit(1)
        
        ext_source_path = sys.argv[2]
        if not os.path.exists(ext_source_path):
            print(f"Error: Extension path '{ext_source_path}' not found")
            sys.exit(1)
        
        if not os.path.isdir(ext_source_path):
            print(f"Error: '{ext_source_path}' is not a directory")
            sys.exit(1)
        
        # Check for main.dosh
        main_dosh = os.path.join(ext_source_path, 'main.dosh')
        if not os.path.exists(main_dosh):
            print(f"Error: Extension must contain 'main.dosh'")
            sys.exit(1)
        
        # Get extension name from directory name
        ext_name = os.path.basename(os.path.abspath(ext_source_path))
        
        # Create extensions directory
        extensions_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'extensions')
        if not os.path.exists(extensions_dir):
            os.makedirs(extensions_dir)
        
        # Copy extension to extensions directory
        ext_dest_path = os.path.join(extensions_dir, ext_name)
        if os.path.exists(ext_dest_path):
            print(f"Extension '{ext_name}' already installed. Updating...")
            shutil.rmtree(ext_dest_path)
        
        shutil.copytree(ext_source_path, ext_dest_path)
        print(f"Extension '{ext_name}' installed successfully!")
        print(f"Use 'import {ext_name}' in your .dosh files to use it.")
        sys.exit(0)
    
    filepath = sys.argv[1]
    
    if not os.path.exists(filepath):
        print(f"Error: File '{filepath}' not found")
        sys.exit(1)
    
    with open(filepath, 'r', encoding='utf-8') as f:
        code = f.read()
    
    interpreter = DoshInterpreter()
    # Set current file directory for extension lookup
    interpreter.current_file_dir = os.path.dirname(os.path.abspath(filepath))
    
    try:
        interpreter.execute(code)
    except Exception as e:
        if not interpreter.show_errors:
            print(f"Runtime Error: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    main()
