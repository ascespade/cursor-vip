#!/bin/bash

# Enhanced Linux Build Script for Cursor VIP Optimized
# This script builds the optimized application for Linux with all features

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --optimized-only    Build only the optimized version"
    echo "  --no-compression    Skip UPX compression"
    echo "  --no-gui           Skip GUI launcher creation"
    echo "  --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build all versions"
    echo "  $0 --optimized-only  # Build only optimized version"
    echo "  $0 --no-compression  # Build without compression"
}

# Default options
BUILD_OPTIMIZED_ONLY=false
NO_COMPRESSION=false
NO_GUI=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --optimized-only)
            BUILD_OPTIMIZED_ONLY=true
            shift
            ;;
        --no-compression)
            NO_COMPRESSION=true
            shift
            ;;
        --no-gui)
            NO_GUI=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

print_header "Cursor VIP Optimized Build Script v3.0"

# Check if Go is installed
if ! command -v go &> /dev/null; then
    print_error "Go is not installed. Please install Go 1.23+ first."
    echo "Download from: https://golang.org/dl/"
    exit 1
fi

print_status "Go version: $(go version)"
echo

# Create build directory
mkdir -p build
print_status "Created build directory"
echo

# Install dependencies
print_step "Installing dependencies..."
go mod tidy
go mod download
if [ $? -ne 0 ]; then
    print_error "Failed to install dependencies"
    exit 1
fi
print_success "Dependencies installed"
echo

# Install build tools
print_step "Installing build tools..."

# Install upx for compression (optional)
if [ "$NO_COMPRESSION" = false ]; then
    print_status "Installing UPX for compression..."
    if command -v upx &> /dev/null; then
        print_success "UPX already installed"
        USE_UPX=true
    else
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y upx
            USE_UPX=true
        elif command -v yum &> /dev/null; then
            sudo yum install -y upx
            USE_UPX=true
        elif command -v pacman &> /dev/null; then
            sudo pacman -S upx
            USE_UPX=true
        else
            print_warning "UPX not available, skipping compression"
            USE_UPX=false
        fi
    fi
else
    print_warning "Compression disabled by user"
    USE_UPX=false
fi
echo

# Build optimized version
print_step "Building optimized version..."
print_status "Building for Linux AMD64..."

# Build the optimized executable
print_status "Compiling optimized executable..."
BUILD_FLAGS="-trimpath -buildvcs=false -ldflags=-s -w"
CGO_ENABLED=0
GOOS=linux
GOARCH=amd64

go build $BUILD_FLAGS -o "build/cursor-vip_linux_optimized" optimized_main.go optimized_auth.go
if [ $? -ne 0 ]; then
    print_error "Failed to build optimized version"
    exit 1
fi

print_success "Optimized version built successfully"
echo

# Build standard version if not optimized-only
if [ "$BUILD_OPTIMIZED_ONLY" = false ]; then
    print_step "Building standard version..."
    print_status "Building standard executable..."
    
    go build $BUILD_FLAGS -o "build/cursor-vip_linux_amd64" main.go
    if [ $? -ne 0 ]; then
        print_error "Failed to build standard version"
        exit 1
    fi
    
    print_success "Standard version built successfully"
    echo
fi

# Compress executables if UPX is available
if [ "$USE_UPX" = true ]; then
    print_step "Compressing executables..."
    
    print_status "Compressing optimized version..."
    upx --best --lzma "build/cursor-vip_linux_optimized"
    if [ $? -ne 0 ]; then
        print_warning "Failed to compress optimized version"
    else
        print_success "Optimized version compressed"
    fi
    
    if [ "$BUILD_OPTIMIZED_ONLY" = false ]; then
        print_status "Compressing standard version..."
        upx --best --lzma "build/cursor-vip_linux_amd64"
        if [ $? -ne 0 ]; then
            print_warning "Failed to compress standard version"
        else
            print_success "Standard version compressed"
        fi
    fi
    echo
fi

