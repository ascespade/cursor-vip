#!/bin/bash

# Cursor VIP Bypassed Version Access Script
# This script runs the bypassed version that skips payment verification

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

echo "🎉 Cursor VIP - Bypassed Version"
echo "================================"
echo ""
echo "✅ Payment verification: BYPASSED"
echo "⏰ Expiration time: 2099-12-31 23:59:59"
echo "🎮 Unlimited access to all features"
echo ""

print_step "Starting bypassed cursor-vip..."

# Stop the systemd service if running
if systemctl is-active --quiet cursor-vip; then
    print_status "Stopping systemd service..."
    sudo systemctl stop cursor-vip
fi

# Run the bypassed version
print_status "Running bypassed version..."
cd /home/admin/projects/cursor-vip
./build/cursor-vip_bypassed

# Restart the systemd service when done
print_status "Restarting systemd service..."
sudo systemctl start cursor-vip

print_status "Done!"
