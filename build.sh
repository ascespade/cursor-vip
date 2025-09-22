#!/bin/bash

# Enhanced Build Script for cursor-vip
# This script builds the application for multiple platforms and provides local development options

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --local               Build for local development only"
    echo "  --platform PLATFORM  Build for specific platform (darwin/linux/windows)"
    echo "  --arch ARCH           Build for specific architecture (amd64/arm64/386)"
    echo "  --no-obfuscation      Disable code obfuscation"
    echo "  --dev                 Build in development mode (no obfuscation, debug info)"
    echo "  --help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build all platforms"
    echo "  $0 --local           # Build for current platform only"
    echo "  $0 --platform linux --arch amd64  # Build specific platform/arch"
    echo "  $0 --dev             # Development build"
}

# Default options
BUILD_LOCAL=false
BUILD_PLATFORM=""
BUILD_ARCH=""
NO_OBFUSCATION=false
DEV_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --local)
            BUILD_LOCAL=true
            shift
            ;;
        --platform)
            BUILD_PLATFORM="$2"
            shift 2
            ;;
        --arch)
            BUILD_ARCH="$2"
            shift 2
            ;;
        --no-obfuscation)
            NO_OBFUSCATION=true
            shift
            ;;
        --dev)
            DEV_MODE=true
            NO_OBFUSCATION=true
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

# Check if Go is installed
if ! command -v go &> /dev/null; then
    print_error "Go is not installed. Please install Go 1.23+ first."
    exit 1
fi

# Install dependencies
print_step "Installing dependencies..."
go mod tidy
go mod download

# Install build tools
print_step "Installing build tools..."

# Install garble for obfuscation
if ! command -v garble &> /dev/null; then
    print_status "Installing garble..."
    go install mvdan.cc/garble@latest
fi

# Install rsrc for Windows icon embedding
if ! command -v rsrc &> /dev/null; then
    print_status "Installing rsrc..."
    go install github.com/akavel/rsrc@latest
fi

# Create build directory
mkdir -p build

# Function to build for a specific platform and architecture
build_platform() {
    local os=$1
    local arch=$2
    local output_name="cursor-vip_${os}_${arch}"
    
    print_status "Building for $os $arch..."
    
    if [[ $os == "windows" ]]; then
        output_name="${output_name}.exe"
        # Windows build with icon
        if [[ -f rsrc.ico ]]; then
            rsrc -arch "$arch" -ico rsrc.ico -o rsrc.syso
        fi
        
        if [[ $DEV_MODE == true ]]; then
            GOOS=$os GOARCH=$arch CGO_ENABLED=0 go build -o "build/$output_name"
        else
            GOOS=$os GOARCH=$arch CGO_ENABLED=0 go build -ldflags "-s -w" -o "build/$output_name"
        fi
        
        # Clean up rsrc.syso
        rm -f rsrc.syso
    else
        # Unix-like systems (Linux, macOS)
        if [[ $DEV_MODE == true || $NO_OBFUSCATION == true ]]; then
            GOOS=$os GOARCH=$arch CGO_ENABLED=0 go build -o "build/$output_name"
        else
            GOOS=$os GOARCH=$arch CGO_ENABLED=0 garble -literals -tiny build -ldflags "-w -s" -o "build/$output_name"
        fi
    fi
    
    chmod +x "build/$output_name"
    print_status "Built: build/$output_name"
}

# Build based on options
if [[ $BUILD_LOCAL == true ]]; then
    # Build for current platform only
    current_os=$(uname -s | tr '[:upper:]' '[:lower:]')
    current_arch=$(uname -m)
    
    case "$current_arch" in
        "amd64"|"x86_64")
            current_arch="amd64"
            ;;
        "arm64"|"aarch64")
            current_arch="arm64"
            ;;
        "i686")
            current_arch="386"
            ;;
        *)
            print_warning "Unsupported architecture $current_arch, using amd64"
            current_arch="amd64"
            ;;
    esac
    
    if [[ $current_os == *"mingw"* ]]; then
        current_os="windows"
    fi
    
    build_platform "$current_os" "$current_arch"
    
elif [[ -n "$BUILD_PLATFORM" && -n "$BUILD_ARCH" ]]; then
    # Build for specific platform and architecture
    build_platform "$BUILD_PLATFORM" "$BUILD_ARCH"
    
else
    # Build for all platforms (original behavior)
    print_step "Building for all platforms..."
    
    # macOS builds
    build_platform "darwin" "amd64"
    build_platform "darwin" "arm64"
    
    # Windows builds
    build_platform "windows" "amd64"
    build_platform "windows" "arm64"
    build_platform "windows" "386"
    
    # Linux builds
    build_platform "linux" "amd64"
    build_platform "linux" "arm64"
    build_platform "linux" "386"
fi

# Set executable permissions for install scripts
print_step "Setting executable permissions..."
chmod +x build/i.sh build/ic.sh build/install.sh 2>/dev/null || true

print_status "Build completed successfully!"
print_status "Built files are in the 'build' directory."

# Show usage instructions
if [[ $BUILD_LOCAL == true ]]; then
    current_os=$(uname -s | tr '[:upper:]' '[:lower:]')
    if [[ $current_os == *"mingw"* ]]; then
        current_os="windows"
    fi
    
    if [[ $current_os == "windows" ]]; then
        print_status "To run locally: ./build/cursor-vip_${current_os}_*.exe"
    else
        print_status "To run locally: ./build/cursor-vip_${current_os}_*"
    fi
fi
