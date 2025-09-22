#!/bin/bash

# Local Development Runner for cursor-vip
# This script runs the application locally for development purposes

set -e

echo "Starting cursor-vip in local development mode..."

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Error: Go is not installed. Please install Go 1.23+ first."
    exit 1
fi

# Check Go version
GO_VERSION=$(go version | grep -o 'go[0-9]\+\.[0-9]\+' | sed 's/go//')
REQUIRED_VERSION="1.23"
if ! printf '%s\n%s\n' "$REQUIRED_VERSION" "$GO_VERSION" | sort -V -C; then
    echo "Error: Go version $GO_VERSION is too old. Please install Go $REQUIRED_VERSION or newer."
    exit 1
fi

# Install dependencies if go.mod is newer than go.sum
if [ go.mod -nt go.sum ] || [ ! -f go.sum ]; then
    echo "Installing dependencies..."
    go mod tidy
    go mod download
fi

# Check if garble is installed (for obfuscation)
if ! command -v garble &> /dev/null; then
    echo "Installing garble for code obfuscation..."
    go install mvdan.cc/garble@latest
fi

# Check if rsrc is installed (for Windows icon embedding)
if ! command -v rsrc &> /dev/null; then
    echo "Installing rsrc for Windows icon embedding..."
    go install github.com/akavel/rsrc@latest
fi

# Create build directory if it doesn't exist
mkdir -p build

# Determine current platform
OS_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH_NAME=$(uname -m)

case "$ARCH_NAME" in
    "amd64"|"x86_64")
        ARCH_NAME="amd64"
        ;;
    "arm64"|"aarch64")
        ARCH_NAME="arm64"
        ;;
    "i686")
        ARCH_NAME="386"
        ;;
    *)
        echo "Warning: Unsupported architecture $ARCH_NAME, using amd64"
        ARCH_NAME="amd64"
        ;;
esac

# Build for current platform
echo "Building for $OS_NAME $ARCH_NAME..."

if [[ $OS_NAME == "windows" ]]; then
    # Windows build with icon
    if [ -f rsrc.ico ]; then
        rsrc -arch amd64 -ico rsrc.ico -o rsrc.syso
        GOOS=windows GOARCH=$ARCH_NAME CGO_ENABLED=0 go build -ldflags "-s -w" -o build/cursor-vip_local.exe
        rm -f rsrc.syso
    else
        GOOS=windows GOARCH=$ARCH_NAME CGO_ENABLED=0 go build -ldflags "-s -w" -o build/cursor-vip_local.exe
    fi
    chmod +x build/cursor-vip_local.exe
    echo "Build complete: build/cursor-vip_local.exe"
    echo "Run with: ./build/cursor-vip_local.exe"
else
    # Unix-like systems (Linux, macOS)
    if [[ $OS_NAME == "darwin" ]]; then
        # macOS build with obfuscation
        GOOS=darwin GOARCH=$ARCH_NAME CGO_ENABLED=0 garble -literals -tiny build -ldflags "-w -s" -o build/cursor-vip_local
    else
        # Linux build with obfuscation
        GOOS=linux GOARCH=$ARCH_NAME CGO_ENABLED=0 garble -literals -tiny build -ldflags "-w -s" -o build/cursor-vip_local
    fi
    chmod +x build/cursor-vip_local
    echo "Build complete: build/cursor-vip_local"
    echo "Run with: ./build/cursor-vip_local"
fi

# Ask if user wants to run immediately
read -p "Do you want to run the application now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ $OS_NAME == "windows" ]]; then
        ./build/cursor-vip_local.exe
    else
        ./build/cursor-vip_local
    fi
else
    echo "Build completed. You can run it manually later."
fi
