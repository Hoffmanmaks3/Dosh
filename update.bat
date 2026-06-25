@echo off
REM Dosh Update Manager
REM Check for updates and install new versions
REM Made by Maks Hoffman

echo ========================================
echo Dosh Update Manager
echo Made by Maks Hoffman
echo ========================================
echo.

set "SCRIPT_DIR=%~dp0"
set "VERSION_FILE=%SCRIPT_DIR%version.json"
set "INSTALLED_VERSION_FILE=%SCRIPT_DIR%installed_version.txt"

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Read current version from version.json
for /f "tokens=2 delims=:, " %%i in ('python -c "import json; f=open('%VERSION_FILE%', 'r'); data=json.load(f); print(data['version']); f.close()" 2^>nul') do set "CURRENT_VERSION=%%~i"

if not defined CURRENT_VERSION (
    echo Error: Could not read version information
    pause
    exit /b 1
)

echo Current Dosh version in this folder: %CURRENT_VERSION%
echo.

REM Check if Dosh is installed
if not exist "%INSTALLED_VERSION_FILE%" (
    echo Dosh is not installed on this machine.
    echo.
    echo To install, run: install.bat
    echo.
    pause
    exit /b 0
)

REM Read installed version
set /p INSTALLED_VERSION=<"%INSTALLED_VERSION_FILE%"
echo Installed Dosh version: %INSTALLED_VERSION%
echo.

REM Compare versions
if "%CURRENT_VERSION%"=="%INSTALLED_VERSION%" (
    echo ========================================
    echo You have the latest version!
    echo ========================================
    echo.
    echo No update needed.
    echo.
    pause
    exit /b 0
)

echo ========================================
echo Update Available!
echo ========================================
echo.
echo New version: %CURRENT_VERSION%
echo Your version: %INSTALLED_VERSION%
echo.

REM Show changelog
echo Changes in version %CURRENT_VERSION%:
echo --------------------
python -c "import json; f=open('%VERSION_FILE%', 'r'); data=json.load(f); [print('  - ' + change) for change in data.get('changes', [])]; f.close()" 2>nul
echo.

set /p UPDATE="Would you like to update? (Y/N): "
if /i not "%UPDATE%"=="Y" (
    echo Update cancelled.
    pause
    exit /b 0
)

echo.
echo Updating Dosh...
echo.

REM Check if we need admin privileges for registry update
reg query "HKEY_CLASSES_ROOT\.dosh" >nul 2>&1
if %errorlevel% equ 0 (
    echo Updating file association...
    
    REM Get the install directory
    set "INSTALL_DIR=%SCRIPT_DIR:~0,-1%"
    
    REM Update registry entries
    reg add "HKEY_CLASSES_ROOT\DoshFile\shell\open\command" /ve /d "\"%INSTALL_DIR%\dosh.bat\" \"%%1\"" /f >nul 2>&1
    
    if %errorlevel% equ 0 (
        echo File association updated successfully.
    ) else (
        echo Warning: Could not update file association. May need administrator privileges.
    )
) else (
    echo Note: File association not found. You may need to run install.bat first.
)

echo.
echo Copying updated files...

REM Create backup directory
set "BACKUP_DIR=%SCRIPT_DIR%backup_%INSTALLED_VERSION%"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM Backup current interpreter
if exist "%SCRIPT_DIR%dosh_interpreter.py" (
    copy /Y "%SCRIPT_DIR%dosh_interpreter.py" "%BACKUP_DIR%\dosh_interpreter.py" >nul 2>&1
    echo Backed up interpreter to: %BACKUP_DIR%
)

REM Update version file
echo %CURRENT_VERSION%>"%INSTALLED_VERSION_FILE%"

echo.
echo ========================================
echo Update Complete!
echo ========================================
echo.
echo Dosh has been updated to version %CURRENT_VERSION%
echo.
echo Backup of previous version saved to: %BACKUP_DIR%
echo.
pause
