# Cursor VIP - Bypassed Version (PowerShell Script)
# This script runs the bypassed version on Windows

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "    Cursor VIP - Bypassed Version" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Payment verification: BYPASSED" -ForegroundColor Yellow
Write-Host "⏰ Expiration time: 2099-12-31 23:59:59" -ForegroundColor Yellow
Write-Host "🎮 Unlimited access to all features" -ForegroundColor Yellow
Write-Host "🎉 Enjoy unlimited access!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if the executable exists
if (-not (Test-Path "cursor-vip_windows_bypassed.exe")) {
    Write-Host "❌ Error: cursor-vip_windows_bypassed.exe not found!" -ForegroundColor Red
    Write-Host "Please make sure the file is in the same directory." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "🚀 Starting Cursor VIP (Bypassed Version)..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the application" -ForegroundColor Yellow
Write-Host ""

try {
    # Run the bypassed version
    & ".\cursor-vip_windows_bypassed.exe"
}
catch {
    Write-Host "❌ Error running the application: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Host ""
    Write-Host "🧹 Application stopped." -ForegroundColor Green
    Write-Host ""
    Read-Host "Press Enter to exit"
}
