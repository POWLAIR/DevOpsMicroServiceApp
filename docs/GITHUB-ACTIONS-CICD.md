# 🚀 CI/CD avec GitHub Actions

Guide complet pour l'intégration continue et le déploiement continu avec GitHub Actions.

---

## 📊 Vue d'ensemble

```
Push code → GitHub → GitHub Actions → Build Docker → Push Docker Hub
```

**9 workflows automatisés** pour gérer l'ensemble du projet :

| # | Workflow | Description | Déclencheur |
|---|----------|-------------|-------------|
| 1 | `frontend-push.yml` | Build et push Frontend | Push sur `frontend/**` |
| 2 | `auth-service-push.yml` | Build et push Auth Service | Push sur `auth-service/**` |
| 3 | `order-service-push.yml` | Build et push Order Service | Push sur `order-service/**` |
| 4 | `product-service-push.yml` | Build et push Product Service | Push sur `product-service/**` |
| 5 | `notification-service-push.yml` | Build et push Notification Service | Push sur `notification-service/**` |
| 6 | `payment-service-push.yml` | Build et push Payment Service | Push sur `payment-service/**` |
| 7 | `tenant-service-push.yml` | Build et push Tenant Service | Push sur `tenant-service/**` |
| 8 | `build-all-services.yml` | Build TOUS les services | Manuel / Release |
| 9 | `update-submodules.yml` | Synchroniser les submodules | Manuel / Quotidien |

---

## 🎯 Architecture CI/CD

```
┌─────────────────────────────────────────────┐
│           GitHub Repository                  │
│     github.com/POWLAIR/DevOpsMicroServiceApp │
└──────────────┬──────────────────────────────┘
               │ Push / Pull Request
               ▼
┌──────────────────────────────────────────────┐
│         GitHub Actions Runners               │
│         (ubuntu-latest)                      │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  1. Checkout code + submodules       │   │
│  │  2. Setup Docker Buildx              │   │
│  │  3. Login to Docker Hub              │   │
│  │  4. Build Docker image               │   │
│  │  5. Push to Docker Hub               │   │
│  └──────────────────────────────────────┘   │
└──────────────┬───────────────────────────────┘
               │ Push images
               ▼
┌──────────────────────────────────────────────┐
│           Docker Hub Registry                 │
│      hub.docker.com/u/DOCKERHUB_USERNAME     │
│                                              │
│  - devops-frontend:latest                   │
│  - devops-auth-service:latest               │
│  - devops-order-service:latest              │
│  - devops-product-service:latest            │
│  - devops-notification-service:latest       │
│  - devops-payment-service:latest            │
│  - devops-tenant-service:latest             │
└──────────────────────────────────────────────┘
```

---

## 📋 Prérequis

### 1. Secrets GitHub

Configurer les secrets dans le repo GitHub :

1. Aller sur : `https://github.com/POWLAIR/DevOpsMicroServiceApp/settings/secrets/actions`
2. Cliquer sur **New repository secret**
3. Ajouter les secrets suivants :

| Nom | Description | Exemple |
|-----|-------------|---------|
| `DOCKERHUB_USERNAME` | Nom d'utilisateur Docker Hub | `powlker` |
| `DOCKERHUB_TOKEN` | Token d'accès Docker Hub | `dckr_pat_...` |
| `NEXT_PUBLIC_API_URL` | URL API pour Frontend (optionnel) | `https://api.example.com` |

#### Créer un token Docker Hub

```bash
# 1. Se connecter à Docker Hub : https://hub.docker.com
# 2. Aller dans : Account Settings > Security > New Access Token
# 3. Nom : "GitHub Actions"
# 4. Permissions : Read, Write, Delete
# 5. Copier le token (il ne sera affiché qu'une fois)
```

### 2. GitHub Actions activé

GitHub Actions est activé par défaut sur les repos publics et privés (avec quota).

---

## 🔄 Workflows Individuels par Service

### Frontend (Next.js)

**Fichier** : `.github/workflows/frontend-push.yml`

**Déclenché par** :
- Push sur `frontend/**`
- Push sur `.github/workflows/frontend-push.yml`
- Manuellement (workflow_dispatch)

**Actions** :
1. Clone le repo avec submodules
2. Build l'image Docker `devops-frontend:latest`
3. Push vers Docker Hub

**Tester** :

```bash
cd frontend
echo "# Test CI/CD" >> README.md
git add README.md
git commit -m "FIX-[frontend] : test GitHub Actions"
git push github main
```

### Auth Service (FastAPI)

**Fichier** : `.github/workflows/auth-service-push.yml`

**Déclenché par** :
- Push sur `auth-service/**`
- Manuellement

**Image Docker** : `devops-auth-service:latest`

### Order Service (NestJS)

**Fichier** : `.github/workflows/order-service-push.yml`

**Image Docker** : `devops-order-service:latest`

