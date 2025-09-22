#!/bin/bash

# Remote Server Deployment Script for cursor-vip
# This script deploys the application to a remote server

set -e

# Configuration
REMOTE_USER="${REMOTE_USER:-root}"
REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_PORT="${REMOTE_PORT:-22}"
REMOTE_PATH="${REMOTE_PATH:-/opt/cursor-vip}"
SERVICE_NAME="${SERVICE_NAME:-cursor-vip}"
BUILD_PLATFORM="${BUILD_PLATFORM:-linux/amd64}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --host HOST        Remote server hostname or IP"
    echo "  -u, --user USER        Remote username (default: root)"
    echo "  -p, --port PORT        SSH port (default: 22)"
    echo "  -d, --path PATH        Remote deployment path (default: /opt/cursor-vip)"
    echo "  -s, --service NAME     Systemd service name (default: cursor-vip)"
    echo "  -b, --build PLATFORM  Build platform (default: linux/amd64)"
    echo "  --build-only          Only build, don't deploy"
    echo "  --deploy-only         Only deploy, don't build"
    echo "  --help                Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  REMOTE_USER           Remote username"
    echo "  REMOTE_HOST           Remote server hostname or IP"
    echo "  REMOTE_PORT           SSH port"
    echo "  REMOTE_PATH           Remote deployment path"
    echo "  SERVICE_NAME          Systemd service name"
    echo "  BUILD_PLATFORM        Build platform"
    echo ""
    echo "Examples:"
    echo "  $0 -h 192.168.1.100 -u ubuntu"
    echo "  $0 --host myserver.com --user admin --path /home/admin/cursor-vip"
    echo "  REMOTE_HOST=myserver.com $0"
}

# Parse command line arguments
BUILD_ONLY=false
DEPLOY_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--host)
            REMOTE_HOST="$2"
            shift 2
            ;;
        -u|--user)
            REMOTE_USER="$2"
            shift 2
            ;;
        -p|--port)
            REMOTE_PORT="$2"
            shift 2
            ;;
        -d|--path)
            REMOTE_PATH="$2"
            shift 2
            ;;
        -s|--service)
            SERVICE_NAME="$2"
            shift 2
            ;;
        -b|--build)
            BUILD_PLATFORM="$2"
            shift 2
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --deploy-only)
            DEPLOY_ONLY=true
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

# Validate required parameters
if [[ -z "$REMOTE_HOST" && "$DEPLOY_ONLY" == false ]]; then
    print_error "Remote host is required. Use -h/--host or set REMOTE_HOST environment variable."
    show_usage
    exit 1
fi

# Check required tools
if ! command_exists go; then
    print_error "Go is not installed. Please install Go 1.23+ first."
    exit 1
fi

if ! command_exists ssh; then
    print_error "SSH client is not installed."
    exit 1
fi

if ! command_exists scp; then
    print_error "SCP is not installed."
    exit 1
fi

# Build the application
if [[ "$DEPLOY_ONLY" == false ]]; then
    print_status "Building application for $BUILD_PLATFORM..."
    
    # Install dependencies
    go mod tidy
    go mod download
    
    # Install build tools
    if ! command_exists garble; then
        print_status "Installing garble..."
        go install mvdan.cc/garble@latest
    fi
    
    # Create build directory
    mkdir -p build
    
    # Parse platform
    IFS='/' read -r GOOS GOARCH <<< "$BUILD_PLATFORM"
    
    # Build for target platform
    print_status "Building for $GOOS $GOARCH..."
    GOOS=$GOOS GOARCH=$GOARCH CGO_ENABLED=0 garble -literals -tiny build -ldflags "-w -s" -o build/cursor-vip_server
    chmod +x build/cursor-vip_server
    
    print_status "Build completed: build/cursor-vip_server"
fi

# Deploy to remote server
if [[ "$BUILD_ONLY" == false ]]; then
    print_status "Deploying to $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH..."
    
    # Test SSH connection
    print_status "Testing SSH connection..."
    if ! ssh -p "$REMOTE_PORT" -o ConnectTimeout=10 -o BatchMode=yes "$REMOTE_USER@$REMOTE_HOST" "echo 'SSH connection successful'" >/dev/null 2>&1; then
        print_error "Cannot connect to $REMOTE_USER@$REMOTE_HOST:$REMOTE_PORT"
        print_error "Please check your SSH configuration and credentials."
        exit 1
    fi
    
    # Create remote directory
    print_status "Creating remote directory..."
    ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_PATH"
    
    # Copy application
    print_status "Copying application..."
    scp -P "$REMOTE_PORT" build/cursor-vip_server "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/"
    
    # Copy systemd service file
    print_status "Installing systemd service..."
    ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST" "cat > /etc/systemd/system/$SERVICE_NAME.service << 'EOF'
[Unit]
Description=Cursor VIP Service
After=network.target

[Service]
Type=simple
User=$REMOTE_USER
WorkingDirectory=$REMOTE_PATH
ExecStart=$REMOTE_PATH/cursor-vip_server
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF"
    
    # Reload systemd and enable service
    print_status "Enabling and starting service..."
    ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST" "
        systemctl daemon-reload &&
        systemctl enable $SERVICE_NAME &&
        systemctl restart $SERVICE_NAME &&
        systemctl status $SERVICE_NAME --no-pager
    "
    
    print_status "Deployment completed successfully!"
    print_status "Service status: systemctl status $SERVICE_NAME"
    print_status "Service logs: journalctl -u $SERVICE_NAME -f"
fi

print_status "Done!"
