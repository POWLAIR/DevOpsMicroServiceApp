# 🚀 GUIDE DE DÉMARRAGE RAPIDE

**Version :** 1.1.0  
**Date :** 8 décembre 2025

---

## 📋 PRÉ-REQUIS

- ✅ Docker & Docker Compose installés
- ✅ Ports disponibles : 3000, 4000, 5432, 6379, 8000
- ✅ 4 GB RAM minimum
- ✅ 10 GB espace disque

---

## ⚡ DÉMARRAGE EN 3 ÉTAPES

### 1️⃣ Cloner et Configurer

```bash
# Cloner le projet
git clone <votre-repo>
cd DevOpsMicroServiceApp

# Copier le fichier .env (si nécessaire)
cp .env.example .env
```

### 2️⃣ Lancer les Services

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier que tout est lancé
docker-compose ps
```

**Attendu :**
```
NAME                COMMAND                  SERVICE             STATUS
saas_auth           "uvicorn app.main:ap…"   auth-service        Up
saas_frontend       "docker-entrypoint.s…"   frontend            Up
saas_postgres       "docker-entrypoint.s…"   postgres            Up
saas_product        "docker-entrypoint.s…"   product-service     Up
saas_redis          "docker-entrypoint.s…"   redis               Up
...
```

### 3️⃣ Initialiser les Données

```bash
# Attendre 30 secondes que les services soient prêts
sleep 30

# Lancer le seeding complet
chmod +x scripts/init-complete-data.sh
./scripts/init-complete-data.sh
```

**Sortie attendue :**
```
============================================
🚀 INITIALISATION COMPLÈTE DES DONNÉES
============================================
▶ Vérification des services Docker...
✅ Services Docker actifs
▶ 1/5 - Seeding Auth Service...
✅ Tenants et utilisateurs créés
▶ 2/5 - Seeding Product Service...
✅ Produits créés
▶ 3/5 - Seeding Favoris et Avis...
✅ Favoris et avis créés
============================================
📊 STATISTIQUES DES DONNÉES CRÉÉES
============================================
👥 Utilisateurs: 11
📦 Produits: 16
❤️  Favoris: 5
⭐ Avis: 12
============================================
✅ INITIALISATION COMPLÈTE TERMINÉE !
============================================
```

---

## 🌐 ACCÈS À L'APPLICATION

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:3000 | Interface utilisateur |
| **Auth API** | http://localhost:8000 | Service d'authentification |
| **Product API** | http://localhost:4000 | Service produits |
| **PostgreSQL** | localhost:5433 | Base de données |
| **Redis** | localhost:6379 | Cache |

---

## 👤 COMPTES DE TEST

### Customer (Client)

```
Email: customer1@example.com
Password: Customer123!
Tenant: Tech Store
```

**Accès :**
- ✅ Catalogue produits
- ✅ Favoris
- ✅ Panier
- ✅ Commandes
- ✅ Profil

---

### Merchant Staff (Employé)

```
Email: staff1@tech-store.com
Password: Staff123!
Tenant: Tech Store
```

**Accès :**
- ✅ Tout Customer +
- ✅ Dashboard merchant
- ✅ Gestion produits
- ✅ Gestion commandes

---

### Merchant Owner (Propriétaire)

```
Email: merchant1@tech-store.com
Password: Merchant123!
Tenant: Tech Store
```

**Accès :**
- ✅ Tout Staff +
- ✅ Gestion équipe
- ✅ Onboarding
- ✅ Invitations

---

### Platform Admin (Administrateur)

```
Email: admin@example.com
Password: Admin123!
Tenant: Default
```

**Accès :**
- ✅ Accès total
- ✅ Multi-tenant

---

## 🧪 TESTS RAPIDES

### Test 1 : Connexion Customer

```bash
# 1. Ouvrir http://localhost:3000
# 2. Cliquer "Connexion"
# 3. Email: customer1@example.com
# 4. Password: Customer123!
# 5. Vérifier redirection vers /orders
```

**✅ Attendu :** Connexion réussie, message "Bonjour, Customer 1" dans TopBar

---

### Test 2 : Navigation et Recherche

```bash
# 1. Connecté en customer1
# 2. Cliquer sur "Produits" dans la navbar
# 3. Taper "iPhone" dans la barre de recherche
# 4. Appuyer sur Entrée
```

**✅ Attendu :** 1 produit "iPhone 15 Pro" affiché

---

### Test 3 : Favoris

```bash
# 1. Connecté en customer1
# 2. Aller sur /products
# 3. Survoler un produit
# 4. Cliquer sur le cœur
# 5. Cliquer sur "Favoris" dans le menu utilisateur (TopBar)
```

**✅ Attendu :** 
- Message "Produit ajouté aux favoris"
- Page /favorites affiche le produit (+ ceux du seeding)

---

### Test 4 : Mise à Jour Profil

```bash
# 1. Connecté en customer1
# 2. Menu utilisateur → Paramètres
# 3. Modifier "Nom complet" → "Jean Dupont"
# 4. Cliquer "Mettre à jour le profil"
```

**✅ Attendu :** Message "Profil mis à jour avec succès"

---

### Test 5 : Dashboard Merchant

```bash
# 1. Se déconnecter
# 2. Se connecter avec staff1@tech-store.com / Staff123!
# 3. Cliquer sur "Dashboard" dans la navbar
```

**✅ Attendu :** 
- Dashboard complet affiché
- 4 KPIs (CA, Commandes, Panier, Produits)
- Graphique Recharts
- Top 5 Produits

---

## 🐛 DÉPANNAGE

### Problème : Services ne démarrent pas

```bash
# Vérifier les logs
docker-compose logs -f

