# AI Sales Closer - Déploiement Rapide

## 1. Setup initial (une fois)
```bash
cd /home/user/ai-sales-closer
npm install
./scripts/setup-env.sh
```

## 2. Déploiement Docker (Recommandé)
```bash
./scripts/deploy-docker.sh build
./scripts/deploy-docker.sh run
# Vérifier: curl http://localhost:3000/api/health
```

## 3. Déploiement Netlify
```bash
./scripts/deploy-netlify.sh deploy
# Production: https://ai-sales-closer.netlify.app
```

## 4. Déploiement Vercel
```bash
./scripts/deploy-vercel.sh deploy
# Production: https://ai-sales-closer.vercel.app
```

## Commandes utiles
```bash
npm run lint       # Vérifier le code
npm run build      # Compiler TypeScript
npm run test       # Exécuter les tests
npm run start      # Démarrer le serveur
```

## Variables d'environnement requises
- `DATABASE_URL`: Connection string PostgreSQL
- `OPENAI_API_KEY`: Clé API OpenAI
- `JWT_SECRET`: Secret JWT
- `NODE_ENV`: "production"

## Support rapide
- Docker: `docker logs <container>`
- Netlify: `netlify log`
- Vercel: `vercel log`
