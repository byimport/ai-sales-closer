# Deployment Guide - AI Sales Closer

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Local Testing](#local-testing)
3. [Docker Deployment](#docker-deployment)
4. [Cloud Deployment (Netlify)](#cloud-deployment-netlify)
5. [Cloud Deployment (Vercel)](#cloud-deployment-vercel)
6. [Database Setup](#database-setup)
7. [Verification Steps](#verification-steps)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software
- Node.js v18.0.0 or higher
- npm v9.0.0 or higher
- Git latest version
- Docker (for Docker deployment)

### Required Accounts
- GitHub account with access to repository
- Netlify account (for Netlify deployment)
- Vercel account (for Vercel deployment)
- PostgreSQL or similar database provider

### Environment Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/ai-sales-closer.git
cd ai-sales-closer

# Install dependencies
npm install

# Copy environment template
cp .env.example .env.production
```

## Local Testing

### Step 1: Install Dependencies
```bash
npm install
```

### Step 2: Set Up Environment Variables
```bash
# Create .env.production file
cat > .env.production << 'EOF'
NODE_ENV=production
DATABASE_URL=postgresql://user:password@localhost:5432/ai_sales_closer
API_PORT=3000
LOG_LEVEL=info
CORS_ORIGIN=http://localhost:3000
EOF
```

### Step 3: Run Tests
```bash
# Run all tests
npm run test

# Run with coverage
npm run test:coverage

# Run specific test file
npm run test -- path/to/test.ts
```

### Step 4: Run Linter
```bash
npm run lint
npm run lint:fix  # To auto-fix issues
```

### Step 5: Build Project
```bash
npm run build
```

### Step 6: Start Local Server
```bash
# Development mode
npm run dev

# Production mode
npm run start
```

### Step 7: Verify Local Deployment
```bash
# Check if server is running
curl http://localhost:3000/health

# Expected response
# {"status": "ok"}
```

## Docker Deployment

### Step 1: Build Docker Image
```bash
# Using the deploy script
./scripts/deploy-docker.sh build

# Or manually
docker build -t ai-sales-closer:latest .
docker build -t ai-sales-closer:v1.0.0 .
```

### Step 2: Run Docker Container
```bash
# Using the deploy script
./scripts/deploy-docker.sh run

# Or manually
docker run -d \
  --name ai-sales-closer \
  -p 3000:3000 \
  --env-file .env.production \
  ai-sales-closer:latest
```

### Step 3: Verify Docker Container
```bash
# Check if container is running
docker ps | grep ai-sales-closer

# Check logs
docker logs ai-sales-closer

# Test endpoint
curl http://localhost:3000/health
```

### Step 4: Push to Registry (Optional)
```bash
# Tag image
docker tag ai-sales-closer:latest docker.io/yourusername/ai-sales-closer:latest

# Push to registry
docker push docker.io/yourusername/ai-sales-closer:latest
```

## Cloud Deployment (Netlify)

### Step 1: Connect Repository
1. Log in to [Netlify](https://netlify.com)
2. Click "New site from Git"
3. Select GitHub repository
4. Authorize Netlify

### Step 2: Configure Build Settings
```
Build command: npm run build
Publish directory: dist
Node version: 18.x
```

### Step 3: Set Environment Variables
```
NODE_ENV=production
DATABASE_URL=your_production_database_url
API_PORT=3000
LOG_LEVEL=info
```

### Step 4: Deploy Using Script
```bash
./scripts/deploy-netlify.sh
```

### Step 5: Verify Deployment
```bash
# Check deployment status
netlify status

# View logs
netlify logs
```

## Cloud Deployment (Vercel)

### Step 1: Connect Repository
1. Log in to [Vercel](https://vercel.com)
2. Click "Import Project"
3. Select GitHub repository
4. Authorize Vercel

### Step 2: Configure Project Settings
```
Framework: Node.js
Build command: npm run build
Output directory: dist
```

### Step 3: Set Environment Variables
1. Go to Project Settings > Environment Variables
2. Add variables:
   - `NODE_ENV=production`
   - `DATABASE_URL=your_production_database_url`
   - `API_PORT=3000`
   - `LOG_LEVEL=info`

### Step 4: Deploy Using Script
```bash
./scripts/deploy-vercel.sh
```

### Step 5: Verify Deployment
```bash
# Check deployment status
vercel status

# View logs
vercel logs
```

## Database Setup

### Step 1: Create Database
```bash
# Using PostgreSQL
createdb ai_sales_closer
```

### Step 2: Run Migrations
```bash
npm run migrate
npm run migrate:up
```

### Step 3: Seed Database (Optional)
```bash
npm run seed
```

### Step 4: Verify Database
```bash
# Check connection
npm run db:test

# Check schema
npm run db:schema
```

## Verification Steps

### 1. Health Check
```bash
curl -s http://your-app-url/health | jq .
```

### 2. Database Connection
```bash
# Via API endpoint
curl -s http://your-app-url/api/health | jq .

# Via CLI
npm run db:test
```

### 3. API Endpoints
```bash
# Test authentication
curl -X POST http://your-app-url/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}'

# Test sales data endpoint
curl -X GET http://your-app-url/api/sales \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 4. Performance Check
```bash
# Load test (using ab or similar)
ab -n 100 -c 10 http://your-app-url/

# View metrics
curl http://your-app-url/metrics
```

### 5. Log Verification
```bash
# For local deployment
tail -f logs/production.log

# For Docker deployment
docker logs -f ai-sales-closer

# For cloud deployment (Netlify)
netlify logs

# For cloud deployment (Vercel)
vercel logs
```

## Troubleshooting

### Application won't start
```bash
# Check if port is already in use
lsof -i :3000

# Kill existing process
kill -9 <PID>

# Check Node version
node --version

# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Database connection failed
```bash
# Check DATABASE_URL format
echo $DATABASE_URL

# Test connection
npm run db:test

# Check database is running
psql -h localhost -U user -d ai_sales_closer -c "SELECT 1"
```

### Docker issues
```bash
# Check Docker is running
docker --version

# Remove old containers
docker rm ai-sales-closer

# Remove old images
docker rmi ai-sales-closer:latest

# Check logs
docker logs ai-sales-closer

# Rebuild image
docker build --no-cache -t ai-sales-closer:latest .
```

### Build failures
```bash
# Clear build cache
npm run clean

# Rebuild
npm run build

# Check for TypeScript errors
npm run tsc

# Check for ESLint errors
npm run lint
```

### Performance issues
```bash
# Monitor resource usage
npm run monitor

# Profile application
npm run profile

# Check database performance
npm run db:analyze
```

## Rollback Procedure

If deployment fails:

```bash
# Rollback to previous version
git revert HEAD
git push origin main

# For Docker
docker stop ai-sales-closer
docker run -d --name ai-sales-closer ... ai-sales-closer:previous-tag

# For Netlify
netlify deploy --alias=rollback

# For Vercel
vercel promote <previous-deployment-id>
```

## Post-Deployment

1. Monitor application in first 24 hours
2. Check error rates and performance metrics
3. Verify all features working correctly
4. Monitor database performance
5. Collect feedback from users
6. Update documentation if needed
