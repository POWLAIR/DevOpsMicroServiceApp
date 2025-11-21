# 🚀 GitHub Actions Workflows

Ce dossier contient tous les workflows GitHub Actions pour le CI/CD du projet.

---

## 📋 Liste des Workflows

### Workflows par Service (7)

| Workflow | Description | Déclencheur |
|----------|-------------|-------------|
| `frontend-push.yml` | Build et push Frontend (Next.js) | Push sur `frontend/**` |
| `auth-service-push.yml` | Build et push Auth Service (FastAPI) | Push sur `auth-service/**` |
| `order-service-push.yml` | Build et push Order Service (NestJS) | Push sur `order-service/**` |
| `product-service-push.yml` | Build et push Product Service (NestJS) | Push sur `product-service/**` |
| `notification-service-push.yml` | Build et push Notification Service (FastAPI) | Push sur `notification-service/**` |
| `payment-service-push.yml` | Build et push Payment Service (Go) | Push sur `payment-service/**` |
| `tenant-service-push.yml` | Build et push Tenant Service (NestJS) | Push sur `tenant-service/**` |

### Workflows Globaux (1)

| Workflow | Description | Déclencheur |
|----------|-------------|-------------|
| `build-all-services.yml` | Build TOUS les services en parallèle | Manuel / Release |

---

## 🎯 Utilisation Rapide

### Déclencher un build individuel

Chaque workflow s'exécute automatiquement lors d'un push sur son service :

```bash
cd frontend
echo "# Change" >> README.md
git add . && git commit -m "FIX-[frontend] : test CI"
git push github main
```

### Déclencher tous les builds

Via GitHub UI :

1. Aller sur [Actions](https://github.com/POWLAIR/DevOpsMicroServiceApp/actions)
2. Sélectionner **Build All Services**
3. Cliquer sur **Run workflow**
4. Choisir `push_to_dockerhub: true`

Via GitHub CLI :

```bash
gh workflow run build-all-services.yml -f push_to_dockerhub=true
```

---

## 🔑 Secrets Requis

Configurer dans [Settings > Secrets](https://github.com/POWLAIR/DevOpsMicroServiceApp/settings/secrets/actions) :

| Nom | Description |
|-----|-------------|
| `DOCKERHUB_USERNAME` | Nom d'utilisateur Docker Hub |
| `DOCKERHUB_TOKEN` | Token d'accès Docker Hub |
| `NEXT_PUBLIC_API_URL` | URL API pour Frontend (optionnel) |

---

## 📚 Documentation Complète

Voir [docs/GITHUB-ACTIONS-CICD.md](../../docs/GITHUB-ACTIONS-CICD.md) pour la documentation complète.

---

**CI/CD configuré et prêt à l'emploi !** 🚀

