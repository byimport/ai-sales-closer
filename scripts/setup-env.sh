#!/bin/bash

# AI Sales Closer - Environment Setup Script
# Usage: ./scripts/setup-env.sh

set -e

echo "AI Sales Closer - Environment Setup"
echo "===================================="
echo ""

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo "Creating .env.production file..."
    cp .env.example .env.production 2>/dev/null || cat > .env.production << 'ENVEOF'
# Application
NODE_ENV=production
APP_NAME=AI Sales Closer
APP_VERSION=1.0.0

# Server
HOST=0.0.0.0
PORT=3000
LOG_LEVEL=info

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/ai_sales_closer
DB_MAX_CONNECTIONS=20
DB_TIMEOUT=10000

# Authentication
JWT_SECRET=your-jwt-secret-key-change-this
JWT_EXPIRE=7d
SESSION_SECRET=your-session-secret-key-change-this

# API Keys
OPENAI_API_KEY=sk-your-openai-key-here
STRIPE_API_KEY=sk_live_your-stripe-key-here
STRIPE_WEBHOOK_SECRET=whsec_your-webhook-secret

# URLs
NEXT_PUBLIC_API_URL=https://api.yourdomain.com
NEXT_PUBLIC_APP_URL=https://yourdomain.com
CALLBACK_URL=https://yourdomain.com/auth/callback

# Mail Service (optional)
MAIL_PROVIDER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# External Services
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
SENTRY_DSN=https://your-sentry-dsn
DATADOG_API_KEY=your-datadog-api-key

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_TRACKING=true
ENABLE_SUPPORT_CHAT=true

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Cache
REDIS_URL=redis://localhost:6379
CACHE_TTL=3600
ENVEOF
    echo "✅ .env.production created"
else
    echo "✅ .env.production already exists"
fi

# Check required environment variables
echo ""
echo "Checking environment variables..."

REQUIRED_VARS=(
    "NODE_ENV"
    "DATABASE_URL"
    "JWT_SECRET"
    "OPENAI_API_KEY"
)

MISSING_VARS=()
for var in "${REQUIRED_VARS[@]}"; do
    if ! grep -q "^${var}=" .env.production 2>/dev/null; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo "⚠️  Missing required variables:"
    printf '   - %s\n' "${MISSING_VARS[@]}"
    echo ""
    echo "Please edit .env.production and add these variables"
else
    echo "✅ All required variables are present"
fi

# Create necessary directories
echo ""
echo "Creating directories..."
mkdir -p logs
mkdir -p tmp
mkdir -p uploads
mkdir -p backups
echo "✅ Directories created"

# Verify Node.js version
echo ""
echo "Checking Node.js version..."
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js 18+ required, found $(node -v)"
    exit 1
fi
echo "✅ Node.js $(node -v) is compatible"

# Verify npm
echo "Checking npm..."
npm -v > /dev/null 2>&1
echo "✅ npm $(npm -v) is installed"

# Install dependencies
echo ""
echo "Installing dependencies..."
npm install
echo "✅ Dependencies installed"

# Run migrations
echo ""
echo "Running database migrations..."
if npm run migrate 2>/dev/null; then
    echo "✅ Migrations completed"
else
    echo "⚠️  Could not run migrations (database may not be accessible)"
    echo "   This is OK - run 'npm run migrate' after database is ready"
fi

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and update .env.production with your values"
echo "2. Run: npm run build"
echo "3. Run: ./scripts/deploy-docker.sh build"
echo "4. Run: ./scripts/deploy-docker.sh run"
