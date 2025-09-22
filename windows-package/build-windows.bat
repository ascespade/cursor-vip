@echo off
title Cursor VIP Windows Builder
color 0A

echo.
echo ========================================
echo    Cursor VIP Windows Builder
echo ========================================
echo.

REM Check if Go is installed
echo Checking Go installation...
go version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Go is not installed or not in PATH
    echo.
    echo Please install Go from: https://golang.org/dl/
    echo Make sure to add Go to your PATH
    echo.
    pause
    exit /b 1
)

echo ✅ Go is installed

REM Check if required tools are installed
echo Checking required tools...

REM Check for rsrc (for Windows icon embedding)
where rsrc >nul 2>&1
if errorlevel 1 (
    echo Installing rsrc for Windows icon embedding...
    go install github.com/akavel/rsrc@latest
    if errorlevel 1 (
        echo ❌ Error: Failed to install rsrc
        echo Please run: go install github.com/akavel/rsrc@latest
        pause
        exit /b 1
    )
)

echo ✅ Required tools are available

REM Create build directory
echo Creating build directory...
if not exist "build" mkdir build

REM Build the application
echo Building Cursor VIP for Windows...
echo.

REM Build with icon embedding
echo Step 1: Building executable...
go build -ldflags "-s -w" -o build/cursor-vip_windows_bypassed_fixed.exe .

if errorlevel 1 (
    echo ❌ Error: Build failed
    echo Please check the error messages above
    pause
    exit /b 1
)

echo ✅ Build successful

REM Check if executable was created
if not exist "build\cursor-vip_windows_bypassed_fixed.exe" (
    echo ❌ Error: Executable not found after build
    pause
    exit /b 1
)

REM Get file size
for %%A in ("build\cursor-vip_windows_bypassed_fixed.exe") do set "filesize=%%~zA"
set /a "filesizeMB=%filesize% / 1048576"

echo.
echo ========================================
echo    Build Complete!
echo ========================================
echo.
echo ✅ Executable created: build\cursor-vip_windows_bypassed_fixed.exe
echo 📁 File size: %filesizeMB% MB
echo.
echo You can now:
echo 1. Run: start-gui.bat (for GUI launcher)
echo 2. Run: build\cursor-vip_windows_bypassed_fixed.exe (direct)
echo 3. Install: install-windows.bat (full installation)
echo.
echo The application is ready to use!
echo.
pause
