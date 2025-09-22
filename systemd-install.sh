#!/bin/bash

# Systemd Service Installation Script for cursor-vip
# This script installs and manages the cursor-vip systemd service

set -e

# Configuration
SERVICE_NAME="${SERVICE_NAME:-cursor-vip}"
SERVICE_USER="${SERVICE_USER:-cursor-vip}"
INSTALL_PATH="${INSTALL_PATH:-/opt/cursor-vip}"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

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

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  install               Install the service"
    echo "  uninstall             Uninstall the service"
    echo "  start                 Start the service"
    echo "  stop                  Stop the service"
    echo "  restart               Restart the service"
    echo "  status                Show service status"
    echo "  logs                  Show service logs"
    echo "  enable                Enable service at boot"
    echo "  disable               Disable service at boot"
    echo ""
    echo "Options:"
    echo "  -u, --user USER       Service user (default: cursor-vip)"
    echo "  -p, --path PATH       Installation path (default: /opt/cursor-vip)"
    echo "  -s, --service NAME    Service name (default: cursor-vip)"
    echo "  --help                Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  SERVICE_USER          Service user"
    echo "  INSTALL_PATH          Installation path"
    echo "  SERVICE_NAME          Service name"
    echo ""
    echo "Examples:"
    echo "  $0 install"
    echo "  $0 start"
    echo "  $0 logs"
    echo "  $0 uninstall"
}

# Parse command line arguments
COMMAND=""
while [[ $# -gt 0 ]]; do
    case $1 in
        install|uninstall|start|stop|restart|status|logs|enable|disable)
            COMMAND="$1"
            shift
            ;;
        -u|--user)
            SERVICE_USER="$2"
            shift 2
            ;;
        -p|--path)
            INSTALL_PATH="$2"
            shift 2
            ;;
        -s|--service)
            SERVICE_NAME="$2"
            shift 2
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

# Validate command
if [[ -z "$COMMAND" ]]; then
    print_error "Command is required."
    show_usage
    exit 1
fi

# Commands
case "$COMMAND" in
    install)
        print_step "Installing cursor-vip systemd service..."
        check_root
        
        # Create service user if it doesn't exist
        if ! id "$SERVICE_USER" &>/dev/null; then
            print_status "Creating service user: $SERVICE_USER"
            useradd --system --no-create-home --shell /bin/false "$SERVICE_USER"
        fi
        
        # Create installation directory
        print_status "Creating installation directory: $INSTALL_PATH"
        mkdir -p "$INSTALL_PATH"
        
        # Copy service file
        print_status "Installing service file: $SERVICE_FILE"
        cp cursor-vip.service "$SERVICE_FILE"
        
        # Update service file with actual paths and user
        sed -i "s|/opt/cursor-vip|$INSTALL_PATH|g" "$SERVICE_FILE"
        sed -i "s|cursor-vip|$SERVICE_USER|g" "$SERVICE_FILE"
        
        # Set ownership
        chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_PATH"
        
        # Reload systemd
        print_status "Reloading systemd daemon..."
        systemctl daemon-reload
        
        # Enable service
        print_status "Enabling service..."
        systemctl enable "$SERVICE_NAME"
        
        print_status "Service installed successfully!"
        print_status "To start the service, run: $0 start"
        print_status "To check status, run: $0 status"
        ;;
    
    uninstall)
        print_step "Uninstalling cursor-vip systemd service..."
        check_root
        
        # Stop and disable service
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            print_status "Stopping service..."
            systemctl stop "$SERVICE_NAME"
        fi
        
        if systemctl is-enabled --quiet "$SERVICE_NAME"; then
            print_status "Disabling service..."
            systemctl disable "$SERVICE_NAME"
        fi
        
        # Remove service file
        if [[ -f "$SERVICE_FILE" ]]; then
            print_status "Removing service file..."
            rm "$SERVICE_FILE"
        fi
        
        # Reload systemd
        systemctl daemon-reload
        
        print_status "Service uninstalled successfully!"
        print_warning "Note: Application files in $INSTALL_PATH are not removed."
        print_warning "To remove them, run: rm -rf $INSTALL_PATH"
        ;;
    
    start)
        print_step "Starting service..."
        check_root
        systemctl start "$SERVICE_NAME"
        print_status "Service started successfully!"
        ;;
    
    stop)
        print_step "Stopping service..."
        check_root
        systemctl stop "$SERVICE_NAME"
        print_status "Service stopped successfully!"
        ;;
    
    restart)
        print_step "Restarting service..."
        check_root
        systemctl restart "$SERVICE_NAME"
        print_status "Service restarted successfully!"
        ;;
    
    status)
        print_step "Service status:"
        systemctl status "$SERVICE_NAME" --no-pager
        ;;
    
    logs)
        print_step "Service logs:"
        journalctl -u "$SERVICE_NAME" -f
        ;;
    
    enable)
        print_step "Enabling service at boot..."
        check_root
        systemctl enable "$SERVICE_NAME"
        print_status "Service enabled successfully!"
        ;;
    
    disable)
        print_step "Disabling service at boot..."
        check_root
        systemctl disable "$SERVICE_NAME"
        print_status "Service disabled successfully!"
        ;;
    
    *)
        print_error "Unknown command: $COMMAND"
        show_usage
        exit 1
        ;;
esac

print_status "Done!"
