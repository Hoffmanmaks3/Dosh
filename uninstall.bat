@echo off
REM Dosh Language Uninstaller
REM This script removes .dosh file association
REM Made by Maks Hoffman

echo ========================================
echo Dosh Language Uninstaller
echo Made by Maks Hoffman
echo ========================================
echo.

echo Removing .dosh file association...

REM Remove registry entries (requires admin privileges)
reg delete "HKEY_CLASSES_ROOT\.dosh" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\DoshFile" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Uninstallation successful!
    echo ========================================
    echo.
    echo .dosh file association has been removed.
    
    REM Remove installed version file
    if exist "%~dp0installed_version.txt" (
        del "%~dp0installed_version.txt" >nul 2>&1
    )
    
    echo You can safely delete this folder now.
    echo.
) else (
    echo.
    echo ========================================
    echo Uninstallation requires administrator privileges
    echo ========================================
    echo.
    echo Please right-click uninstall.bat and select "Run as administrator"
    echo.
)

pause
