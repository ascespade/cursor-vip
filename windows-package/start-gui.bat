@echo off
title Cursor VIP Professional Launcher
color 0A

echo.
echo ========================================
echo    Cursor VIP Professional Launcher
echo ========================================
echo.

REM Check if Python is installed
echo Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Python is not installed or not in PATH
    echo.
    echo Please install Python 3.6+ from: https://python.org
    echo Make sure to check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

echo ✅ Python is installed

REM Check if required packages are installed
echo Checking required packages...
python -c "import tkinter, psutil" >nul 2>&1
if errorlevel 1 (
    echo Installing required packages...
    pip install psutil
    if errorlevel 1 (
        echo ❌ Error: Failed to install required packages
        echo Please run: pip install psutil
        pause
        exit /b 1
    )
)

echo ✅ Required packages are available

REM Check if executable exists
echo Checking Cursor VIP executable...
if not exist "build\cursor-vip_windows_bypassed_fixed.exe" (
    echo ❌ Error: Cursor VIP executable not found!
    echo.
    echo Please run the build script first:
    echo 1. Open Command Prompt as Administrator
    echo 2. Navigate to this folder
    echo 3. Run: build.bat
    echo.
    pause
    exit /b 1
)

echo ✅ Cursor VIP executable found

REM Check if Cursor is installed
echo Checking Cursor installation...
where cursor >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Warning: Cursor not found in PATH
    echo Please make sure Cursor is installed from: https://cursor.sh/
    echo.
) else (
    echo ✅ Cursor is installed
)

echo.
echo 🚀 Starting Cursor VIP Professional Launcher...
echo.

REM Start GUI
python cursor-vip-gui.py

if errorlevel 1 (
    echo.
    echo ❌ Error: Failed to start the GUI launcher
    echo Please check the error messages above
    echo.
    pause
)
