#!/bin/bash

# AI Sales Closer - Environment Setup Script
# This script helps set up environment variables for different environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if .env.example exists
check_example() {
    if [ ! -f ".env.example" ]; then
        print_error ".env.example file not found"
        exit 1
    fi
    print_success ".env.example found"
}

# Create development environment
setup_dev() {
    print_info "Setting up development environment..."

    cat > .env.development << 'EOF'
# Development Environment Variables
NODE_ENV=development
DEBUG=true
LOG_LEVEL=debug

# Server
API_PORT=3000
API_HOST=localhost
CORS_ORIGIN=http://localhost:3000,http://localhost:3001

# Database
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/ai_sales_closer_dev
DB_SSL=false
DB_POOL_MIN=2
DB_POOL_MAX=10

# Authentication
JWT_SECRET=dev-jwt-secret-change-in-production
REFRESH_TOKEN_SECRET=dev-refresh-secret-change-in-production
ACCESS_TOKEN_EXPIRY=15m
REFRESH_TOKEN_EXPIRY=7d

# External APIs
OPENAI_API_KEY=sk-your-dev-key-here
STRIPE_SECRET_KEY=sk_test_your_test_key
STRIPE_PUBLIC_KEY=pk_test_your_test_key

# Email
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USER=
SMTP_PASS=
SMTP_FROM=dev@example.com

# Storage
STORAGE_TYPE=local
STORAGE_PATH=./uploads

# Features
ENABLE_EMAIL=false
ENABLE_WEBHOOKS=true
ENABLE_MONITORING=false
EOF

    print_success "Development environment created: .env.development"
}

# Create production environment
setup_production() {
    print_info "Setting up production environment..."

    cat > .env.production << 'EOF'
# Production Environment Variables
NODE_ENV=production
DEBUG=false
LOG_LEVEL=info

# Server
API_PORT=3000
API_HOST=0.0.0.0
CORS_ORIGIN=https://your-domain.com

# Database
DATABASE_URL=postgresql://user:password@db-host:5432/ai_sales_closer_prod
DB_SSL=true
DB_POOL_MIN=5
DB_POOL_MAX=20

# Authentication
JWT_SECRET=change-this-to-a-secure-random-string
REFRESH_TOKEN_SECRET=change-this-to-another-secure-random-string
ACCESS_TOKEN_EXPIRY=15m
REFRESH_TOKEN_EXPIRY=7d

# External APIs
OPENAI_API_KEY=sk-your-production-key
STRIPE_SECRET_KEY=sk_live_your_live_key
STRIPE_PUBLIC_KEY=pk_live_your_live_key

# Email
SMTP_HOST=smtp.provider.com
SMTP_PORT=587
SMTP_USER=your-email@provider.com
SMTP_PASS=your-password
SMTP_FROM=noreply@your-domain.com

# Storage
STORAGE_TYPE=s3
STORAGE_BUCKET=your-bucket-name
STORAGE_REGION=us-east-1
STORAGE_ACCESS_KEY_ID=your-access-key
STORAGE_SECRET_ACCESS_KEY=your-secret-key

# Features
ENABLE_EMAIL=true
ENABLE_WEBHOOKS=true
ENABLE_MONITORING=true

# Monitoring
SENTRY_DSN=https://your-sentry-dsn
DATADOG_API_KEY=your-datadog-key
EOF

    print_warning "Production environment created: .env.production"
    print_warning "IMPORTANT: Update all placeholder values with your actual production credentials"
}

# Create staging environment
setup_staging() {
    print_info "Setting up staging environment..."

    cat > .env.staging << 'EOF'
# Staging Environment Variables
NODE_ENV=staging
DEBUG=false
LOG_LEVEL=debug

# Server
API_PORT=3000
API_HOST=0.0.0.0
CORS_ORIGIN=https://staging.your-domain.com

# Database
DATABASE_URL=postgresql://user:password@staging-db-host:5432/ai_sales_closer_staging
DB_SSL=true
DB_POOL_MIN=3
DB_POOL_MAX=15

# Authentication
JWT_SECRET=staging-jwt-secret-change-this
REFRESH_TOKEN_SECRET=staging-refresh-secret-change-this
ACCESS_TOKEN_EXPIRY=15m
REFRESH_TOKEN_EXPIRY=7d

# External APIs (Use test keys)
OPENAI_API_KEY=sk-your-staging-key
STRIPE_SECRET_KEY=sk_test_your_test_key
STRIPE_PUBLIC_KEY=pk_test_your_test_key

# Email
SMTP_HOST=smtp.provider.com
SMTP_PORT=587
SMTP_USER=staging-email@provider.com
SMTP_PASS=staging-password
SMTP_FROM=staging@your-domain.com

# Storage
STORAGE_TYPE=s3
STORAGE_BUCKET=your-staging-bucket-name
STORAGE_REGION=us-east-1
STORAGE_ACCESS_KEY_ID=your-staging-access-key
STORAGE_SECRET_ACCESS_KEY=your-staging-secret-key

# Features
ENABLE_EMAIL=true
ENABLE_WEBHOOKS=true
ENABLE_MONITORING=true

# Monitoring
SENTRY_DSN=https://your-staging-sentry-dsn
DATADOG_API_KEY=your-staging-datadog-key
EOF

    print_warning "Staging environment created: .env.staging"
    print_warning "IMPORTANT: Update all placeholder values with your actual staging credentials"
}

