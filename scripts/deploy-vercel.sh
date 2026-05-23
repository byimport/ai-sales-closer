#!/bin/bash

# AI Sales Closer - Vercel Deployment Script
# This script handles deployment to Vercel

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="ai-sales-closer"
PROJECT_NAME="ai-sales-closer"

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

# Check if Vercel CLI is installed
check_vercel() {
    if ! command -v vercel &> /dev/null; then
        print_error "Vercel CLI is not installed"
        print_info "Install with: npm install -g vercel"
        exit 1
    fi
    print_success "Vercel CLI is installed"
}

# Check if user is logged in
check_auth() {
    if [ ! -d "$HOME/.vercel" ]; then
        print_warning "Not authenticated with Vercel"
        print_info "Logging in..."
        vercel login
    fi
    print_success "Vercel authentication verified"
}

# Check git status
check_git() {
    if ! git diff-index --quiet HEAD --; then
        print_warning "There are uncommitted changes"
        print_info "Commit changes before deployment"
        exit 1
    fi
    print_success "Git status is clean"
}

# Install dependencies
install_deps() {
    print_info "Installing dependencies..."
    npm install
    print_success "Dependencies installed"
}

# Run tests
run_tests() {
    print_info "Running tests..."
    npm run test
    print_success "Tests passed"
}

# Run linter
run_lint() {
    print_info "Running linter..."
    npm run lint
    print_success "Linter checks passed"
}

# Build project
build_project() {
    print_info "Building project..."
    npm run build
    print_success "Project built successfully"
}

# Deploy to Vercel
deploy_vercel() {
    print_info "Deploying to Vercel..."

    vercel --prod --yes

    print_success "Deployment to Vercel completed"
}

# Check deployment status
check_status() {
    print_info "Checking deployment status..."
    vercel inspect
}

# Test deployment
test_deployment() {
    print_info "Testing deployment..."

    DEPLOYMENT_URL=$(vercel inspect --json | jq -r '.alias[0]' 2>/dev/null || echo "")

    if [ -z "$DEPLOYMENT_URL" ]; then
        print_warning "Could not test deployment - URL not available"
        return
    fi

    for i in {1..5}; do
        if curl -s "https://$DEPLOYMENT_URL/health" > /dev/null 2>&1; then
            print_success "Health check passed"
            return 0
        fi

        if [ $i -lt 5 ]; then
            print_warning "Health check attempt $i/5 failed, retrying..."
            sleep 2
        fi
    done

    print_warning "Health check failed - deployment may need time to initialize"
}

# View logs
view_logs() {
    print_info "Displaying deployment logs..."
    vercel logs
}

# Promote deployment
promote_deployment() {
    local deployment_id="${1:-}"

    if [ -z "$deployment_id" ]; then
        print_error "Deployment ID required"
        print_info "Usage: $0 promote <deployment-id>"
        exit 1
    fi

    print_info "Promoting deployment: $deployment_id"
    vercel promote "$deployment_id"
    print_success "Deployment promoted"
}

# Main script logic
main() {
    local action="${1:-deploy}"

    case "$action" in
        install)
            print_info "=== Installing Dependencies ==="
            install_deps
            ;;

        test)
            print_info "=== Running Tests ==="
            run_tests
            ;;

        lint)
            print_info "=== Running Linter ==="
            run_lint
            ;;

        build)
            print_info "=== Building Project ==="
            build_project
            ;;

        check)
            print_info "=== Pre-Deployment Checks ==="
            check_vercel
            check_auth
            check_git
            install_deps
            run_tests
            run_lint
            build_project
            print_success "All pre-deployment checks passed"
            ;;

        deploy)
            print_info "=== Full Deployment to Vercel ==="
            check_vercel
            check_auth
            check_git
            install_deps
            run_tests
            run_lint
            build_project
            deploy_vercel
            check_status
            test_deployment
            print_success "Deployment to Vercel completed successfully!"
            ;;

        status)
            print_info "=== Deployment Status ==="
            check_vercel
            check_auth
            check_status
            ;;

        logs)
            view_logs
            ;;

        promote)
            print_info "=== Promoting Deployment ==="
            check_vercel
            check_auth
            promote_deployment "${2:-}"
            ;;

        *)
            echo "Usage: $0 {install|test|lint|build|check|deploy|status|logs|promote}"
            echo ""
            echo "Commands:"
            echo "  install    - Install dependencies"
            echo "  test       - Run tests"
            echo "  lint       - Run linter"
            echo "  build      - Build project"
            echo "  check      - Run all pre-deployment checks"
            echo "  deploy     - Full deployment (checks + build + deploy)"
            echo "  status     - Check deployment status"
            echo "  logs       - View deployment logs"
            echo "  promote    - Promote a deployment to production"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
