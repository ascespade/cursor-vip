#!/bin/bash

# Docker Deployment Script for cursor-vip
# This script builds and deploys the application using Docker

set -e

# Configuration
IMAGE_NAME="${IMAGE_NAME:-cursor-vip}"
TAG="${TAG:-latest}"
REGISTRY="${REGISTRY:-}"
CONTAINER_NAME="${CONTAINER_NAME:-cursor-vip}"
PORT="${PORT:-8080}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build                 Build Docker image"
    echo "  run                   Run container locally"
    echo "  stop                  Stop running container"
    echo "  restart               Restart container"
    echo "  logs                  Show container logs"
    echo "  shell                 Open shell in container"
    echo "  push                  Push image to registry"
    echo "  compose-up            Start with docker-compose"
    echo "  compose-down          Stop docker-compose services"
    echo "  compose-logs          Show docker-compose logs"
    echo "  clean                 Clean up containers and images"
    echo ""
    echo "Options:"
    echo "  -t, --tag TAG         Image tag (default: latest)"
    echo "  -r, --registry REG    Registry URL"
    echo "  -p, --port PORT       Port mapping (default: 8080)"
    echo "  -n, --name NAME       Container name (default: cursor-vip)"
    echo "  --help                Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  IMAGE_NAME            Docker image name"
    echo "  TAG                   Image tag"
    echo "  REGISTRY              Registry URL"
    echo "  CONTAINER_NAME        Container name"
    echo "  PORT                  Port mapping"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 run -p 8080:8080"
    echo "  $0 push -r myregistry.com -t v1.0.0"
    echo "  $0 compose-up"
}

# Parse command line arguments
COMMAND=""
while [[ $# -gt 0 ]]; do
    case $1 in
        build|run|stop|restart|logs|shell|push|compose-up|compose-down|compose-logs|clean)
            COMMAND="$1"
            shift
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -n|--name)
            CONTAINER_NAME="$2"
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

# Check required tools
if ! command_exists docker; then
    print_error "Docker is not installed."
    exit 1
fi

# Build full image name
if [[ -n "$REGISTRY" ]]; then
    FULL_IMAGE_NAME="$REGISTRY/$IMAGE_NAME:$TAG"
else
    FULL_IMAGE_NAME="$IMAGE_NAME:$TAG"
fi

# Commands
case "$COMMAND" in
    build)
        print_step "Building Docker image..."
        print_status "Image: $FULL_IMAGE_NAME"
        docker build -t "$FULL_IMAGE_NAME" .
        print_status "Build completed successfully!"
        ;;
    
    run)
        print_step "Running container..."
        print_status "Container: $CONTAINER_NAME"
        print_status "Port: $PORT"
        
        # Stop existing container if running
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            print_warning "Stopping existing container..."
            docker stop "$CONTAINER_NAME"
        fi
        
        # Remove existing container
        if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
            print_warning "Removing existing container..."
            docker rm "$CONTAINER_NAME"
        fi
        
        # Run new container
        docker run -d \
            --name "$CONTAINER_NAME" \
            -p "$PORT:8080" \
            --restart unless-stopped \
            "$FULL_IMAGE_NAME"
        
        print_status "Container started successfully!"
        print_status "Access the application at: http://localhost:$PORT"
        ;;
    
    stop)
        print_step "Stopping container..."
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            docker stop "$CONTAINER_NAME"
            print_status "Container stopped successfully!"
        else
            print_warning "Container is not running."
        fi
        ;;
    
    restart)
        print_step "Restarting container..."
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            docker restart "$CONTAINER_NAME"
            print_status "Container restarted successfully!"
        else
            print_warning "Container is not running. Starting new container..."
            $0 run
        fi
        ;;
    
    logs)
        print_step "Showing container logs..."
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            docker logs -f "$CONTAINER_NAME"
        else
            print_warning "Container is not running."
        fi
        ;;
    
    shell)
        print_step "Opening shell in container..."
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            docker exec -it "$CONTAINER_NAME" /bin/sh
        else
            print_warning "Container is not running."
        fi
        ;;
    
    push)
        print_step "Pushing image to registry..."
        if [[ -z "$REGISTRY" ]]; then
            print_error "Registry is required for push command."
            exit 1
        fi
        docker push "$FULL_IMAGE_NAME"
        print_status "Image pushed successfully!"
        ;;
    
    compose-up)
        print_step "Starting services with docker-compose..."
        if ! command_exists docker-compose; then
            print_error "docker-compose is not installed."
            exit 1
        fi
        docker-compose -f "$COMPOSE_FILE" up -d
        print_status "Services started successfully!"
        ;;
    
    compose-down)
        print_step "Stopping docker-compose services..."
        if ! command_exists docker-compose; then
            print_error "docker-compose is not installed."
            exit 1
        fi
        docker-compose -f "$COMPOSE_FILE" down
        print_status "Services stopped successfully!"
        ;;
    
    compose-logs)
        print_step "Showing docker-compose logs..."
        if ! command_exists docker-compose; then
            print_error "docker-compose is not installed."
            exit 1
        fi
        docker-compose -f "$COMPOSE_FILE" logs -f
        ;;
    
    clean)
        print_step "Cleaning up containers and images..."
        
        # Stop and remove container
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            docker stop "$CONTAINER_NAME"
        fi
        if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
            docker rm "$CONTAINER_NAME"
        fi
        
        # Remove image
        if docker images -q "$IMAGE_NAME" | grep -q .; then
            docker rmi "$FULL_IMAGE_NAME"
        fi
        
        print_status "Cleanup completed successfully!"
        ;;
    
    *)
        print_error "Unknown command: $COMMAND"
        show_usage
        exit 1
        ;;
esac

print_status "Done!"
