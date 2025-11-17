# DevOps MicroService App

Application microservices avec API Gateway Next.js, Auth Service FastAPI et Order Service NestJS.

## Architecture

- **Frontend/API Gateway** (Next.js) - Point d'entrée unique
- **Auth Service** (Python FastAPI + SQLite) - Authentification et autorisation
- **Order Service** (NestJS + SQLite) - Gestion des commandes

## Structure du projet

Ce repo parent utilise des **submodules Git** pour regrouper les 3 services sans duplication de code :

```text
DevOpsMicroServiceApp/
├── frontend/          # Frontend + API Gateway (Next.js) [submodule]
├── auth-service/      # Auth Service (FastAPI) - TP 03 [submodule]
├── order-service/     # Order Service (NestJS) - TP 04 [submodule]
└── docs/             # Documentation
```

### Cloner le repo avec les submodules

```bash
# Cloner le repo parent
git clone git@gitea.com:PowlAIR/DevOpsMicoServiceApp.git DevOpsMicroServiceApp
cd DevOpsMicroServiceApp

# Initialiser et cloner les submodules
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

### 3. Order Service (NestJS)

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
- `NEXT_PUBLIC_API_URL=http://localhost:3001`

### Auth Service (.env)

- `DATABASE_URL=sqlite:///./auth.db`
- `SECRET_KEY=your-super-secret-key-change-in-production`
- `ALGORITHM=HS256`
- `ACCESS_TOKEN_EXPIRE_MINUTES=30`
- `HOST=0.0.0.0`
- `PORT=8000`
- `CORS_ORIGINS=http://localhost:3001,http://localhost:3000`

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

**Important** : Lancer les services dans l'ordre suivant (3 terminaux séparés) :

#### Terminal 1 - Auth Service (port 8000)

```bash
cd auth-service
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Terminal 2 - Order Service (port 3000)

```bash
cd order-service
npm run start:dev
```

#### Terminal 3 - Frontend/API Gateway (port 3001)

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

## TPs

- **TP 01** : Architecture MicroServices et Philosophie DevOps
- **TP 02** : Frontend + API Gateway (Next.js) ✅
- **TP 03** : Auth Service (Python FastAPI + SQLite) ✅
- **TP 04** : Order Service (NestJS API + SQLite) ✅
- **TP 05** : Conteneurisation (Docker + Docker Compose)
- **TP 06** : Orchestration (Kubernetes)

## Contribution

Format de commit : `DEVOP-XXX : [service] message`

Exemple : `DEVOP-002 : [frontend] add authentication context`
