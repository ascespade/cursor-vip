@echo off
setlocal enabledelayedexpansion

REM Enhanced Windows Build Script for Cursor VIP Optimized
REM This script builds the optimized application for Windows with all features

echo ========================================
echo Cursor VIP Optimized Build Script v3.0
echo ========================================
echo.

REM Check if Go is installed
go version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Go is not installed. Please install Go 1.23+ first.
    echo Download from: https://golang.org/dl/
    pause
    exit /b 1
)

echo [INFO] Go version:
go version
echo.

REM Create build directory
if not exist "build" mkdir build
echo [INFO] Created build directory
echo.

REM Install dependencies
echo [STEP] Installing dependencies...
go mod tidy
go mod download
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)
echo [SUCCESS] Dependencies installed
echo.

REM Install build tools
echo [STEP] Installing build tools...

REM Install rsrc for Windows icon embedding
echo [INFO] Installing rsrc...
go install github.com/akavel/rsrc@latest
if errorlevel 1 (
    echo [WARNING] Failed to install rsrc, continuing without icon embedding
) else (
    echo [SUCCESS] rsrc installed
)

REM Install upx for compression (optional)
echo [INFO] Installing UPX for compression...
go install github.com/upx/upx@latest
if errorlevel 1 (
    echo [WARNING] UPX not available, skipping compression
    set USE_UPX=false
) else (
    echo [SUCCESS] UPX installed
    set USE_UPX=true
)
echo.

REM Build optimized version
echo [STEP] Building optimized version...
echo [INFO] Building for Windows AMD64...

REM Create Windows resource file for icon
if exist "rsrc.ico" (
    echo [INFO] Creating Windows resource file...
    rsrc -arch amd64 -ico rsrc.ico -o rsrc.syso
    if errorlevel 1 (
        echo [WARNING] Failed to create resource file, continuing without icon
    )
)

REM Build the optimized executable
echo [INFO] Compiling optimized executable...
set BUILD_FLAGS=-ldflags "-s -w -H windowsgui"
set CGO_ENABLED=0
set GOOS=windows
set GOARCH=amd64

go build %BUILD_FLAGS% -o "build\cursor-vip_windows_optimized.exe" optimized_main.go optimized_auth.go
if errorlevel 1 (
    echo [ERROR] Failed to build optimized version
    pause
    exit /b 1
)

REM Clean up resource file
if exist "rsrc.syso" del rsrc.syso

echo [SUCCESS] Optimized version built successfully
echo.

REM Build standard version
echo [STEP] Building standard version...
echo [INFO] Building standard executable...

go build %BUILD_FLAGS% -o "build\cursor-vip_windows_amd64.exe" main.go
if errorlevel 1 (
    echo [ERROR] Failed to build standard version
    pause
    exit /b 1
)

echo [SUCCESS] Standard version built successfully
echo.

REM Compress executables if UPX is available
if "%USE_UPX%"=="true" (
    echo [STEP] Compressing executables...
    
    echo [INFO] Compressing optimized version...
    upx --best --lzma "build\cursor-vip_windows_optimized.exe"
    if errorlevel 1 (
        echo [WARNING] Failed to compress optimized version
    ) else (
        echo [SUCCESS] Optimized version compressed
    )
    
    echo [INFO] Compressing standard version...
    upx --best --lzma "build\cursor-vip_windows_amd64.exe"
    if errorlevel 1 (
        echo [WARNING] Failed to compress standard version
    ) else (
        echo [SUCCESS] Standard version compressed
    )
    echo.
)

REM Create GUI launcher
echo [STEP] Creating GUI launcher...
echo [INFO] Copying GUI launcher...

copy "cursor_vip_gui_optimized.py" "build\cursor_vip_gui_optimized.py"
if errorlevel 1 (
    echo [WARNING] Failed to copy GUI launcher
) else (
    echo [SUCCESS] GUI launcher copied
)

REM Create requirements file for Python GUI
echo [INFO] Creating Python requirements file...
(
echo psutil
echo requests
) > "build\requirements.txt"

echo [SUCCESS] Requirements file created
echo.

REM Create installation script
echo [STEP] Creating installation script...
echo [INFO] Creating install.bat...