# Create GUI launcher if not disabled
if [ "$NO_GUI" = false ]; then
    print_step "Creating GUI launcher..."
    print_status "Copying GUI launcher..."
    
    cp "cursor_vip_gui_optimized.py" "build/cursor_vip_gui_optimized.py"
    if [ $? -ne 0 ]; then
        print_warning "Failed to copy GUI launcher"
    else
        print_success "GUI launcher copied"
    fi
    
    # Create requirements file for Python GUI
    print_status "Creating Python requirements file..."
    cat > "build/requirements.txt" << EOF
psutil
requests
tkinter
EOF
    
    print_success "Requirements file created"
    echo
fi

# Create installation script
print_step "Creating installation script..."
print_status "Creating install.sh..."

cat > "build/install.sh" << 'EOF'
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
EOF

chmod +x "build/install.sh"
print_success "Installation script created"
echo

# Create README for Linux
print_step "Creating Linux README..."
print_status "Creating README_LINUX_OPTIMIZED.txt..."

cat > "build/README_LINUX_OPTIMIZED.txt" << 'EOF'
Cursor VIP Optimized - Linux Package
====================================

This package contains the optimized version of Cursor VIP with enhanced performance and features.

CONTENTS:
- cursor-vip_linux_optimized     : Optimized command-line version
- cursor-vip_linux_amd64         : Standard command-line version
- cursor_vip_gui_optimized.py    : Enhanced GUI launcher
- requirements.txt               : Python dependencies
- install.sh                     : Installation script
- README_LINUX_OPTIMIZED.txt     : This file

INSTALLATION:
1. Run: chmod +x install.sh && ./install.sh
2. Choose your preferred method:
   - GUI: python3 cursor_vip_gui_optimized.py
   - CLI: ./cursor-vip_linux_optimized

FEATURES:
- Enhanced Performance Mode
- Real-time monitoring
- Advanced logging
- Memory optimization
- Better error handling
- Professional GUI interface

REQUIREMENTS:
- Linux (Ubuntu/Debian/CentOS/Arch)
- Python 3.7+ (for GUI)
- Go 1.23+ (for building)

USAGE:
1. GUI Method (Recommended):
   - Run: python3 cursor_vip_gui_optimized.py
   - Click "Start Cursor VIP + Open Cursor"
   - Enjoy unlimited access!

2. Command Line Method:
   - Run: ./cursor-vip_linux_optimized
   - Follow the prompts
   - Open Cursor manually

TROUBLESHOOTING:
- If GUI doesn't start: Install Python 3 and run install.sh
- If CLI doesn't work: Check permissions (chmod +x)
- For help: Check the log files or contact support

SUPPORT:
- GitHub: https://github.com/kingparks/cursor-vip
- Issues: Check the GitHub issues page

Made with ❤️ for the developer community
EOF

print_success "Linux README created"
echo

# Set executable permissions
print_step "Setting executable permissions..."
chmod +x build/cursor-vip_linux_optimized
if [ "$BUILD_OPTIMIZED_ONLY" = false ]; then
    chmod +x build/cursor-vip_linux_amd64
fi
chmod +x build/install.sh
print_success "Executable permissions set"
echo

# Show build results
print_header "BUILD COMPLETED SUCCESSFULLY!"
echo
print_status "Built files:"
ls -la build/*.exe build/cursor-vip_linux_* 2>/dev/null || true
echo
print_status "Other files:"
ls -la build/*.py build/*.txt build/*.sh 2>/dev/null || true
echo
print_status "File sizes:"
for file in build/cursor-vip_linux_*; do
    if [ -f "$file" ]; then
        size=$(du -h "$file" | cut -f1)
        echo "$(basename "$file"): $size"
    fi
done
echo
print_status "You can now:"
echo "  1. Run ./install.sh to install dependencies"
echo "  2. Use the GUI launcher: python3 cursor_vip_gui_optimized.py"
echo "  3. Use the CLI: ./cursor-vip_linux_optimized"
echo
print_status "The optimized version includes:"
echo "  - Enhanced performance monitoring"
echo "  - Better memory management"
echo "  - Improved error handling"
echo "  - Professional GUI interface"
echo "  - Real-time statistics"
echo