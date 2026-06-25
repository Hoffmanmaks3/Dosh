@echo off
REM Dosh Language Launcher
REM This script runs .dosh files using Python
REM Made by Maks Hoffman

python "%~dp0dosh_interpreter.py" %*
cmd /k
