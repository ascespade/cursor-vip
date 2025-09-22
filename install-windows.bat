@echo off
title Cursor VIP Windows Installer
color 0A

echo.
echo ========================================
echo    Cursor VIP Windows Installer
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if errorlevel 1 (
    echo Error: This installer requires administrator privileges.
    echo Please run as administrator.
    pause
    exit /b 1
)

echo Installing Cursor VIP Professional Launcher...
echo.

REM Create installation directory
set "INSTALL_DIR=%PROGRAMFILES%\Cursor VIP"
echo Creating installation directory: %INSTALL_DIR%
mkdir "%INSTALL_DIR%" 2>nul

REM Copy files
echo Copying files...
copy "build\cursor-vip_windows_bypassed_fixed.exe" "%INSTALL_DIR%\" >nul
copy "cursor-vip-gui.py" "%INSTALL_DIR%\" >nul
copy "start-gui.bat" "%INSTALL_DIR%\" >nul

REM Create desktop shortcut
echo Creating desktop shortcut...
set "DESKTOP=%USERPROFILE%\Desktop"
echo [InternetShortcut] > "%DESKTOP%\Cursor VIP Launcher.url"
echo URL=file:///%INSTALL_DIR%/start-gui.bat >> "%DESKTOP%\Cursor VIP Launcher.url"
echo IconFile=%INSTALL_DIR%/cursor-vip_windows_bypassed_fixed.exe >> "%DESKTOP%\Cursor VIP Launcher.url"
echo IconIndex=0 >> "%DESKTOP%\Cursor VIP Launcher.url"

REM Create start menu shortcut
echo Creating start menu shortcut...
set "START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs"
mkdir "%START_MENU%\Cursor VIP" 2>nul
echo [InternetShortcut] > "%START_MENU%\Cursor VIP\Cursor VIP Launcher.url"
echo URL=file:///%INSTALL_DIR%/start-gui.bat >> "%START_MENU%\Cursor VIP\Cursor VIP Launcher.url"
echo IconFile=%INSTALL_DIR%/cursor-vip_windows_bypassed_fixed.exe >> "%START_MENU%\Cursor VIP\Cursor VIP Launcher.url"
echo IconIndex=0 >> "%START_MENU%\Cursor VIP\Cursor VIP Launcher.url"

REM Install Python dependencies
echo Installing Python dependencies...
pip install psutil >nul 2>&1

REM Create uninstaller
echo Creating uninstaller...
echo @echo off > "%INSTALL_DIR%\uninstall.bat"
echo title Cursor VIP Uninstaller >> "%INSTALL_DIR%\uninstall.bat"
echo echo Uninstalling Cursor VIP... >> "%INSTALL_DIR%\uninstall.bat"
echo del "%DESKTOP%\Cursor VIP Launcher.url" >> "%INSTALL_DIR%\uninstall.bat"
echo rmdir /s /q "%START_MENU%\Cursor VIP" >> "%INSTALL_DIR%\uninstall.bat"
echo rmdir /s /q "%INSTALL_DIR%" >> "%INSTALL_DIR%\uninstall.bat"
echo echo Cursor VIP uninstalled successfully. >> "%INSTALL_DIR%\uninstall.bat"
echo pause >> "%INSTALL_DIR%\uninstall.bat"

echo.
echo ========================================
echo    Installation Complete!
echo ========================================
echo.
echo Cursor VIP has been installed to: %INSTALL_DIR%
echo.
echo Desktop shortcut created: Cursor VIP Launcher
echo Start menu shortcut created: Cursor VIP
echo.
echo You can now:
echo 1. Double-click the desktop shortcut to start
echo 2. Find it in the Start Menu
echo 3. Run: %INSTALL_DIR%\start-gui.bat
echo.
echo To uninstall, run: %INSTALL_DIR%\uninstall.bat
echo.
pause