# Redémarrer proprement
docker-compose down
docker-compose up -d
```

---

### Problème : Page favoris erreur

**Solution :** Bug corrigé dans v1.1.0

```bash
# Vérifier la version du fichier
cat frontend/app/favorites/page.tsx | grep "reviewCount"

# Si absent, récupérer la dernière version
git pull origin main
```

---

### Problème : Mise à jour profil échoue

**Solution :** Bug corrigé dans v1.1.0

```bash
# Vérifier les logs auth-service
docker-compose logs -f auth-service

# Redémarrer auth-service
docker-compose restart auth-service
```

---

### Problème : Pas de données après seeding

```bash
# Réinitialiser complètement
docker-compose down -v  # ⚠️ Supprime les volumes
docker-compose up -d
sleep 30
./scripts/init-complete-data.sh
```

---

## 📊 VÉRIFICATION DE LA SANTÉ

### Health Checks

```bash
# Auth Service
curl http://localhost:8000/health
# Attendu: {"status":"healthy"}

# Product Service
curl http://localhost:4000/health
# Attendu: {"status":"ok"}

# Frontend
curl http://localhost:3000
# Attendu: HTML de la page d'accueil
```

---

### Vérification Base de Données

```bash
# Connexion PostgreSQL
docker-compose exec postgres psql -U saas_admin -d saas_platform

# Compter les utilisateurs
SELECT COUNT(*) FROM users;
# Attendu: 11

# Compter les produits
SELECT COUNT(*) FROM products;
# Attendu: 16

# Compter les favoris
SELECT COUNT(*) FROM favorites;
# Attendu: ~5

# Compter les avis
SELECT COUNT(*) FROM reviews;
# Attendu: ~10-15

# Quitter
\q
```

---

## 🔄 COMMANDES UTILES

### Gestion des Services

```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Redémarrer un service
docker-compose restart frontend

# Voir les logs
docker-compose logs -f auth-service

# Voir tous les logs
docker-compose logs -f

# Reconstruire les images
docker-compose build --no-cache
docker-compose up -d
```

---

### Gestion des Données

```bash
# Seeding complet
./scripts/init-complete-data.sh

# Seeding favoris et avis seulement
cat scripts/seed-complete-data.sql | docker-compose exec -T postgres psql -U saas_admin -d saas_platform

# Seeding commandes
python3 scripts/seed-orders.py

# Réinitialiser TOUTES les données
docker-compose down -v
docker-compose up -d
./scripts/init-complete-data.sh
```

---

### Développement Frontend

```bash
# Entrer dans le container frontend
docker-compose exec frontend sh

# Installer une dépendance
npm install <package>

# Rebuild
docker-compose restart frontend
```

---

## 📚 DOCUMENTATION COMPLÈTE

- 📖 [README.md](../README.md) - Vue d'ensemble du projet
- 🐛 [CORRECTIONS-BUGS-CRITIQUES.md](CORRECTIONS-BUGS-CRITIQUES.md) - Détails des corrections
- 📋 [CHANGELOG-CORRECTIONS.md](CHANGELOG-CORRECTIONS.md) - Liste des modifications
- 🧪 [PLAN-TESTS-MANUELS.md](PLAN-TESTS-MANUELS.md) - Plan de tests complet
- 📊 [RAPPORT-TESTS-SESSION-3-FINAL.md](RAPPORT-TESTS-SESSION-3-FINAL.md) - Dernier rapport de tests

---

## 🎯 PROCHAINES ÉTAPES

Après avoir testé l'application :

1. ✅ Lire le [CHANGELOG-CORRECTIONS.md](CHANGELOG-CORRECTIONS.md)
2. ✅ Exécuter les tests du [PLAN-TESTS-MANUELS.md](PLAN-TESTS-MANUELS.md)
3. ✅ Personnaliser les données de seeding si nécessaire
4. ✅ Configurer les variables d'environnement pour la production
5. ✅ Ajouter des tests E2E automatisés (Playwright/Cypress)

---

## 💡 CONSEILS

### Performance

- ✅ Les images Docker sont optimisées (multi-stage builds)
- ✅ Redis cache les tokens JWT
- ✅ PostgreSQL indexé sur les colonnes critiques

### Sécurité

- ⚠️ Changer les mots de passe par défaut en production
- ⚠️ Configurer HTTPS avec un reverse proxy (Nginx)
- ⚠️ Activer rate limiting sur l'API Gateway

### Monitoring

- 📊 Ajouter Prometheus + Grafana pour métriques
- 📝 Centraliser les logs avec ELK Stack
- 🚨 Configurer des alertes (Sentry, Datadog)

---

## 📞 SUPPORT

**Questions ?** Consultez la documentation ou ouvrez une issue sur GitHub.

**Bugs ?** Vérifiez d'abord [CORRECTIONS-BUGS-CRITIQUES.md](CORRECTIONS-BUGS-CRITIQUES.md)

---

**FIN DU GUIDE**

> 🎉 **Bon développement !** L'application est maintenant prête à être testée et déployée.
