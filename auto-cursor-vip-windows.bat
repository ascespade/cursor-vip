@echo off
title Cursor VIP Auto-Launcher (Windows)
color 0A

echo.
echo ========================================
echo    🚀 Cursor VIP Auto-Launcher
echo ========================================
echo.

:menu
echo.
echo Choose your action:
echo 1) Start Cursor VIP + Open Cursor (Recommended)
echo 2) Start Cursor VIP only
echo 3) Open Cursor only (if VIP is already running)
echo 4) Stop Cursor VIP
echo 5) Check status
echo 6) Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto start_and_open
if "%choice%"=="2" goto start_only
if "%choice%"=="3" goto open_only
if "%choice%"=="4" goto stop_vip
if "%choice%"=="5" goto check_status
if "%choice%"=="6" goto exit
echo Invalid choice. Please try again.
goto menu

:start_and_open
echo.
echo 🚀 Starting Cursor VIP + Opening Cursor...
call :start_cursor_vip
call :open_cursor
echo.
echo ✅ Setup complete! Cursor is now running with paid features.
echo    Press Ctrl+C to stop this script (Cursor will keep running)
echo.
:keep_running
timeout /t 30 /nobreak >nul
call :check_cursor_vip
if errorlevel 1 (
    echo ⚠️  Cursor VIP stopped, restarting...
    call :start_cursor_vip
)
goto keep_running

:start_only
echo.
call :start_cursor_vip
echo ✅ Cursor VIP started. You can now open Cursor manually.
pause
goto menu

:open_only
echo.
call :check_cursor_vip
if errorlevel 1 (
    echo ❌ Cursor VIP is not running. Please start it first (option 1 or 2).
) else (
    call :open_cursor
)
pause
goto menu

:stop_vip
echo.
call :stop_cursor_vip
pause
goto menu

:check_status
echo.
call :check_cursor_vip
where cursor >nul 2>&1
if errorlevel 1 (
    echo ❌ Cursor is not installed
) else (
    echo ✅ Cursor is installed
)
pause
goto menu

:exit
echo.
echo 👋 Goodbye!
exit /b 0

:start_cursor_vip
echo 🔄 Starting Cursor VIP in background...
start /b "" "build\cursor-vip_windows_bypassed_fixed.exe" >nul 2>&1
echo ✅ Cursor VIP started
timeout /t 3 /nobreak >nul
goto :eof

:open_cursor
echo 🎯 Opening Cursor with paid features...

REM Check if Cursor is in PATH
where cursor >nul 2>&1
if not errorlevel 1 (
    echo ✅ Cursor found in PATH, opening with paid features...
    start "" cursor --enable-paid-features
    goto :cursor_opened
)

REM Check common Cursor installation paths
if exist "%LOCALAPPDATA%\Programs\cursor\Cursor.exe" (
    echo ✅ Cursor found in AppData, opening with paid features...
    start "" "%LOCALAPPDATA%\Programs\cursor\Cursor.exe" --enable-paid-features
    goto :cursor_opened
)

if exist "%PROGRAMFILES%\Cursor\Cursor.exe" (
    echo ✅ Cursor found in Program Files, opening with paid features...
    start "" "%PROGRAMFILES%\Cursor\Cursor.exe" --enable-paid-features
    goto :cursor_opened
)

if exist "%PROGRAMFILES(X86)%\Cursor\Cursor.exe" (
    echo ✅ Cursor found in Program Files (x86), opening with paid features...
    start "" "%PROGRAMFILES(X86)%\Cursor\Cursor.exe" --enable-paid-features
    goto :cursor_opened
)

REM Check if Cursor is in current directory
if exist "cursor.exe" (
    echo ✅ Cursor found in current directory, opening with paid features...
    start "" cursor.exe --enable-paid-features
    goto :cursor_opened
)

echo ❌ Cursor not found. Please install Cursor first.
echo    Download from: https://cursor.sh/
goto :eof

:cursor_opened
echo 🎉 Cursor opened with paid features enabled!
echo    All premium features are now available!
goto :eof

:check_cursor_vip
tasklist /FI "IMAGENAME eq cursor-vip_windows_bypassed_fixed.exe" 2>NUL | find /I /N "cursor-vip_windows_bypassed_fixed.exe" >NUL
if errorlevel 1 (
    echo ❌ Cursor VIP is not running
    exit /b 1
) else (
    echo ✅ Cursor VIP is running
    exit /b 0
)
goto :eof

:stop_cursor_vip
echo 🛑 Stopping Cursor VIP...
taskkill /F /IM "cursor-vip_windows_bypassed_fixed.exe" >nul 2>&1
if errorlevel 1 (
    echo ❌ Failed to stop Cursor VIP
) else (
    echo ✅ Cursor VIP stopped
)
goto :eof
