@echo off
REM Dosh Extension Uninstaller
REM Uninstall Dosh extensions
REM Made by Maks Hoffman

echo ========================================
echo Dosh Extension Uninstaller
echo Made by Maks Hoffman
echo ========================================
echo.

set "EXTENSIONS_DIR=%~dp0extensions"

if not exist "%EXTENSIONS_DIR%" (
    echo No extensions directory found.
    echo No extensions are currently installed.
    pause
    exit /b 0
)

REM Count extensions
set count=0
for /d %%i in ("%EXTENSIONS_DIR%\*") do set /a count+=1

if %count%==0 (
    echo No extensions are currently installed.
    pause
    exit /b 0
)

echo Installed Extensions:
echo --------------------
set index=0
for /d %%i in ("%EXTENSIONS_DIR%\*") do (
    set /a index+=1
    echo [!index!] %%~ni
    set "ext_!index!=%%~ni"
)
echo.
echo [0] Cancel
echo.

set /p choice="Select extension to uninstall (enter number): "

if "%choice%"=="0" (
    echo Cancelled.
    pause
    exit /b 0
)

REM Validate input
set /a valid=0
if %choice% gtr 0 if %choice% leq %index% set /a valid=1

if %valid%==0 (
    echo Invalid selection.
    pause
    exit /b 1
)

REM Get the selected extension name
setlocal enabledelayedexpansion
call set "selected_ext=%%ext_%choice%%%"

echo.
echo Are you sure you want to uninstall extension: !selected_ext!?
set /p confirm="Type YES to confirm: "

if /i not "!confirm!"=="YES" (
    echo Cancelled.
    pause
    exit /b 0
)

REM Delete the extension folder
set "ext_path=%EXTENSIONS_DIR%\!selected_ext!"
if exist "!ext_path!" (
    rmdir /s /q "!ext_path!"
    echo.
    echo Extension '!selected_ext!' has been uninstalled successfully!
) else (
    echo Error: Extension folder not found.
)

echo.
pause