### Product Service (NestJS)

**Fichier** : `.github/workflows/product-service-push.yml`

**Image Docker** : `devops-product-service:latest`

### Notification Service (FastAPI)

**Fichier** : `.github/workflows/notification-service-push.yml`

**Image Docker** : `devops-notification-service:latest`

### Payment Service (Go)

**Fichier** : `.github/workflows/payment-service-push.yml`

**Image Docker** : `devops-payment-service:latest`

### Tenant Service (NestJS)

**Fichier** : `.github/workflows/tenant-service-push.yml`

**Image Docker** : `devops-tenant-service:latest`

---

## 🌐 Workflow Global - Build All Services

**Fichier** : `.github/workflows/build-all-services.yml`

**Fonctionnalités** :
- Build les **7 services en parallèle** (matrice)
- Option : Build only (pour tester) OU Build + Push
- Déclenché manuellement ou lors d'une release

### Utilisation

#### Option 1 : Via GitHub UI

1. Aller sur : `https://github.com/POWLAIR/DevOpsMicroServiceApp/actions`
2. Sélectionner le workflow **Build All Services**
3. Cliquer sur **Run workflow**
4. Choisir :
   - **push_to_dockerhub** : `true` (push vers Docker Hub) ou `false` (build only)
5. Cliquer sur **Run workflow**

#### Option 2 : Via GitHub CLI

```bash
# Build only (ne pas pousser vers Docker Hub)
gh workflow run build-all-services.yml \
  -f push_to_dockerhub=false

# Build et push vers Docker Hub
gh workflow run build-all-services.yml \
  -f push_to_dockerhub=true
```

**Résultat** :
- 7 jobs en parallèle
- Durée totale : ~10-15 minutes (selon la taille des services)
- Résumé automatique des builds

---

## 🔄 Workflow Update Submodules

**Fichier** : `.github/workflows/update-submodules.yml`

**Fonctionnalités** :
- Synchronise automatiquement les submodules vers leurs derniers commits
- Commit et push les changements
- Déclenché quotidiennement à 2h du matin OU manuellement

### Utilisation

#### Manuellement via GitHub UI

1. Aller sur : `https://github.com/POWLAIR/DevOpsMicroServiceApp/actions`
2. Sélectionner **Update Submodules**
3. Cliquer sur **Run workflow**

#### Manuellement via GitHub CLI

```bash
gh workflow run update-submodules.yml
```

#### Automatiquement

Le workflow s'exécute tous les jours à 2h du matin (UTC) pour vérifier les mises à jour.

**Commit automatique** :

```
REFACTOR-[repo-parent] : auto-update submodules to latest commits
```

---

## 📊 Monitoring et Logs

### Voir les workflows en cours

```bash
# Via GitHub CLI
gh run list

# Voir les détails d'un workflow
gh run view <RUN_ID>

# Voir les logs
gh run view <RUN_ID> --log
```

### Via GitHub UI

1. Aller sur : `https://github.com/POWLAIR/DevOpsMicroServiceApp/actions`
2. Cliquer sur un workflow pour voir les détails
3. Cliquer sur un job pour voir les logs

### Statut du workflow

Les workflows affichent un badge :

```markdown
![Build Status](https://github.com/POWLAIR/DevOpsMicroServiceApp/actions/workflows/build-all-services.yml/badge.svg)
```

---

## 🔧 Personnalisation des Workflows

### Ajouter des tests unitaires

Modifier un workflow (exemple : `frontend-push.yml`) :

```yaml
steps:
  - name: Checkout code with submodules
    uses: actions/checkout@v4
    with:
      submodules: recursive
  
  # Nouveau step : Tests
  - name: Run tests
    run: |
      cd frontend
      npm install
      npm run test
  
  # ... reste du workflow (build docker)
```

### Ajouter des notifications Slack/Discord

```yaml
- name: Notify Slack
  if: success()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
    payload: |
      {
        "text": "✅ ${{ matrix.service.name }} deployed successfully!"
      }
```

### Déploiement Kubernetes automatique

Ajouter un step de déploiement :

```yaml
- name: Deploy to Kubernetes
  if: github.ref == 'refs/heads/main'
  run: |
    kubectl set image deployment/${{ matrix.service.name }} \
      ${{ matrix.service.name }}=${{ secrets.DOCKERHUB_USERNAME }}/${{ matrix.service.image }}:latest \
      -n microservices
```

---

## 🎯 Workflow de Développement

### 1. Développer localement

```bash
# Créer une branche feature
git checkout -b feature/nouvelle-fonctionnalite

# Travailler sur un service (exemple: frontend)
cd frontend
# ... faire des modifications
git add .
git commit -m "FIX-[frontend] : implement new feature"
git push origin feature/nouvelle-fonctionnalite
```

### 2. Créer une Pull Request

```bash
gh pr create \
  --title "Feature: nouvelle fonctionnalité" \
  --body "Description de la fonctionnalité"
```

