@echo off
title Cursor VIP - Bypassed Version (Windows)
color 0A

echo.
echo ========================================
echo    Cursor VIP - Bypassed Version
echo ========================================
echo.
echo ✅ Payment verification: BYPASSED
echo ⏰ Expiration time: 2099-12-31 23:59:59
echo 🎮 Unlimited access to all features
echo 🎉 Enjoy unlimited access!
echo.
echo ========================================
echo.

REM Check if the executable exists
if not exist "cursor-vip_windows_bypassed.exe" (
    echo ❌ Error: cursor-vip_windows_bypassed.exe not found!
    echo Please make sure the file is in the same directory.
    pause
    exit /b 1
)

echo 🚀 Starting Cursor VIP (Bypassed Version)...
echo.
echo Press Ctrl+C to stop the application
echo.

REM Run the bypassed version
cursor-vip_windows_bypassed.exe

echo.
echo 🧹 Application stopped.
echo.
pause
