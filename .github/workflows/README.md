# 🚀 GitHub Actions Workflows

Les workflows CI/CD de ce projet sont distribués dans chaque sous-module de service.

---

## 📋 Architecture CI/CD

Chaque service (sous-module) possède son propre workflow :

| Service | Technologie | Action CI/CD |
|---------|-------------|--------------|
| Frontend | Next.js | Build et push image Docker |
| Auth Service | FastAPI | Build et push image Docker |
| Order Service | NestJS | Build et push image Docker |
| Product Service | NestJS | Build et push image Docker |
| Notification Service | FastAPI | Build et push image Docker |
| Payment Service | Go | Build et push image Docker |
| Tenant Service | NestJS | Build et push image Docker |

## 🎯 Utilisation

Chaque service (sous-module) possède son propre workflow de CI/CD dans **son propre repository**.

**Fonctionnement :**
1. Aller dans le repo du service (ex: `devops-auth-service`)
2. Modifier du code et push sur `main`
3. Le workflow GitHub Actions se déclenche automatiquement
4. L'image Docker est buildée et pushée sur Docker Hub

**Exemple :**

```bash
# Dans le repo du service (pas le repo parent)
cd devops-auth-service
echo "# Change" >> README.md
git add . && git commit -m "FIX-[auth-service] : update feature"
git push origin main
```

---

## 🔑 Secrets Requis

À configurer dans **chaque repository de service** :

| Nom | Description |
|-----|-------------|
| `DOCKERHUB_USERNAME` | Nom d'utilisateur Docker Hub |
| `DOCKERHUB_TOKEN` | Token d'accès Docker Hub |
| `NEXT_PUBLIC_API_URL` | URL API pour Frontend (optionnel, frontend uniquement) |

---

## 📝 Note

Ce repo parent (`DevOpsMicroServiceApp`) est un conteneur de sous-modules.  
Les workflows CI/CD sont situés dans chaque sous-module indépendant.

---

**CI/CD décentralisé par service !** 🚀