### 3. CI/CD automatique

- Les workflows **ne se déclenchent PAS** automatiquement sur les branches feature
- Pour tester avant merge : déclencher manuellement le workflow

### 4. Merger vers main

```bash
# Merger la PR (via GitHub UI ou CLI)
gh pr merge --merge

# Le workflow se déclenche automatiquement sur main
# L'image Docker est buildée et pushée vers Docker Hub
```

---

## 🐛 Troubleshooting

### Erreur : "Secrets not found"

**Solution** : Vérifier que les secrets sont bien configurés dans le repo :

```bash
# Lister les secrets (ne montre pas les valeurs)
gh secret list
```

Si manquants, les ajouter :

```bash
gh secret set DOCKERHUB_USERNAME --body "powlker"
gh secret set DOCKERHUB_TOKEN --body "dckr_pat_..."
```

### Erreur : "Submodule not found"

**Solution** : S'assurer que le checkout inclut les submodules :

```yaml
- name: Checkout code with submodules
  uses: actions/checkout@v4
  with:
    submodules: recursive  # ← Important !
```

### Erreur : "Docker build failed"

**Solution** : Vérifier localement que le Dockerfile fonctionne :

```bash
cd frontend
docker build -t test-frontend .
```

### Workflow ne se déclenche pas

**Causes possibles** :
1. Le path filter ne correspond pas (vérifier `paths:` dans le workflow)
2. La branche n'est pas `main` (workflows déclenchés uniquement sur main)
3. GitHub Actions désactivé (vérifier Settings > Actions)

---

## 📈 Optimisations

### 1. Cache Docker layers

Déjà configuré dans les workflows :

```yaml
cache-from: type=registry,ref=${{ secrets.DOCKERHUB_USERNAME }}/devops-frontend:latest
cache-to: type=inline
```

**Gain** : 2-3x plus rapide sur les builds suivants.

### 2. Build parallèle

Le workflow `build-all-services.yml` utilise une matrice pour construire les 7 services en parallèle.

**Durée** : ~10-15 minutes (au lieu de 70 minutes en série).

### 3. Limiter les déclencheurs

Les workflows sont déclenchés uniquement quand les fichiers du service changent :

```yaml
on:
  push:
    paths:
      - 'frontend/**'
      - '.github/workflows/frontend-push.yml'
```

**Avantage** : Pas de build inutile si on modifie un autre service.

---

## 🎓 Comparaison Gitea Actions vs GitHub Actions

| Fonctionnalité | Gitea Actions | GitHub Actions |
|----------------|---------------|----------------|
| **Runner** | Self-hosted obligatoire | Hosted (gratuit) ou self-hosted |
| **Syntaxe** | Compatible GitHub Actions | Natif |
| **Marketplace** | Limité | 20 000+ actions |
| **Cache** | Manuel | Automatique |
| **Secrets** | Par repo | Par repo / organisation |
| **Logs** | Basiques | Avancés + artifacts |
| **Déclencheurs** | Push, PR, Cron | Push, PR, Cron, Release, etc. |
| **Quota** | Illimité (self-hosted) | 2000 min/mois (gratuit) |

**Conclusion** : GitHub Actions est plus simple, plus puissant et gratuit pour les repos publics.

---

## 📚 Ressources

### Documentation GitHub Actions

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)

### Actions utilisées dans ce projet

- [actions/checkout@v4](https://github.com/actions/checkout) - Clone le repo
- [docker/setup-buildx-action@v3](https://github.com/docker/setup-buildx-action) - Setup Docker Buildx
- [docker/login-action@v3](https://github.com/docker/login-action) - Login Docker Hub
- [docker/metadata-action@v5](https://github.com/docker/metadata-action) - Génère tags/labels
- [docker/build-push-action@v5](https://github.com/docker/build-push-action) - Build et push images

### Exemples de workflows avancés

- [Déploiement Kubernetes](https://github.com/marketplace/actions/kubernetes-cli-kubectl)
- [Tests avec coverage](https://github.com/marketplace/actions/coveralls-github-action)
- [Notifications Slack](https://github.com/marketplace/actions/slack-send)

---

## ✅ Checklist Migration Gitea → GitHub Actions

- [x] Créer les secrets Docker Hub sur GitHub
- [x] Créer les workflows pour les 7 services
- [x] Créer le workflow `build-all-services`
- [x] Créer le workflow `update-submodules`
- [x] Tester chaque workflow individuellement
- [x] Tester le workflow global
- [ ] Configurer les branch protection rules
- [ ] Ajouter des tests unitaires dans les workflows
- [ ] Configurer les notifications (optionnel)

---

**CI/CD GitHub Actions configuré et opérationnel ! 🚀**

**Tous vos 7 microservices sont maintenant automatiquement buildés et déployés sur Docker Hub à chaque push !** 🐳

