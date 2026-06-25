@echo off
REM Dosh Language Installer
REM This script registers .dosh files to open with the dosh interpreter
REM Made by Maks Hoffman

echo ========================================
echo Dosh Language Installer
echo Made by Maks Hoffman
echo ========================================
echo.

REM Get the current directory
set "INSTALL_DIR=%~dp0"
set "INSTALL_DIR=%INSTALL_DIR:~0,-1%"

echo Installing Dosh to: %INSTALL_DIR%
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/
    pause
    exit /b 1
)

echo Python found!
echo.

REM Create file association for .dosh files
echo Registering .dosh file association...

REM Create registry entries (requires admin privileges)
reg add "HKEY_CLASSES_ROOT\.dosh" /ve /d "DoshFile" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\DoshFile" /ve /d "Dosh Script File" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\DoshFile\DefaultIcon" /ve /d "%SystemRoot%\System32\imageres.dll,76" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\DoshFile\shell\open\command" /ve /d "\"%INSTALL_DIR%\dosh.bat\" \"%%1\"" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Installation successful!
    echo ========================================
    echo.
    echo You can now double-click .dosh files to run them!
    echo.
    
    REM Save installed version
    set "VERSION_FILE=%INSTALL_DIR%\version.json"
    set "INSTALLED_VERSION_FILE=%INSTALL_DIR%\installed_version.txt"
    
    for /f "tokens=2 delims=:, " %%i in ('python -c "import json; f=open('%VERSION_FILE%', 'r'); data=json.load(f); print(data['version']); f.close()" 2^>nul') do set "VERSION=%%~i"
    
    if defined VERSION (
        echo %VERSION%>"%INSTALLED_VERSION_FILE%"
        echo Installed version: %VERSION%
        echo.
    )
    
    echo To uninstall, run: uninstall.bat
    echo To check for updates, run: update.bat
    echo.
) else (
    echo.
    echo ========================================
    echo Installation requires administrator privileges
    echo ========================================
    echo.
    echo Please right-click install.bat and select "Run as administrator"
    echo.
)

pause
