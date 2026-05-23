#!/bin/bash

# AI Sales Closer - Docker Deployment Script
# This script handles building and running Docker containers for the application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="ai-sales-closer"
IMAGE_NAME="${APP_NAME}:latest"
CONTAINER_NAME="${APP_NAME}"
PORT="3000"
ENV_FILE=".env.production"

# Functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_success "Docker is installed"
}

# Check if Docker daemon is running
check_docker_daemon() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    print_success "Docker daemon is running"
}

# Check environment file
check_env() {
    if [ ! -f "$ENV_FILE" ]; then
        print_warning "Environment file $ENV_FILE not found"
        print_info "Creating $ENV_FILE from template..."

        if [ -f ".env.example" ]; then
            cp .env.example "$ENV_FILE"
            print_warning "Please update $ENV_FILE with your configuration"
        else
            print_error "No .env.example template found. Please create $ENV_FILE manually."
            exit 1
        fi
    fi
    print_success "Environment file found: $ENV_FILE"
}

# Build Docker image
build_image() {
    print_info "Building Docker image: $IMAGE_NAME"

    if docker build -t "$IMAGE_NAME" .; then
        print_success "Docker image built successfully"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
}

# Check if container is running
is_container_running() {
    docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"
}

# Stop existing container
stop_container() {
    if is_container_running; then
        print_info "Stopping existing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME"
        docker rm "$CONTAINER_NAME"
        print_success "Container stopped and removed"
    fi
}

# Run Docker container
run_container() {
    print_info "Starting Docker container: $CONTAINER_NAME"

    if docker run -d \
        --name "$CONTAINER_NAME" \
        -p "$PORT:3000" \
        --env-file "$ENV_FILE" \
        --restart unless-stopped \
        --log-driver json-file \
        --log-opt max-size=10m \
        --log-opt max-file=3 \
        "$IMAGE_NAME"; then

        print_success "Container started successfully"
        print_info "Container is running on port $PORT"

        # Wait for container to be healthy
        sleep 2

        # Check if container is still running
        if is_container_running; then
            print_success "Container is healthy"
        else
            print_error "Container failed to start"
            docker logs "$CONTAINER_NAME"
            exit 1
        fi
    else
        print_error "Failed to run Docker container"
        exit 1
    fi
}

# Test container
test_container() {
    print_info "Testing container..."

    for i in {1..5}; do
        if curl -s http://localhost:$PORT/health > /dev/null 2>&1; then
            print_success "Health check passed"
            curl -s http://localhost:$PORT/health | jq . 2>/dev/null || echo "OK"
            return 0
        fi

        if [ $i -lt 5 ]; then
            print_warning "Health check attempt $i/5 failed, retrying..."
            sleep 1
        fi
    done

    print_error "Health check failed after 5 attempts"
    print_info "Container logs:"
    docker logs "$CONTAINER_NAME"
    exit 1
}

# View logs
view_logs() {
    print_info "Displaying container logs..."
    docker logs -f "$CONTAINER_NAME"
}

# Clean up
cleanup() {
    print_info "Cleaning up..."

    # Remove stopped containers
    docker container prune -f > /dev/null 2>&1

    # Remove unused images
    docker image prune -f > /dev/null 2>&1

    print_success "Cleanup completed"
}

# Main script logic
main() {
    local action="${1:-build}"

    case "$action" in
        build)
            print_info "=== Building Docker Image ==="
            check_docker
            check_docker_daemon
            build_image
            print_success "Build completed successfully"
            ;;

        run)
            print_info "=== Running Docker Container ==="
            check_docker
            check_docker_daemon
            check_env
            stop_container
            run_container
            test_container
            print_success "Deployment completed successfully!"
            print_info "Access your application at http://localhost:$PORT"
            ;;

        deploy)
            print_info "=== Full Deployment (Build + Run) ==="
            check_docker
            check_docker_daemon
            check_env
            build_image
            stop_container
            run_container
            test_container
            print_success "Deployment completed successfully!"
            print_info "Access your application at http://localhost:$PORT"
            ;;

        stop)
            print_info "=== Stopping Container ==="
            stop_container
            print_success "Container stopped"
            ;;

        restart)
            print_info "=== Restarting Container ==="
            stop_container
            run_container
            test_container
            print_success "Container restarted"
            ;;

        logs)
            view_logs
            ;;

        logs-short)
            docker logs "$CONTAINER_NAME" --tail 50
            ;;

        clean)
            cleanup
            ;;

        status)
            print_info "=== Container Status ==="
            if is_container_running; then
                print_success "Container is running"
                docker ps --filter "name=$CONTAINER_NAME"
            else
                print_warning "Container is not running"
            fi
            ;;

        *)
            echo "Usage: $0 {build|run|deploy|stop|restart|logs|logs-short|clean|status}"
            echo ""
            echo "Commands:"
            echo "  build        - Build Docker image"
            echo "  run          - Run Docker container (build if needed)"
            echo "  deploy       - Full deployment (build + run)"
            echo "  stop         - Stop running container"
            echo "  restart      - Restart container"
            echo "  logs         - View live container logs"
            echo "  logs-short   - View last 50 lines of logs"
            echo "  clean        - Clean up unused containers and images"
            echo "  status       - Show container status"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
