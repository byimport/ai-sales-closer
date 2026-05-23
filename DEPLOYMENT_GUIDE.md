# AI Sales Closer - Guide de Déploiement Complet

## Table des Matières
1. [Vue d'ensemble](#vue-densemble)
2. [Pré-requis](#pré-requis)
3. [Préparation](#préparation)
4. [Déploiement Docker](#déploiement-docker)
5. [Déploiement Netlify](#déploiement-netlify)
6. [Déploiement Vercel](#déploiement-vercel)
7. [Post-déploiement](#post-déploiement)
8. [Dépannage](#dépannage)

## Vue d'ensemble

AI Sales Closer est une application Node.js/TypeScript avec une base de données PostgreSQL. Elle peut être déployée sur Docker, Netlify, ou Vercel.

**Architecture:**
- Frontend: Next.js
- Backend: Node.js avec Express
- Base de données: PostgreSQL
- Runtime: Node.js 18+

## Pré-requis

### Pour tous les déploiements
- Node.js 18+
- npm 8+
- Git
- Compte GitHub

### Pour Docker
- Docker Desktop 4.0+
- Docker Compose 2.0+

### Pour Netlify
- Compte Netlify
- Netlify CLI (`npm install -g netlify-cli`)

### Pour Vercel
- Compte Vercel
- Vercel CLI (`npm install -g vercel`)

### Authentification
- GitHub token pour les déploiements automatisés
- PostgreSQL credentials
- Variables d'environnement sensibles

## Préparation

### 1. Vérifier l'état du code
```bash
cd /home/user/ai-sales-closer
git status
git log --oneline -5
npm run lint
npm run type-check
npm run build
npm run test
```

### 2. Préparer les variables d'environnement
```bash
cp .env.example .env.production
# Éditer .env.production avec vos valeurs
```

**Variables requises:**
```
NODE_ENV=production
DATABASE_URL=postgresql://user:password@host:port/dbname
OPENAI_API_KEY=sk-...
JWT_SECRET=your-secret-key
NEXT_PUBLIC_API_URL=https://your-api-domain.com
LOG_LEVEL=info
```

### 3. Préserver les données
```bash
# Backup base de données
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d-%H%M%S).sql
```

## Déploiement Docker

### Build de l'image Docker
```bash
./scripts/deploy-docker.sh build
```

### Exécuter le conteneur
```bash
./scripts/deploy-docker.sh run
```

### Vérifier le déploiement
```bash
curl http://localhost:3000/api/health
```

## Déploiement Netlify

### Configuration Netlify
```bash
./scripts/deploy-netlify.sh setup
```

### Déployer sur Netlify
```bash
./scripts/deploy-netlify.sh deploy
```

### URL de production
```
https://ai-sales-closer.netlify.app
```

## Déploiement Vercel

### Configuration Vercel
```bash
./scripts/deploy-vercel.sh setup
```

### Déployer sur Vercel
```bash
./scripts/deploy-vercel.sh deploy
```

### URL de production
```
https://ai-sales-closer.vercel.app
```

## Post-déploiement

### Tests de santé
```bash
# Health check
curl https://api.yourdomain.com/api/health

# Smoke tests
npm run test:smoke

# E2E tests
npm run test:e2e
```

### Vérifications
- Accès API fonctionnel
- Base de données connectée
- Variables d'environnement correctes
- Logs sans erreurs
- Performance acceptable

### Monitoring
- Active Application Insights/Datadog
- Configure alertes
- Vérifie les métriques
- Monitor les erreurs

## Dépannage

### Erreur de connexion à la base de données
```bash
# Vérifier la DATABASE_URL
echo $DATABASE_URL

# Tester la connexion
psql $DATABASE_URL -c "SELECT 1"
```

### Build Docker échoue
```bash
# Nettoyer le build
docker builder prune

# Reconstruire avec verbosité
docker build --progress=plain .
```

### Déploiement Netlify échoue
```bash
# Vérifier la configuration
netlify status

# Voir les logs
netlify log
```

### Déploiement Vercel échoue
```bash
# Vérifier la configuration
vercel env list

# Voir les logs
vercel logs
```

## Rollback

### Docker
```bash
docker pull previous-tag
docker run -d previous-tag
```

### Netlify
```bash
netlify deploy --restore
```

### Vercel
```bash
vercel rollback
```

## Support

- Documentation: `/docs`
- Issues: GitHub Issues
- Support email: support@ai-sales-closer.com
