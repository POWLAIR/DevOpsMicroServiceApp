# DevOps MicroService App

Application microservices E-commerce avec API Gateway Next.js, Auth Service FastAPI, Product Service et Order Service NestJS.

> 🚀 **Nouveau sur le projet ?** Consultez le [Guide de Démarrage Rapide](docs/QUICKSTART.md) pour lancer l'application en 5 minutes !

## Architecture

- **Frontend/API Gateway** (Next.js) - Point d'entrée unique avec catalogue produits
- **Auth Service** (Python FastAPI + SQLite) - Authentification et autorisation
- **Product Service** (NestJS + SQLite) - Catalogue produits, favoris, avis (TP 07)
- **Order Service** (NestJS + SQLite) - Gestion des commandes
- **Payment Service** (Go + Fiber + PostgreSQL) - Paiements Stripe avec webhooks ✨ **NOUVEAU**
- **Notification Service** (Python FastAPI + Celery + Redis) - Emails (SendGrid) et SMS (Twilio) ✨ **NOUVEAU**

## Structure du projet

Ce projet utilise une **architecture modulaire** avec 7 microservices (submodules GitHub) :

```text
DevOpsMicroServiceApp/
├── frontend/              # [submodule] Frontend + API Gateway (Next.js)
├── auth-service/          # [submodule] Auth Service (FastAPI)
├── product-service/       # [submodule] Product Service (NestJS)
├── order-service/         # [submodule] Order Service (NestJS)
├── notification-service/  # [submodule] Notification Service (FastAPI)
├── payment-service/       # [submodule] Payment Service (Go)
├── tenant-service/        # [submodule] Tenant Service (NestJS)
├── k8s/                   # Manifests Kubernetes
├── docker-compose.yml     # Orchestration Docker Compose
├── scripts/               # Scripts de migration et utilitaires
└── docs/                  # Documentation$$

$$
```

> 📚 **Migration Gitea → GitHub** : Consultez [docs/MIGRATION-GITHUB.md](docs/MIGRATION-GITHUB.md)

### Cloner le repo avec les submodules

```bash
# Cloner le repo parent (GitHub)
git clone --recursive git@github.com:POWLAIR/DevOpsMicroServiceApp.git
cd DevOpsMicroServiceApp

# Si déjà cloné sans --recursive, initialiser les submodules
git submodule update --init --recursive
```

### Mettre à jour les submodules

```bash
# Mettre à jour tous les submodules vers leur dernière version
git submodule update --remote

# Commiter les mises à jour dans le repo parent
git commit -am "DEVOP- : [repo-parent] update submodules"
git push
```

### Travailler sur un service

Les services sont des repos Git indépendants. Pour travailler sur un service :

```bash
cd frontend  # ou auth-service, order-service
# Faire vos modifications, commits, pushes comme d'habitude
git add .
git commit -m "DEVOP-XXX : [frontend] votre message"
git push origin main
```

## Prérequis

- Node.js 20+
- Python 3.11+ (pour Auth Service)
- npm ou yarn

## Installation

### 1. Frontend (Next.js)

```bash
cd frontend
npm install
cp .env.example .env.local
# Éditer .env.local avec les bonnes valeurs
```

### 2. Auth Service (FastAPI)

```bash
cd auth-service
python3 -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Éditer .env et configurer les variables nécessaires
```

### 3. Product Service (NestJS)

```bash
cd product-service
npm install
cp .env.example .env
# Éditer .env et configurer les variables nécessaires
# IMPORTANT: JWT_SECRET doit être identique à auth-service
```

### 4. Order Service (NestJS)

```bash
cd order-service
npm install
cp .env.example .env
# Éditer .env et configurer les variables nécessaires
```

## Variables d'environnement

Créer un fichier `.env.local` (frontend) ou `.env` (services backend) dans chaque service (voir `.env.example`).

### Frontend (.env.local)

- `AUTH_SERVICE_URL=http://localhost:8000`
- `ORDER_SERVICE_URL=http://localhost:3000`
- `PRODUCT_SERVICE_URL=http://localhost:4000`
- `NEXT_PUBLIC_API_URL=http://localhost:3001`

### Auth Service (.env)

- `DATABASE_URL=sqlite:///./auth.db`
- `SECRET_KEY=your-super-secret-key-change-in-production`
- `ALGORITHM=HS256`
- `ACCESS_TOKEN_EXPIRE_MINUTES=30`
- `HOST=0.0.0.0`
- `PORT=8000`
- `CORS_ORIGINS=http://localhost:3001,http://localhost:3000`

### Product Service (.env)

