@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Cursor VIP Optimized Installation
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed. Please install Python 3.7+ first.
    echo Download from: https://python.org/downloads/
    pause
    exit /b 1
)

echo [INFO] Python version:
python --version
echo.

REM Install Python dependencies
echo [STEP] Installing Python dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Failed to install Python dependencies
    pause
    exit /b 1
)

echo [SUCCESS] Installation completed!
echo.
echo [INFO] You can now run:
echo   - cursor-vip_windows_optimized.exe (Command line)
echo   - python cursor_vip_gui_optimized.py (GUI launcher)
echo.
pause