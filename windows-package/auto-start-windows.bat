@echo off
title Cursor VIP Auto-Start Setup
color 0A

echo.
echo ========================================
echo    Cursor VIP Auto-Start Setup
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if errorlevel 1 (
    echo Error: This setup requires administrator privileges.
    echo Please run as administrator.
    pause
    exit /b 1
)

echo Setting up Cursor VIP to start automatically with Windows...
echo.

REM Create startup script
set "STARTUP_SCRIPT=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Cursor VIP Auto-Start.bat"
echo @echo off > "%STARTUP_SCRIPT%"
echo REM Cursor VIP Auto-Start Script >> "%STARTUP_SCRIPT%"
echo cd /d "%~dp0" >> "%STARTUP_SCRIPT%"
echo start /min "" "build\cursor-vip_windows_bypassed_fixed.exe" >> "%STARTUP_SCRIPT%"
echo timeout /t 5 /nobreak ^>nul >> "%STARTUP_SCRIPT%"
echo start "" "cursor-vip-gui.py" >> "%STARTUP_SCRIPT%"

REM Create registry entry for auto-start
echo Creating registry entry...
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "Cursor VIP" /t REG_SZ /d "\"%STARTUP_SCRIPT%\"" /f >nul

echo.
echo ========================================
echo    Auto-Start Setup Complete!
echo ========================================
echo.
echo Cursor VIP will now start automatically when Windows boots.
echo.
echo To disable auto-start:
echo 1. Run: reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "Cursor VIP" /f
echo 2. Delete: %STARTUP_SCRIPT%
echo.
echo To enable auto-start again, run this script.
echo.
pause
