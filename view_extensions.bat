@echo off
REM Dosh Extension Viewer
REM View all installed Dosh extensions
REM Made by Maks Hoffman

echo ========================================
echo Dosh Extension Viewer
echo Made by Maks Hoffman
echo ========================================
echo.

set "EXTENSIONS_DIR=%~dp0extensions"

if not exist "%EXTENSIONS_DIR%" (
    echo No extensions directory found.
    echo No extensions are currently installed.
    echo.
    pause
    exit /b 0
)

REM Count extensions
set count=0
for /d %%i in ("%EXTENSIONS_DIR%\*") do set /a count+=1

if %count%==0 (
    echo No extensions are currently installed.
    echo.
    echo To install an extension, run: install_extension.bat
    echo.
    pause
    exit /b 0
)

echo Installed Extensions:
echo --------------------
echo.

for /d %%i in ("%EXTENSIONS_DIR%\*") do (
    echo Extension: %%~ni
    if exist "%%i\help.txt" (
        echo   - Has help file
    ) else (
        echo   - No help file
    )
    if exist "%%i\main.dosh" (
        echo   - Has main.dosh
    ) else (
        echo   - Missing main.dosh ^(INVALID^)
    )
    echo   - Path: %%i
    echo.
)

echo --------------------
echo Total: %count% extension^(s^) installed
echo.
echo To use an extension in your .dosh file:
echo   import extensionname
echo   extensionname.functionname
echo   extensionname.help
echo.

pause
