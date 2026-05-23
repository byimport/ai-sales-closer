# Quick Start Deployment - AI Sales Closer

## 5-Minute Docker Deployment

```bash
# 1. Build image
./scripts/deploy-docker.sh build

# 2. Run container
./scripts/deploy-docker.sh run

# 3. Verify
curl http://localhost:3000/health
```

## 10-Minute Netlify Deployment

```bash
# 1. Ensure all changes are committed
git add .
git commit -m "Ready for production"
git push

# 2. Run deployment script
./scripts/deploy-netlify.sh

# 3. Verify deployment
netlify status
```

## 10-Minute Vercel Deployment

```bash
# 1. Ensure all changes are committed
git add .
git commit -m "Ready for production"
git push

# 2. Run deployment script
./scripts/deploy-vercel.sh

# 3. Verify deployment
vercel status
```

## Environment Setup (2 minutes)

```bash
# Create environment file
./scripts/setup-env.sh

# Or manually
cp .env.example .env.production
# Edit .env.production with your values
```

## Pre-Deployment Checks (2 minutes)

```bash
# Run tests
npm run test

# Check linting
npm run lint

# Build
npm run build
```

## Health Check

```bash
# Local
curl http://localhost:3000/health

# Remote (replace URL)
curl https://your-app-url/health
```

## Rollback (1 minute)

```bash
# Docker
docker stop ai-sales-closer
docker run -d --name ai-sales-closer ... ai-sales-closer:previous-tag

# Netlify
netlify rollback

# Vercel
vercel promote <previous-deployment>
```

## Important URLs

- **Repository**: https://github.com/yourusername/ai-sales-closer
- **Netlify**: https://app.netlify.com
- **Vercel**: https://vercel.com
- **Docker Hub**: https://hub.docker.com

## Critical Commands

```bash
# Logs
docker logs ai-sales-closer              # Docker logs
netlify logs                              # Netlify logs
vercel logs                               # Vercel logs

# Database
npm run migrate                           # Run migrations
npm run db:test                          # Test connection

# Monitoring
npm run monitor                          # Monitor application
npm run profile                          # Profile application
```

## Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Port already in use | `lsof -i :3000 && kill -9 <PID>` |
| Database connection failed | Check `DATABASE_URL` env var |
| Docker not found | Install Docker Desktop |
| Build failed | `npm install && npm run build` |
| Tests failing | `npm run test -- --verbose` |

## Success Criteria

- [ ] Application starts without errors
- [ ] Health endpoint responds `{"status": "ok"}`
- [ ] Database connection successful
- [ ] All API endpoints accessible
- [ ] No critical errors in logs
- [ ] Performance metrics acceptable

---

**Need help?** See DEPLOYMENT_GUIDE.md or TROUBLESHOOTING.md
