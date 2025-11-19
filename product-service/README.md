# Product Service

Service de gestion du catalogue produits pour DevOps MicroService App.

## Description

Le Product Service est un microservice NestJS qui gère :
- Le catalogue de produits (CRUD)
- Les favoris utilisateurs (authentification requise)
- Les avis produits (authentification requise)
- L'intégration avec l'API externe FakeStore

## Technologies

- **Framework** : NestJS + TypeScript
- **Base de données** : SQLite (products.db)
- **ORM** : TypeORM
- **Authentification** : JWT (validation des tokens générés par auth-service)
- **API externe** : FakeStore API (https://fakestoreapi.com)
- **Port** : 4000

## Architecture

```
product-service/
├── src/
│   ├── auth/               # Validation JWT
│   ├── products/           # CRUD produits
│   ├── favorites/          # Favoris utilisateurs
│   ├── reviews/            # Avis produits
│   ├── external-api/       # Intégration FakeStore API
│   ├── health/             # Health check
│   ├── database/           # Configuration TypeORM
│   └── config/             # Configuration globale
├── Dockerfile
└── README.md
```

## Endpoints API

### Endpoints publics (sans authentification)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/products` | Liste tous les produits |
| GET | `/products/:id` | Détail d'un produit |
| GET | `/products/search?q=` | Recherche par nom/description |
| GET | `/products/category/:name` | Filtrer par catégorie |
| GET | `/categories` | Liste des catégories |
| GET | `/products/:id/reviews` | Avis d'un produit |
| GET | `/health` | Health check |

### Endpoints protégés (JWT requis)

#### CRUD Produits (Admin)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/products` | Créer un produit |
| PUT | `/products/:id` | Modifier un produit |
| PATCH | `/products/:id/stock` | Mettre à jour le stock |
| DELETE | `/products/:id` | Supprimer un produit |

#### Favoris (Utilisateurs authentifiés)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/favorites` | Mes favoris |
| POST | `/products/:id/favorite` | Ajouter aux favoris |
| DELETE | `/products/:id/favorite` | Retirer des favoris |
| GET | `/products/:id/is-favorite` | Vérifier si favori |

#### Avis (Utilisateurs authentifiés)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/products/:id/review` | Ajouter un avis |
| PUT | `/reviews/:id` | Modifier mon avis |
| DELETE | `/reviews/:id` | Supprimer mon avis |

## Modèle de données

### Product

```typescript
{
  id: string;              // UUID
  name: string;
  description: string;
  price: number;
  category: string;
  imageUrl: string;
  stock: number;
  rating: number;          // Moyenne des avis (0-5)
  reviewCount: number;     // Nombre d'avis
  createdAt: Date;
  updatedAt: Date;
}
```

### Favorite

```typescript
{
  id: number;
  userId: string;         // Référence à Auth Service
  productId: string;      // Référence à Product
  createdAt: Date;
}
```

### Review

```typescript
{
  id: number;
  userId: string;         // Référence à Auth Service
  productId: string;      // Référence à Product
  rating: number;         // 1-5
  comment: string;
  createdAt: Date;
  updatedAt: Date;
}
```

## Intégration FakeStore API

Le service utilise l'API FakeStore pour seed la base de données au démarrage :
- URL : https://fakestoreapi.com
- Produits importés automatiquement si la DB est vide
- Stock généré aléatoirement (10-110 unités)

## Variables d'environnement

```env
# Server
PORT=4000
HOST=0.0.0.0
NODE_ENV=development

# Database
DATABASE_PATH=./data/products.db

# JWT (doit correspondre à auth-service)
JWT_SECRET=your-secret-key-here
JWT_ALGORITHM=HS256

# CORS
CORS_ORIGINS=http://localhost:3001

# Services
AUTH_SERVICE_URL=http://localhost:8000

# External API
FAKESTORE_API_URL=https://fakestoreapi.com
```

## Installation et lancement

### Mode local (développement)

```bash
# Installer les dépendances
npm install

# Copier le fichier d'environnement
cp .env.example .env

# Configurer JWT_SECRET (même valeur que auth-service)

# Démarrer en mode dev
npm run start:dev

# Build production
npm run build
npm run start:prod
```

Le service sera accessible sur http://localhost:4000

### Mode Docker Compose

```bash
# Depuis la racine du projet
docker-compose up --build product-service
```

### Mode Kubernetes

#### Option 1 : Avec Docker Hub (Recommandé)

```bash
# Build et push sur Docker Hub
cd product-service
./scripts/docker-push.sh v1.0.0

# Appliquer les manifests (utilise powlker/product-service:latest)
kubectl apply -f k8s/configmaps/product-config.yaml
kubectl apply -f k8s/persistent-volumes/product-pvc.yaml
kubectl apply -f k8s/deployments/product-deployment.yaml
kubectl apply -f k8s/services/product-service.yaml

# Vérifier le déploiement
kubectl get pods -n microservices -l app=product-service
kubectl logs -n microservices -l app=product-service

# Port-forward pour tester
kubectl port-forward -n microservices svc/product-service 4000:4000
```

#### Option 2 : Avec Minikube local

```bash
# Build l'image locale
eval $(minikube docker-env)
docker build -t product-service:latest .

# Modifier le deployment pour utiliser imagePullPolicy: IfNotPresent
# Puis appliquer les manifests
kubectl apply -f k8s/configmaps/product-config.yaml
kubectl apply -f k8s/persistent-volumes/product-pvc.yaml
kubectl apply -f k8s/deployments/product-deployment.yaml
kubectl apply -f k8s/services/product-service.yaml
```

## Tests

### Test Health Check

```bash
curl http://localhost:4000/health
```

### Test Liste Produits

```bash
curl http://localhost:4000/products
```

### Test Recherche

```bash
curl "http://localhost:4000/products/search?q=laptop"
```

### Test Catégories

```bash
curl http://localhost:4000/categories
```

### Test avec Authentification

```bash
# Obtenir un token depuis auth-service
TOKEN="votre-token-jwt"

# Voir mes favoris
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/favorites

# Ajouter aux favoris
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/products/{productId}/favorite
```

## Docker Hub

### Build et Push

Utiliser le script automatisé :

```bash
# Build et push avec tag latest
./scripts/docker-push.sh

# Build et push avec version spécifique
./scripts/docker-push.sh v1.0.0
```

### Pull depuis Docker Hub

```bash
docker pull powlker/product-service:latest
docker pull powlker/product-service:v1.0.0
```

### Run depuis Docker Hub

```bash
docker run -d \
  -p 4000:4000 \
  -e JWT_SECRET=your-secret \
  -e DATABASE_PATH=./data/products.db \
  powlker/product-service:latest
```

## Seed Database

La base de données est automatiquement seed au premier démarrage avec les produits de FakeStore API.

Pour forcer un nouveau seed :
```bash
# Supprimer la base de données
rm data/products.db

# Redémarrer le service
npm run start:dev
```

## Architecture microservices

Le Product Service fait partie d'une architecture microservices :

```
┌─────────────────────────────────────────┐
│          Frontend (Next.js)             │
│            Port: 3001                    │
└──────┬──────────────┬────────────┬──────┘
       │              │            │
       │              │            │
   ┌───▼───┐      ┌───▼───┐   ┌───▼───┐
   │ Auth  │      │Product│   │ Order │
   │Service│      │Service│   │Service│
   │ :8000 │      │ :4000 │   │ :3000 │
   └───────┘      └───────┘   └───────┘
```

### Communication inter-services

- **Frontend → Product Service** : Via API Routes (API Gateway)
- **Product Service → Auth Service** : Validation JWT uniquement (pas d'appel direct)
- **Product Service → FakeStore API** : Import initial des produits

## Sécurité

- **JWT** : Validation des tokens avec le même secret que auth-service
- **CORS** : Configuré pour accepter uniquement le frontend
- **Validation** : class-validator sur tous les DTOs
- **SQL Injection** : Protection via TypeORM (parameterized queries)

## Performance

- **Seed automatique** : Uniquement si DB vide
- **Indexes** : Sur les colonnes name, category, userId, productId
- **Calcul rating** : Mis à jour automatiquement à chaque ajout/modification/suppression d'avis

## Logs

Le service log :
- Démarrage et port d'écoute
- Seed de la base de données
- Erreurs de connexion API externe

## Troubleshooting

### Problème : Erreur de connexion à FakeStore API

**Solution** : Vérifier la connexion internet et l'URL de l'API dans la configuration.

### Problème : Erreur JWT

**Solution** : Vérifier que JWT_SECRET est identique dans auth-service et product-service.

### Problème : Base de données locked

**Solution** : SQLite ne supporte qu'un seul writer. Utiliser `replicas: 1` dans Kubernetes.

## Développement

### Structure du code

- **Controllers** : Gestion des routes HTTP
- **Services** : Logique métier
- **Entities** : Modèles TypeORM
- **DTOs** : Validation des entrées
- **Guards** : Protection JWT
- **Strategies** : Stratégie Passport JWT

### Ajouter un endpoint

1. Créer le DTO dans `dto/`
2. Ajouter la méthode dans le service
3. Ajouter la route dans le controller
4. Protéger avec `@UseGuards(JwtAuthGuard)` si nécessaire

## Contribution

1. Créer une branche feature
2. Commiter avec le format : `FIX-[product-service] : message`
3. Tester localement
4. Créer une pull request

## Licence

Projet académique EFREI - DevOps MicroService App

