# DevOps MicroService App

Application microservices avec API Gateway Next.js, Auth Service FastAPI et Order Service NestJS.

## Architecture

- **Frontend/API Gateway** (Next.js) - Point d'entrée unique
- **Auth Service** (Python FastAPI + SQLite) - Authentification et autorisation
- **Order Service** (NestJS + SQLite) - Gestion des commandes

## Structure du projet

Ce repo parent utilise des **submodules Git** pour regrouper les 3 services sans duplication de code :

```
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

### Frontend

```bash
cd frontend
npm install
cp .env.example .env.local
# Éditer .env.local avec les bonnes valeurs
npm run dev
```

## Variables d'environnement

Créer un fichier `.env.local` dans chaque service (voir `.env.example`).

### Frontend
- `AUTH_SERVICE_URL=http://localhost:8000`
- `ORDER_SERVICE_URL=http://localhost:3000`
- `NEXT_PUBLIC_API_URL=http://localhost:3001`

## Développement

```bash
# Frontend
cd frontend
npm run dev

# Auth Service (TP 03)
cd auth-service
uvicorn main:app --reload

# Order Service (TP 04)
cd order-service
npm run start:dev
```

## TPs

- **TP 01** : Architecture MicroServices et Philosophie DevOps
- **TP 02** : Frontend + API Gateway (Next.js) ✅
- **TP 03** : Auth Service (Python FastAPI + SQLite)
- **TP 04** : Order Service (NestJS API + SQLite)
- **TP 05** : Conteneurisation (Docker + Docker Compose)
- **TP 06** : Orchestration (Kubernetes)

## Contribution

Format de commit : `DEVOP-XXX : [service] message`

Exemple : `DEVOP-002 : [frontend] add authentication context`

