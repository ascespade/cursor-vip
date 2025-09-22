#!/bin/bash

# Cursor VIP Auto-Launcher
# Automatically opens Cursor with paid features after selection

echo "🚀 Cursor VIP Auto-Launcher"
echo "================================"
echo ""

# Function to start Cursor VIP in background
start_cursor_vip() {
    echo "🔄 Starting Cursor VIP in background..."
    nohup ./build/cursor-vip_bypassed_fixed > /dev/null 2>&1 &
    CURSOR_VIP_PID=$!
    echo "✅ Cursor VIP started with PID: $CURSOR_VIP_PID"
    sleep 3  # Wait for initialization
}

# Function to open Cursor with paid features
open_cursor() {
    echo "🎯 Opening Cursor with paid features..."
    
    # Check if Cursor is installed
    if command -v cursor &> /dev/null; then
        echo "✅ Cursor found, opening with paid features..."
        cursor --enable-paid-features &
    elif [ -f "/Applications/Cursor.app/Contents/MacOS/Cursor" ]; then
        echo "✅ Cursor.app found, opening with paid features..."
        /Applications/Cursor.app/Contents/MacOS/Cursor --enable-paid-features &
    elif [ -f "/opt/cursor/cursor" ]; then
        echo "✅ Cursor found in /opt/cursor, opening with paid features..."
        /opt/cursor/cursor --enable-paid-features &
    else
        echo "❌ Cursor not found. Please install Cursor first."
        echo "   Download from: https://cursor.sh/"
        return 1
    fi
    
    echo "🎉 Cursor opened with paid features enabled!"
    echo "   All premium features are now available!"
}

# Function to show menu
show_menu() {
    echo ""
    echo "Choose your action:"
    echo "1) Start Cursor VIP + Open Cursor (Recommended)"
    echo "2) Start Cursor VIP only"
    echo "3) Open Cursor only (if VIP is already running)"
    echo "4) Stop Cursor VIP"
    echo "5) Check status"
    echo "6) Exit"
    echo ""
    read -p "Enter your choice (1-6): " choice
}

# Function to check if Cursor VIP is running
check_cursor_vip() {
    if pgrep -f "cursor-vip_bypassed_fixed" > /dev/null; then
        echo "✅ Cursor VIP is running"
        return 0
    else
        echo "❌ Cursor VIP is not running"
        return 1
    fi
}

# Function to stop Cursor VIP
stop_cursor_vip() {
    echo "🛑 Stopping Cursor VIP..."
    pkill -f "cursor-vip_bypassed_fixed"
    if [ $? -eq 0 ]; then
        echo "✅ Cursor VIP stopped"
    else
        echo "❌ Failed to stop Cursor VIP"
    fi
}

# Main loop
while true; do
    show_menu
    
    case $choice in
        1)
            echo ""
            echo "🚀 Starting Cursor VIP + Opening Cursor..."
            start_cursor_vip
            open_cursor
            echo ""
            echo "✅ Setup complete! Cursor is now running with paid features."
            echo "   Press Ctrl+C to stop this script (Cursor will keep running)"
            echo ""
            # Keep script running to maintain the session
            while true; do
                sleep 30
                if ! check_cursor_vip; then
                    echo "⚠️  Cursor VIP stopped, restarting..."
                    start_cursor_vip
                fi
            done
            ;;
        2)
            echo ""
            start_cursor_vip
            echo "✅ Cursor VIP started. You can now open Cursor manually."
            ;;
        3)
            echo ""
            if check_cursor_vip; then
                open_cursor
            else
                echo "❌ Cursor VIP is not running. Please start it first (option 1 or 2)."
            fi
            ;;
        4)
            echo ""
            stop_cursor_vip
            ;;
        5)
            echo ""
            check_cursor_vip
            if command -v cursor &> /dev/null; then
                echo "✅ Cursor is installed"
            else
                echo "❌ Cursor is not installed"
            fi
            ;;
        6)
            echo ""
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice. Please try again."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