(
echo @echo off
echo setlocal enabledelayedexpansion
echo.
echo echo ========================================
echo echo Cursor VIP Optimized Installation
echo echo ========================================
echo echo.
echo.
echo REM Check if Python is installed
echo python --version ^>nul 2^>^&1
echo if errorlevel 1 ^(
echo     echo [ERROR] Python is not installed. Please install Python 3.7+ first.
echo     echo Download from: https://python.org/downloads/
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo [INFO] Python version:
echo python --version
echo echo.
echo.
echo REM Install Python dependencies
echo echo [STEP] Installing Python dependencies...
echo pip install -r requirements.txt
echo if errorlevel 1 ^(
echo     echo [ERROR] Failed to install Python dependencies
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo [SUCCESS] Installation completed!
echo echo.
echo echo [INFO] You can now run:
echo echo   - cursor-vip_windows_optimized.exe ^(Command line^)
echo echo   - python cursor_vip_gui_optimized.py ^(GUI launcher^)
echo echo.
echo pause
) > "build\install.bat"

echo [SUCCESS] Installation script created
echo.

REM Create README for Windows
echo [STEP] Creating Windows README...
echo [INFO] Creating README_WINDOWS_OPTIMIZED.txt...

(
echo Cursor VIP Optimized - Windows Package
echo =====================================
echo.
echo This package contains the optimized version of Cursor VIP with enhanced performance and features.
echo.
echo CONTENTS:
echo - cursor-vip_windows_optimized.exe    : Optimized command-line version
echo - cursor-vip_windows_amd64.exe        : Standard command-line version
echo - cursor_vip_gui_optimized.py         : Enhanced GUI launcher
echo - requirements.txt                    : Python dependencies
echo - install.bat                         : Installation script
echo - README_WINDOWS_OPTIMIZED.txt        : This file
echo.
echo INSTALLATION:
echo 1. Run install.bat to install Python dependencies
echo 2. Choose your preferred method:
echo    - GUI: Run "python cursor_vip_gui_optimized.py"
echo    - CLI: Run "cursor-vip_windows_optimized.exe"
echo.
echo FEATURES:
echo - Enhanced Performance Mode
echo - Real-time monitoring
echo - Advanced logging
echo - Memory optimization
echo - Better error handling
echo - Professional GUI interface
echo.
echo REQUIREMENTS:
echo - Windows 10/11
echo - Python 3.7+ ^(for GUI^)
echo - Go 1.23+ ^(for building^)
echo.
echo USAGE:
echo 1. GUI Method ^(Recommended^):
echo    - Run: python cursor_vip_gui_optimized.py
echo    - Click "Start Cursor VIP + Open Cursor"
echo    - Enjoy unlimited access!
echo.
echo 2. Command Line Method:
echo    - Run: cursor-vip_windows_optimized.exe
echo    - Follow the prompts
echo    - Open Cursor manually
echo.
echo TROUBLESHOOTING:
echo - If GUI doesn't start: Install Python and run install.bat
echo - If CLI doesn't work: Check Windows Defender settings
echo - For help: Check the log files or contact support
echo.
echo SUPPORT:
echo - GitHub: https://github.com/kingparks/cursor-vip
echo - Issues: Check the GitHub issues page
echo.
echo Made with ❤️ for the developer community
) > "build\README_WINDOWS_OPTIMIZED.txt"

echo [SUCCESS] Windows README created
echo.

REM Show build results
echo ========================================
echo BUILD COMPLETED SUCCESSFULLY!
echo ========================================
echo.
echo Built files:
dir /b build\*.exe
echo.
echo Other files:
dir /b build\*.py
dir /b build\*.txt
dir /b build\*.bat
echo.
echo File sizes:
for %%f in (build\*.exe) do (
    echo %%~nxf: %%~zf bytes
)
echo.
echo [INFO] You can now:
echo   1. Run install.bat to install dependencies
echo   2. Use the GUI launcher: python cursor_vip_gui_optimized.py
echo   3. Use the CLI: cursor-vip_windows_optimized.exe
echo.
echo [INFO] The optimized version includes:
echo   - Enhanced performance monitoring
echo   - Better memory management
echo   - Improved error handling
echo   - Professional GUI interface
echo   - Real-time statistics
echo.
pause