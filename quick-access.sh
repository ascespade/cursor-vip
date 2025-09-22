#!/bin/bash

# Quick Access Script for Cursor VIP
# Simple script to quickly access cursor-vip

echo "🚀 Cursor VIP Quick Access"
echo "=========================="
echo ""
echo "Current server: $(hostname)"
echo "IP Address: $(hostname -I | awk '{print $1}')"
echo "Service Status: $(systemctl is-active cursor-vip)"
echo ""

# Show menu
echo "Choose an option:"
echo "1) Start Interactive Session"
echo "2) Start Bypassed Version (No Payment Required)"
echo "3) Show Service Logs"
echo "4) Show Service Status"
echo "5) Restart Service"
echo "6) Stop Service"
echo "7) Start Service"
echo "8) Exit"
echo ""

read -p "Enter your choice (1-8): " choice

case $choice in
    1)
        echo "🔄 Starting interactive session..."
        sudo systemctl stop cursor-vip
        sleep 2
        cd /opt/cursor-vip
        sudo -u cursor-vip ./cursor-vip
        sudo systemctl start cursor-vip
        ;;
    2)
        echo "🎉 Starting bypassed version (no payment required)..."
        ./run-bypassed.sh
        ;;
    3)
        echo "📋 Showing service logs..."
        sudo journalctl -u cursor-vip -f
        ;;
    4)
        echo "📊 Service status:"
        sudo systemctl status cursor-vip --no-pager
        ;;
    5)
        echo "🔄 Restarting service..."
        sudo systemctl restart cursor-vip
        echo "✅ Service restarted!"
        ;;
    6)
        echo "⏹️ Stopping service..."
        sudo systemctl stop cursor-vip
        echo "✅ Service stopped!"
        ;;
    7)
        echo "▶️ Starting service..."
        sudo systemctl start cursor-vip
        echo "✅ Service started!"
        ;;
    8)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice!"
        exit 1
        ;;
esac
