@echo off
echo ========================================
echo    Cursor VIP - Windows Access Tool
echo ========================================
echo.
echo Server IP: 172.31.92.48
echo Username: admin
echo.
echo Choose connection method:
echo 1) PuTTY (if installed)
echo 2) Windows Terminal/PowerShell
echo 3) Command Prompt
echo 4) Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo Starting PuTTY...
    start putty admin@172.31.92.48
) else if "%choice%"=="2" (
    echo Starting Windows Terminal...
    start wt ssh admin@172.31.92.48
) else if "%choice%"=="3" (
    echo Starting Command Prompt SSH...
    start cmd /k "ssh admin@172.31.92.48"
) else if "%choice%"=="4" (
    echo Goodbye!
    exit /b 0
) else (
    echo Invalid choice!
    pause
    exit /b 1
)

echo.
echo After connecting, run these commands:
echo cd /home/admin/projects/cursor-vip
echo ./quick-access.sh
echo.
pause
