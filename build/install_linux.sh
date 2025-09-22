#!/bin/bash

echo "========================================"
echo "Cursor VIP Optimized Installation"
echo "========================================"
echo

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 is not installed. Please install Python 3.7+ first."
    echo "Install with: sudo apt-get install python3 python3-pip"
    exit 1
fi

echo "[INFO] Python version: $(python3 --version)"
echo

# Install Python dependencies
echo "[STEP] Installing Python dependencies..."
pip3 install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to install Python dependencies"
    echo "Try: pip3 install --user -r requirements.txt"
    exit 1
fi

echo "[SUCCESS] Installation completed!"
echo
echo "[INFO] You can now run:"
echo "  - ./cursor-vip_linux_optimized (Command line)"
echo "  - python3 cursor_vip_gui_optimized.py (GUI launcher)"
echo