- `DATABASE_PATH=./data/products.db`
- `JWT_SECRET=your-super-secret-key-change-in-production` (doit correspondre à SECRET_KEY de l'Auth Service)
- `JWT_ALGORITHM=HS256`
- `PORT=4000`
- `HOST=0.0.0.0`
- `NODE_ENV=development`
- `CORS_ORIGINS=http://localhost:3001`
- `AUTH_SERVICE_URL=http://localhost:8000`
- `FAKESTORE_API_URL=https://fakestoreapi.com`

### Order Service (.env)

- `DATABASE_PATH=./orders.db`
- `JWT_SECRET=your-super-secret-key-change-in-production` (doit correspondre à SECRET_KEY de l'Auth Service)
- `JWT_ALGORITHM=HS256`
- `PORT=3000`
- `HOST=0.0.0.0`
- `CORS_ORIGINS=http://localhost:3001,http://localhost:3000`
- `AUTH_SERVICE_URL=http://localhost:8000`

## Développement

### Lancer tous les services

**Important** : Lancer les services dans l'ordre suivant (4 terminaux séparés) :

#### Terminal 1 - Auth Service (port 8000)

```bash
cd auth-service
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Terminal 2 - Product Service (port 4000)

```bash
cd product-service
npm run start:dev
```

#### Terminal 3 - Order Service (port 3000)

```bash
cd order-service
npm run start:dev
```

#### Terminal 4 - Frontend/API Gateway (port 3001)

```bash
cd frontend
npm run dev
```

### URLs des services

Une fois tous les services démarrés :

- **Frontend/API Gateway** : <http://localhost:3001>
- **Auth Service** : <http://localhost:8000>
  - Documentation Swagger : <http://localhost:8000/docs>
  - Documentation ReDoc : <http://localhost:8000/redoc>
- **Order Service** : <http://localhost:3000>

### Lancer un service individuel

```bash
# Frontend
cd frontend
npm run dev

# Auth Service (TP 03)
cd auth-service
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Order Service (TP 04)
cd order-service
npm run start:dev
```

## Déploiement Kubernetes (TP 06)

### Prérequis

- Kubernetes cluster local (Minikube ou Orbstack)
- `kubectl` installé et configuré
- Docker pour construire les images
- Ingress Controller activé (nginx-ingress pour Minikube)

#### Installation Minikube

```bash
# Installer Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Démarrer Minikube
minikube start

# Activer l'Ingress
minikube addons enable ingress

# Configurer Docker pour utiliser le daemon Minikube
eval $(minikube docker-env)
```

#### Installation Orbstack

Orbstack est une alternative à Docker Desktop qui inclut Kubernetes. Activer Kubernetes dans les paramètres d'Orbstack.

### Construction des images Docker

```bash
# Avec Minikube : configurer Docker pour utiliser le daemon Minikube
eval $(minikube docker-env)

# Construire les images
(cd auth-service && docker build -t auth-service:latest .)
(cd order-service && docker build -t order-service:latest .)
(cd frontend && docker build -t frontend:latest .)
```

### Déploiement

#### 1. Créer le namespace

```bash
kubectl apply -f k8s/namespace.yaml
```

#### 2. Créer les ConfigMaps

```bash
kubectl apply -f k8s/configmaps/
```

#### 3. Créer le Secret JWT

**Important** : Ne jamais commiter les secrets en clair. Créer le secret via `kubectl` :

```bash
kubectl create secret generic jwt-secret \
  --from-literal=SECRET_KEY=your-super-secret-key-change-in-production \
  --from-literal=JWT_SECRET=your-super-secret-key-change-in-production \
  -n microservices
```

Ou utiliser le template `k8s/secrets/jwt-secret.yaml.example` (modifier les valeurs avant d'appliquer).

#### 4. Créer les PersistentVolumeClaims

```bash
kubectl apply -f k8s/persistent-volumes/
```

#### 5. Créer les Deployments

```bash
kubectl apply -f k8s/deployments/
```

#### 6. Créer les Services

```bash
kubectl apply -f k8s/services/
```

#### 7. Créer l'Ingress

```bash
kubectl apply -f k8s/ingress/
```

#### Déploiement complet (tous les manifests)

```bash
# Appliquer tous les manifests (sauf le secret)
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmaps/
kubectl apply -f k8s/persistent-volumes/
kubectl apply -f k8s/deployments/
kubectl apply -f k8s/services/
kubectl apply -f k8s/ingress/

# Créer le secret séparément
kubectl create secret generic jwt-secret \
  --from-literal=SECRET_KEY=your-secret-key \
  --from-literal=JWT_SECRET=your-secret-key \
  -n microservices
```

### Vérification

#### Vérifier les pods

```bash
kubectl get pods -n microservices
```

Tous les pods doivent être en état `Running`.

#### Vérifier les services

```bash
kubectl get services -n microservices
```

#### Vérifier les deployments

```bash
kubectl get deployments -n microservices
```

#### Vérifier les PVCs

```bash
kubectl get pvc -n microservices
```

Les PVCs doivent être en état `Bound`.

#### Voir les logs

```bash
# Logs d'un pod spécifique
kubectl logs -f <pod-name> -n microservices

# Logs de tous les pods d'un deployment
kubectl logs -f deployment/auth-deployment -n microservices
```

#### Décrire un pod (debugging)

```bash
kubectl describe pod <pod-name> -n microservices
```

### Accès aux services

#### Via Ingress (recommandé)

```bash
# Obtenir l'IP de l'Ingress
kubectl get ingress -n microservices

# Ajouter l'entrée dans /etc/hosts (ou équivalent)
# <INGRESS_IP> microservices.local

# Accéder à l'application
# http://microservices.local
```

#### Via Port Forward (développement)

```bash
# Frontend
kubectl port-forward svc/frontend-service 3001:3001 -n microservices

# Auth Service
kubectl port-forward svc/auth-service 8000:8000 -n microservices

# Order Service
kubectl port-forward svc/order-service 3000:3000 -n microservices
```

#### Via Minikube Service

```bash
# Obtenir l'URL du service frontend
minikube service frontend-service -n microservices --url

# Ou utiliser le tunnel Minikube
minikube tunnel
```

### Commandes utiles

#### Mettre à jour une image

```bash
kubectl set image deployment/auth-deployment \
  auth-service=auth-service:v2 \
  -n microservices
```

#### Vérifier le statut d'un rollout

```bash
kubectl rollout status deployment/auth-deployment -n microservices
```

#### Rollback

```bash
kubectl rollout undo deployment/auth-deployment -n microservices
```

#### Exécuter une commande dans un pod

```bash
kubectl exec -it <pod-name> -n microservices -- /bin/sh
```

#### Voir les événements

```bash
kubectl get events -n microservices --sort-by='.lastTimestamp'
```

### Suppression

#### Supprimer tous les ressources

```bash
kubectl delete namespace microservices
```

#### Supprimer individuellement

```bash
kubectl delete -f k8s/
```

### Notes importantes

1. **SQLite et ReadWriteOnce** : Les services auth et order utilisent `replicas: 1` car SQLite ne supporte qu'un seul writer à la fois avec ReadWriteOnce.

2. **Service Discovery** : Les services communiquent via DNS Kubernetes (`http://auth-service:8000`, `http://order-service:3000`).

3. **Secrets** : Ne jamais commiter les secrets en clair. Utiliser `kubectl create secret` ou un gestionnaire de secrets en production.

4. **Images Docker** : Les images doivent être construites et disponibles dans le registre utilisé par Kubernetes (local pour Minikube/Orbstack).

5. **Storage Class** : Pour Minikube, utiliser `storageClassName: standard` ou `hostpath` selon la configuration.

## CI/CD - GitHub Actions

Le projet utilise GitHub Actions pour l'intégration et le déploiement continus.

### Workflows automatiques

- **9 workflows** configurés pour tous les services
- Build automatique sur push vers `main`
- Push vers Docker Hub
- Synchronisation automatique des submodules

### Documentation

Voir [docs/GITHUB-ACTIONS-CICD.md](docs/GITHUB-ACTIONS-CICD.md) pour :

- Configuration des secrets
- Utilisation des workflows
- Personnalisation et optimisation

### Déclencher un build

```bash
# Via GitHub CLI
gh workflow run build-all-services.yml -f push_to_dockerhub=true

# Ou manuellement sur GitHub
# Actions → Build All Services → Run workflow
```

---

## TPs

- **TP 01** : Architecture MicroServices et Philosophie DevOps
- **TP 02** : Frontend + API Gateway (Next.js) ✅
- **TP 03** : Auth Service (Python FastAPI + SQLite) ✅
- **TP 04** : Order Service (NestJS API + SQLite) ✅
- **TP 05** : Conteneurisation (Docker + Docker Compose) ✅
- **TP 06** : Orchestration (Kubernetes) ✅
- **TP 07** : CI/CD (GitHub Actions) ✅

## Contribution

Format de commit : `PREFIX-[service] : message`

Exemples :

- `FIX-[frontend] : add authentication context`
- `REFACTOR-[auth-service] : improve JWT validation`
- `DOCS-[repo-parent] : update README`

Préfixes : `FIX`, `BUGFIX`, `REFACTOR`, `TESTS`, `DOCS`