# Create test environment
setup_test() {
    print_info "Setting up test environment..."

    cat > .env.test << 'EOF'
# Test Environment Variables
NODE_ENV=test
DEBUG=false
LOG_LEVEL=error

# Server
API_PORT=3001
API_HOST=localhost
CORS_ORIGIN=http://localhost:3001

# Database (In-memory or test database)
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/ai_sales_closer_test
DB_SSL=false
DB_POOL_MIN=1
DB_POOL_MAX=5

# Authentication (Test keys)
JWT_SECRET=test-jwt-secret
REFRESH_TOKEN_SECRET=test-refresh-secret
ACCESS_TOKEN_EXPIRY=15m
REFRESH_TOKEN_EXPIRY=7d

# External APIs (Mock or test keys)
OPENAI_API_KEY=test-key
STRIPE_SECRET_KEY=sk_test_
STRIPE_PUBLIC_KEY=pk_test_

# Email
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USER=
SMTP_PASS=
SMTP_FROM=test@example.com

# Storage
STORAGE_TYPE=local
STORAGE_PATH=./test-uploads

# Features
ENABLE_EMAIL=false
ENABLE_WEBHOOKS=false
ENABLE_MONITORING=false
EOF

    print_success "Test environment created: .env.test"
}

# Interactive setup
setup_interactive() {
    print_info "Interactive Environment Setup"
    echo ""

    read -p "Enter Node environment (development/staging/production) [development]: " env
    env=${env:-development}

    if [ "$env" = "production" ]; then
        read -p "Enter Database URL: " db_url
        read -p "Enter JWT Secret: " jwt_secret
        read -p "Enter API Domain: " api_domain
    elif [ "$env" = "staging" ]; then
        read -p "Enter Database URL: " db_url
        read -p "Enter JWT Secret: " jwt_secret
        read -p "Enter API Domain: " api_domain
    else
        db_url="postgresql://postgres:postgres@localhost:5432/ai_sales_closer_dev"
        jwt_secret="dev-jwt-secret"
        api_domain="localhost:3000"
    fi

    cat > ".env.$env" << EOF
NODE_ENV=$env
DEBUG=true
LOG_LEVEL=debug

API_PORT=3000
API_HOST=localhost
CORS_ORIGIN=http://$api_domain

DATABASE_URL=$db_url
DB_SSL=false
DB_POOL_MIN=2
DB_POOL_MAX=10

JWT_SECRET=$jwt_secret
REFRESH_TOKEN_SECRET=refresh-secret
ACCESS_TOKEN_EXPIRY=15m
REFRESH_TOKEN_EXPIRY=7d
EOF

    print_success "Environment file created: .env.$env"
}

# Validate environment file
validate_env() {
    local env_file="${1:-.env.production}"

    if [ ! -f "$env_file" ]; then
        print_error "Environment file not found: $env_file"
        return 1
    fi

    print_info "Validating environment file: $env_file"

    local required_vars=(
        "NODE_ENV"
        "DATABASE_URL"
        "JWT_SECRET"
        "API_PORT"
    )

    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$env_file"; then
            missing_vars+=("$var")
        fi
    done

    if [ ${#missing_vars[@]} -gt 0 ]; then
        print_warning "Missing required variables in $env_file:"
        printf '%s\n' "${missing_vars[@]}"
        return 1
    fi

    print_success "All required variables found"
    return 0
}

# Show environment variables
show_env() {
    local env_file="${1:-.env.production}"

    if [ ! -f "$env_file" ]; then
        print_error "Environment file not found: $env_file"
        return 1
    fi

    print_info "Environment variables in $env_file:"
    echo ""
    grep "^[^#]" "$env_file" | grep "=" | sed 's/=.*/=***/' || true
    echo ""
}

# Main script logic
main() {
    local action="${1:-interactive}"

    case "$action" in
        dev|development)
            check_example
            setup_dev
            ;;

        prod|production)
            check_example
            setup_production
            ;;

        staging)
            check_example
            setup_staging
            ;;

        test)
            check_example
            setup_test
            ;;

        interactive|setup)
            check_example
            setup_interactive
            ;;

        validate)
            validate_env "${2:-.env.production}"
            ;;

        show)
            show_env "${2:-.env.production}"
            ;;

        all)
            check_example
            setup_dev
            echo ""
            setup_staging
            echo ""
            setup_production
            echo ""
            setup_test
            print_success "All environment files created"
            ;;

        *)
            echo "Usage: $0 {dev|production|staging|test|interactive|validate|show|all}"
            echo ""
            echo "Commands:"
            echo "  dev           - Setup development environment"
            echo "  production    - Setup production environment"
            echo "  staging       - Setup staging environment"
            echo "  test          - Setup test environment"
            echo "  interactive   - Interactive setup"
            echo "  validate      - Validate environment file"
            echo "  show          - Show environment variables (masked)"
            echo "  all           - Create all environment files"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
