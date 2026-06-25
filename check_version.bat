@echo off
REM Dosh Version Checker
REM Displays current and installed versions
REM Made by Maks Hoffman

echo ========================================
echo Dosh Version Information
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

echo Package Version: %CURRENT_VERSION%

REM Read release date
for /f "tokens=2 delims=:, " %%i in ('python -c "import json; f=open('%VERSION_FILE%', 'r'); data=json.load(f); print(data['release_date']); f.close()" 2^>nul') do set "RELEASE_DATE=%%~i"
echo Release Date: %RELEASE_DATE%
echo.

REM Check if Dosh is installed
if exist "%INSTALLED_VERSION_FILE%" (
    set /p INSTALLED_VERSION=<"%INSTALLED_VERSION_FILE%"
    echo Installed Version: !INSTALLED_VERSION!
    echo.
    
    if "%CURRENT_VERSION%"=="!INSTALLED_VERSION!" (
        echo Status: Up to date
    ) else (
        echo Status: Update available - run update.bat
    )
) else (
    echo Installed Version: Not installed
    echo.
    echo Status: Not installed - run install.bat
)

echo.
echo Changes in version %CURRENT_VERSION%:
echo --------------------
python -c "import json; f=open('%VERSION_FILE%', 'r'); data=json.load(f); [print('  - ' + change) for change in data.get('changes', [])]; f.close()" 2>nul

echo.
pause
