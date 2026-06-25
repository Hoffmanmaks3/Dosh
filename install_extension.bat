@echo off
REM Dosh Extension Installer
REM Install a Dosh extension globally
REM Made by Maks Hoffman

echo ========================================
echo Dosh Extension Installer
echo Made by Maks Hoffman
echo ========================================
echo.

if "%~1"=="" (
    echo Opening folder browser...
    echo.
    
    REM Use PowerShell to show modern folder picker dialog
    for /f "delims=" %%i in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Select Extension Folder'; $folderBrowser.ShowNewFolderButton = $false; if ($folderBrowser.ShowDialog() -eq 'OK') { $folderBrowser.SelectedPath }"') do set "EXT_PATH=%%i"
    
    if not defined EXT_PATH (
        echo No folder selected. Exiting.
        pause
        exit /b 1
    )
) else (
    set "EXT_PATH=%~1"
)

if not exist "%EXT_PATH%" (
    echo Error: Path '%EXT_PATH%' does not exist
    pause
    exit /b 1
)

echo Installing extension from: %EXT_PATH%
echo.

python "%~dp0dosh_interpreter.py" --install-extension "%EXT_PATH%"

echo.
pause
