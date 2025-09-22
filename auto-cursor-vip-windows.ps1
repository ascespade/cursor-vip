# Cursor VIP Auto-Launcher (PowerShell)
# Automatically opens Cursor with paid features after selection

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "    🚀 Cursor VIP Auto-Launcher" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Function to start Cursor VIP in background
function Start-CursorVIP {
    Write-Host "🔄 Starting Cursor VIP in background..." -ForegroundColor Yellow
    Start-Process -FilePath "build\cursor-vip_windows_bypassed_fixed.exe" -WindowStyle Hidden
    Write-Host "✅ Cursor VIP started" -ForegroundColor Green
    Start-Sleep -Seconds 3
}

# Function to open Cursor with paid features
function Open-Cursor {
    Write-Host "🎯 Opening Cursor with paid features..." -ForegroundColor Yellow
    
    # Check if Cursor is in PATH
    $cursorPath = Get-Command cursor -ErrorAction SilentlyContinue
    if ($cursorPath) {
        Write-Host "✅ Cursor found in PATH, opening with paid features..." -ForegroundColor Green
        Start-Process -FilePath "cursor" -ArgumentList "--enable-paid-features"
        Write-Host "🎉 Cursor opened with paid features enabled!" -ForegroundColor Cyan
        Write-Host "   All premium features are now available!" -ForegroundColor Cyan
        return
    }
    
    # Check common Cursor installation paths
    $cursorPaths = @(
        "$env:LOCALAPPDATA\Programs\cursor\Cursor.exe",
        "$env:PROGRAMFILES\Cursor\Cursor.exe",
        "${env:PROGRAMFILES(X86)}\Cursor\Cursor.exe",
        ".\cursor.exe"
    )
    
    foreach ($path in $cursorPaths) {
        if (Test-Path $path) {
            Write-Host "✅ Cursor found at: $path" -ForegroundColor Green
            Start-Process -FilePath $path -ArgumentList "--enable-paid-features"
            Write-Host "🎉 Cursor opened with paid features enabled!" -ForegroundColor Cyan
            Write-Host "   All premium features are now available!" -ForegroundColor Cyan
            return
        }
    }
    
    Write-Host "❌ Cursor not found. Please install Cursor first." -ForegroundColor Red
    Write-Host "   Download from: https://cursor.sh/" -ForegroundColor Yellow
}

# Function to check if Cursor VIP is running
function Test-CursorVIP {
    $process = Get-Process -Name "cursor-vip_windows_bypassed_fixed" -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "✅ Cursor VIP is running" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Cursor VIP is not running" -ForegroundColor Red
        return $false
    }
}

# Function to stop Cursor VIP
function Stop-CursorVIP {
    Write-Host "🛑 Stopping Cursor VIP..." -ForegroundColor Yellow
    $process = Get-Process -Name "cursor-vip_windows_bypassed_fixed" -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Name "cursor-vip_windows_bypassed_fixed" -Force
        Write-Host "✅ Cursor VIP stopped" -ForegroundColor Green
    } else {
        Write-Host "❌ Cursor VIP is not running" -ForegroundColor Red
    }
}

# Function to show menu
function Show-Menu {
    Write-Host ""
    Write-Host "Choose your action:" -ForegroundColor White
    Write-Host "1) Start Cursor VIP + Open Cursor (Recommended)" -ForegroundColor Cyan
    Write-Host "2) Start Cursor VIP only" -ForegroundColor Cyan
    Write-Host "3) Open Cursor only (if VIP is already running)" -ForegroundColor Cyan
    Write-Host "4) Stop Cursor VIP" -ForegroundColor Cyan
    Write-Host "5) Check status" -ForegroundColor Cyan
    Write-Host "6) Exit" -ForegroundColor Cyan
    Write-Host ""
    $choice = Read-Host "Enter your choice (1-6)"
    return $choice
}

# Main loop
while ($true) {
    $choice = Show-Menu
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "🚀 Starting Cursor VIP + Opening Cursor..." -ForegroundColor Green
            Start-CursorVIP
            Open-Cursor
            Write-Host ""
            Write-Host "✅ Setup complete! Cursor is now running with paid features." -ForegroundColor Green
            Write-Host "   Press Ctrl+C to stop this script (Cursor will keep running)" -ForegroundColor Yellow
            Write-Host ""
            
            # Keep script running to maintain the session
            while ($true) {
                Start-Sleep -Seconds 30
                if (-not (Test-CursorVIP)) {
                    Write-Host "⚠️  Cursor VIP stopped, restarting..." -ForegroundColor Yellow
                    Start-CursorVIP
                }
            }
        }
        "2" {
            Write-Host ""
            Start-CursorVIP
            Write-Host "✅ Cursor VIP started. You can now open Cursor manually." -ForegroundColor Green
            Read-Host "Press Enter to continue"
        }
        "3" {
            Write-Host ""
            if (Test-CursorVIP) {
                Open-Cursor
            } else {
                Write-Host "❌ Cursor VIP is not running. Please start it first (option 1 or 2)." -ForegroundColor Red
            }
            Read-Host "Press Enter to continue"
        }
        "4" {
            Write-Host ""
            Stop-CursorVIP
            Read-Host "Press Enter to continue"
        }
        "5" {
            Write-Host ""
            Test-CursorVIP
            $cursorPath = Get-Command cursor -ErrorAction SilentlyContinue
            if ($cursorPath) {
                Write-Host "✅ Cursor is installed" -ForegroundColor Green
            } else {
                Write-Host "❌ Cursor is not installed" -ForegroundColor Red
            }
            Read-Host "Press Enter to continue"
        }
        "6" {
            Write-Host ""
            Write-Host "👋 Goodbye!" -ForegroundColor Green
            exit
        }
        default {
            Write-Host "❌ Invalid choice. Please try again." -ForegroundColor Red
        }
    }
}
