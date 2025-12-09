# 🔧 PLAN DE CORRECTIONS DES BUGS

**Date :** 8 décembre 2025  
**Objectif :** Corriger les 2 bugs identifiés + ajouter fixtures + améliorer design

---

## 🐛 BUG-001 : Page Favoris Cassée (MAJEUR)

### Cause Racine
L'endpoint `/favorites` n'existe pas dans le product-service, causant une erreur 404 ou 500.

### Solution
Créer l'endpoint GET `/favorites` dans product-service qui retourne la liste des produits favoris de l'utilisateur.

### Fichiers à Modifier
1. `product-service/src/routes/favorites.routes.ts` (à créer)
2. `product-service/src/controllers/favorites.controller.ts` (à créer)
3. `product-service/src/services/favorites.service.ts` (à créer)
4. `product-service/src/app.ts` (ajouter la route)

### Acceptation
- ✅ GET `/favorites` retourne la liste des produits favoris
- ✅ La page `/favorites` s'affiche sans erreur
- ✅ Les produits favoris sont affichés correctement

---

## 🐛 BUG-002 : Mise à Jour Profil Échoue (MINEUR)

### Cause Racine
L'endpoint `/api/v1/users/me` n'existe pas dans auth-service.

### Solution
Créer les endpoints :
- GET `/api/v1/users/me` : Récupérer le profil utilisateur
- PATCH `/api/v1/users/me` : Mettre à jour le profil
- PATCH `/api/v1/users/me/password` : Changer le mot de passe

### Fichiers à Créer/Modifier
1. `auth-service/app/routers/users.py` (à créer)
2. `auth-service/app/services/user_service.py` (à créer)
3. `auth-service/app/main.py` (ajouter la route)

### Acceptation
- ✅ GET `/api/v1/users/me` retourne les infos utilisateur
- ✅ PATCH `/api/v1/users/me` met à jour le profil
- ✅ PATCH `/api/v1/users/me/password` change le mot de passe
- ✅ La page `/profile` fonctionne correctement

---

## 📦 FIXTURES & SEEDING

### Objectif
Alimenter les bases de données avec des données réalistes au démarrage.

### Données à Créer

#### Auth Service (PostgreSQL)
- ✅ 3 tenants (Default, Tech Store, Fashion Boutique)
- ✅ 11 utilisateurs (admins, owners, staff, customers)

#### Product Service (SQLite)
- 🔄 20 produits variés par tenant
  - Tech Store : 10 produits électronique
  - Fashion Boutique : 10 produits mode
- 🔄 Catégories réalistes
- 🔄 Images produits (URLs)
- 🔄 Stock et prix variés

#### Order Service (SQLite)
- 🔄 10 commandes de test
- 🔄 Différents statuts (pending, processing, shipped, delivered)
- 🔄 Historique réaliste

### Fichiers à Créer
1. `scripts/seed-products.ts` (NestJS)
2. `scripts/seed-orders.ts` (NestJS)
3. `docker-compose.yml` (ajouter commandes de seeding)

---

## 🎨 AMÉLIORATION DESIGN FRONTEND

### Navbar E-Commerce (2 niveaux)

#### Niveau 1 : Top Bar
- Logo + Nom du site
- Barre de recherche centrale
- Icônes : Favoris, Panier (avec badge), Profil

#### Niveau 2 : Navigation
- Catégories produits
- Liens contextuels selon rôle
- Mega menu pour catégories

### Pages Produits
- Grid responsive (4 colonnes desktop, 2 tablette, 1 mobile)
- Cards produits améliorées :
  - Image grande taille
  - Badge "Nouveau" / "Promo"
  - Note étoiles visible
  - Bouton "Ajouter au panier" prominent
  - Icône favoris en overlay

### Catalogue
- Filtres latéraux (catégorie, prix, note)
- Tri avancé
- Pagination
- Breadcrumbs

### Fichiers à Modifier
1. `frontend/components/Header.tsx`
2. `frontend/components/products/ProductCard.tsx`
3. `frontend/components/products/ProductGrid.tsx`
4. `frontend/app/products/page.tsx`

---

## 📋 ORDRE D'EXÉCUTION

### Phase 1 : Corrections Bugs (Priorité P0)
1. ✅ Créer endpoint users/me dans auth-service
2. ✅ Créer endpoint favorites dans product-service
3. ✅ Tester les deux corrections

### Phase 2 : Fixtures (Priorité P1)
4. ✅ Créer script de seeding produits
5. ✅ Créer script de seeding commandes
6. ✅ Intégrer dans docker-compose

### Phase 3 : Design (Priorité P2)
7. ✅ Refonte navbar 2 niveaux
8. ✅ Amélioration cards produits
9. ✅ Amélioration page catalogue

### Phase 4 : Tests (Priorité P1)
10. ✅ Tests manuels complets
11. ✅ Vérification des fixtures
12. ✅ Validation design responsive

---

## 🎯 CRITÈRES DE SUCCÈS

### Fonctionnel
- ✅ Aucune erreur client-side sur /favorites
- ✅ Mise à jour profil fonctionne
- ✅ Changement mot de passe fonctionne
- ✅ Données réalistes au démarrage
- ✅ 20+ produits visibles
- ✅ 10+ commandes de test

### UX/Design
- ✅ Navbar professionnelle e-commerce
- ✅ Cards produits attractives
- ✅ Navigation intuitive
- ✅ Responsive mobile/desktop
- ✅ Pas d'erreurs console

### Performance
- ✅ Pages chargent en < 2s
- ✅ Pas de memory leaks
- ✅ Images optimisées

---

**Temps estimé total :** 4-6 heures
**Priorité :** P0 (Critique pour déploiement)

