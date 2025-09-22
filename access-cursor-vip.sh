#!/bin/bash

# Interactive Cursor VIP Access Script
# This script allows you to interact with cursor-vip running on the server

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
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  interactive    Start interactive session with cursor-vip"
    echo "  logs           Show cursor-vip logs"
    echo "  status         Show service status"
    echo "  restart        Restart the service"
    echo "  stop           Stop the service"
    echo "  start          Start the service"
    echo "  help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 interactive    # Start interactive session"
    echo "  $0 logs          # Show logs"
    echo "  $0 status        # Show status"
}

# Function to start interactive session
start_interactive() {
    print_step "Starting interactive cursor-vip session..."
    
    # Stop the service first to run interactively
    print_status "Stopping systemd service..."
    sudo systemctl stop cursor-vip
    
    # Wait a moment
    sleep 2
    
    # Start cursor-vip interactively
    print_status "Starting cursor-vip interactively..."
    print_warning "Press Ctrl+C to stop and return to systemd service"
    
    cd /opt/cursor-vip
    sudo -u cursor-vip ./cursor-vip
    
    # Restart the service when done
    print_status "Restarting systemd service..."
    sudo systemctl start cursor-vip
}

# Function to show logs
show_logs() {
    print_step "Showing cursor-vip logs..."
    sudo journalctl -u cursor-vip -f
}

# Function to show status
show_status() {
    print_step "Cursor-vip service status:"
    sudo systemctl status cursor-vip --no-pager
}

# Function to restart service
restart_service() {
    print_step "Restarting cursor-vip service..."
    sudo systemctl restart cursor-vip
    print_status "Service restarted successfully!"
}

# Function to stop service
stop_service() {
    print_step "Stopping cursor-vip service..."
    sudo systemctl stop cursor-vip
    print_status "Service stopped successfully!"
}

# Function to start service
start_service() {
    print_step "Starting cursor-vip service..."
    sudo systemctl start cursor-vip
    print_status "Service started successfully!"
}

# Parse command line arguments
COMMAND=""
if [[ $# -gt 0 ]]; then
    COMMAND="$1"
else
    COMMAND="interactive"
fi

# Commands
case "$COMMAND" in
    interactive)
        start_interactive
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    restart)
        restart_service
        ;;
    stop)
        stop_service
        ;;
    start)
        start_service
        ;;
    help|--help|-h)
        show_usage
        exit 0
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        show_usage
        exit 1
        ;;
esac

print_status "Done!"
