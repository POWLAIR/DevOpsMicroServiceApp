# Plan de Tests Manuels - Validation des Rôles et Fonctionnalités

> Document de tests manuels pour valider l'accès et le fonctionnement des fonctionnalités par rôle sur l'interface web

**Version :** 1.0  
**Date :** 8 décembre 2025  
**Projet :** DevOps MicroService App

---

## Table des Matières

1. [Prérequis et Configuration](#prérequis-et-configuration)
2. [Comptes de Test](#comptes-de-test)
3. [Tests par Rôle](#tests-par-rôle)
   - [Customer](#tests-customer)
   - [Merchant Staff](#tests-merchant-staff)
   - [Merchant Owner](#tests-merchant-owner)
   - [Platform Admin](#tests-platform-admin)
4. [Scénarios de Test Complets](#scénarios-de-test-complets)
5. [Matrice de Validation](#matrice-de-validation)
6. [Template de Rapport](#template-de-rapport)

---

## Prérequis et Configuration

### Services à Démarrer

**Option 1 : Docker Compose (Recommandé)**

```bash
cd /home/paul/efrei-project/DevOpsMicroServiceApp
docker-compose up -d
```

**Option 2 : Services Individuels**

```bash
# Auth Service (Port 8000)
cd auth-service
python -m uvicorn app.main:app --reload --port 8000

# Product Service (Port 8001)
cd product-service
npm run start:dev

# Order Service (Port 8002)
cd order-service
npm run start:dev

# Payment Service (Port 8003)
cd payment-service
go run main.go

# Notification Service (Port 8004)
cd notification-service
python -m uvicorn app.main:app --reload --port 8004

# Tenant Service (Port 8005)
cd tenant-service
npm run start:dev

# Frontend (Port 3000)
cd frontend
npm run dev
```

### URLs de Test

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | <http://localhost:3000> | Interface utilisateur |
| Auth Service | <http://localhost:8000> | API Authentification |
| Product Service | <http://localhost:8001> | API Produits |
| Order Service | <http://localhost:8002> | API Commandes |
| Payment Service | <http://localhost:8003> | API Paiements |
| Notification Service | <http://localhost:8004> | API Notifications |
| Tenant Service | <http://localhost:8005> | API Tenants |

### Vérification des Services

Vérifier que tous les services sont opérationnels :

```bash
# Health checks
curl http://localhost:8000/health  # Auth
curl http://localhost:8001/health  # Product
curl http://localhost:8002/health  # Order
curl http://localhost:8003/health  # Payment
curl http://localhost:8004/health  # Notification
curl http://localhost:8005/health  # Tenant
```

### Navigateurs Recommandés

- ✅ Chrome/Chromium (version récente)
- ✅ Firefox (version récente)
- ✅ Edge (version récente)
- ⚠️ Safari (à tester si disponible)

### Outils Utiles

- **DevTools** : F12 pour inspecter requêtes réseau et console
- **Extensions** :
  - Redux DevTools (si applicable)
  - React Developer Tools
  - JSON Viewer

---

## Comptes de Test

Les comptes suivants sont créés automatiquement par le seeding au démarrage de `auth-service`.

### 👑 Platform Admin

```
Email    : admin@example.com
Password : Admin123!
Role     : platform_admin
Tenant   : N/A (accès global)
```

### 🏪 Merchant Owner - Tech Store

```
Email    : merchant1@tech-store.com
Password : Merchant123!
Role     : merchant_owner
Tenant   : Tech Store
```

### 👔 Merchant Staff - Tech Store

```
Email    : staff1@tech-store.com
Password : Staff123!
Role     : merchant_staff
Tenant   : Tech Store
```

### 🏪 Merchant Owner - Fashion Boutique

```
Email    : merchant2@fashion-boutique.com
Password : Merchant123!
Role     : merchant_owner
Tenant   : Fashion Boutique
```

### 👔 Merchant Staff - Fashion Boutique

```
Email    : staff2@fashion-boutique.com
Password : Staff123!
Role     : merchant_staff
Tenant   : Fashion Boutique
```

### 🛒 Customer 1

```
Email    : customer1@example.com
Password : Customer123!
Role     : customer
Tenant   : N/A (peut acheter sur tous les tenants)
```

### 🛒 Customer 2

```
Email    : customer2@example.com
Password : Customer123!
Role     : customer
Tenant   : N/A (peut acheter sur tous les tenants)
```

---

## Tests par Rôle

### Tests Customer

**Compte de test :** `customer1@example.com` / `Customer123!`

#### A. Tests d'Authentification

| ID | Test | Steps | Résultat Attendu | Status |
|----|------|-------|------------------|--------|
| C-AUTH-001 | Connexion réussie | 1. Aller sur /login<br>2. Entrer email/password<br>3. Cliquer "Se connecter" | Redirection vers / ou /products<br>Token JWT stocké<br>Header affiche email | [ ] |
| C-AUTH-002 | Connexion échouée | 1. /login<br>2. Mauvais credentials<br>3. Submit | Message d'erreur affiché<br>Toast rouge<br>Pas de redirection | [ ] |
| C-AUTH-003 | Déconnexion | 1. Connecté<br>2. Clic "Déconnexion" | Redirection vers /<br>Token supprimé<br>Header mode non-auth | [ ] |

#### B. Tests de Navigation

| ID | Test | Vérification | Status |
|----|------|--------------|--------|
| C-NAV-001 | Header - Liens visibles | Accueil, Produits, Favoris, Commandes, Mon Profil, Notifications (avec badge) | [ ] |
| C-NAV-002 | Header - Liens masqués | Dashboard, Équipe, Paiements ne sont PAS visibles | [ ] |
| C-NAV-003 | Barre de recherche | Visible dans header (desktop), fonctionnelle | [ ] |
| C-NAV-004 | Badge panier | Affiche nombre d'articles, cliquable vers /cart | [ ] |
| C-NAV-005 | Badge notifications | Affiche compteur non lus, cliquable vers /notifications | [ ] |
| C-NAV-006 | Breadcrumbs | Affichés sur chaque page avec chemin correct | [ ] |
| C-NAV-007 | Menu mobile | Hamburger accessible, contient tous les liens | [ ] |

#### C. Tests d'Accès aux Pages

**Pages Accessibles ✅**

| Page | URL | Test | Status |
|------|-----|------|--------|
| Accueil | / | Catalogue visible, call-to-actions | [ ] |
| Catalogue | /products | Liste produits, recherche, filtres | [ ] |
| Détail Produit | /products/[id] | Détails, avis, boutons favoris/panier | [ ] |
| Favoris | /favorites | Liste des favoris, actions | [ ] |
| Panier | /cart | Articles, quantités, total | [ ] |
| Checkout | /checkout | Formulaire paiement, Stripe | [ ] |
| Commandes | /orders | Historique commandes personnelles | [ ] |
| Mon Profil | /profile | Formulaire profil + mot de passe | [ ] |
| Notifications | /notifications | Historique avec filtres | [ ] |

**Pages Interdites ❌ (Doivent rediriger vers /)**

| Page | URL | Test Redirection | Status |
|------|-----|------------------|--------|
| Dashboard | /dashboard | Accès → Redirection vers / | [ ] |
| Équipe | /team | Accès → Redirection vers / | [ ] |
| Paiements | /payments | Accès → Redirection vers / | [ ] |
| Onboarding | /onboarding | Accès → Redirection vers / | [ ] |

#### D. Tests des Fonctionnalités

**F-001 : Parcourir le Catalogue**

- **Pré-requis** : Authentifié
- **Steps** :
  1. Aller sur /products
  2. Vérifier liste de produits affichée
  3. Vérifier images chargées
  4. Vérifier prix affichés
- **Résultat attendu** : Catalogue complet visible
- **Status** : [ ]

**F-002 : Rechercher un Produit**

- **Pré-requis** : Sur /products
- **Steps** :
  1. Utiliser barre de recherche (header)
  2. Entrer "laptop" par exemple
  3. Soumettre recherche
- **Résultat attendu** : Redirection vers /products?search=laptop, résultats filtrés
- **Status** : [ ]

**F-003 : Ajouter aux Favoris**

- **Pré-requis** : Sur page produit
- **Steps** :
  1. Aller sur /products/[id]
  2. Cliquer icône cœur "Ajouter aux favoris"
  3. Vérifier toast de confirmation
  4. Aller sur /favorites
- **Résultat attendu** : Toast "Ajouté aux favoris", produit visible dans /favorites
- **Status** : [ ]

**F-004 : Retirer des Favoris**

- **Pré-requis** : Produit dans favoris
- **Steps** :
  1. Aller sur /favorites
  2. Cliquer "Retirer" sur un produit
  3. Vérifier toast
- **Résultat attendu** : Toast confirmation, produit retiré de la liste
- **Status** : [ ]

**F-005 : Ajouter au Panier**

- **Pré-requis** : Sur page produit
- **Steps** :
  1. /products/[id]
  2. Cliquer "Ajouter au panier"
  3. Vérifier badge panier +1
  4. Aller sur /cart
- **Résultat attendu** : Badge mis à jour, produit dans panier avec quantité 1
- **Status** : [ ]

**F-006 : Modifier Quantité Panier**

- **Pré-requis** : Produit dans panier
- **Steps** :
  1. /cart
  2. Modifier quantité (+ ou -)
  3. Vérifier total mis à jour
- **Résultat attendu** : Quantité changée, total recalculé
- **Status** : [ ]

**F-007 : Retirer du Panier**

- **Pré-requis** : Produit dans panier
- **Steps** :
  1. /cart
  2. Cliquer bouton retirer
  3. Vérifier badge panier
- **Résultat attendu** : Produit retiré, badge -1, total recalculé
- **Status** : [ ]

**F-008 : Processus de Paiement (Checkout)**

- **Pré-requis** : Panier avec articles
- **Steps** :
  1. /cart → Clic "Procéder au paiement"
  2. Redirection /checkout
  3. Remplir infos livraison
  4. Entrer infos carte test Stripe
  5. Valider paiement
- **Résultat attendu** : Redirection vers /orders, commande créée, email envoyé
- **Status** : [ ]

**F-009 : Voir Historique Commandes**

- **Pré-requis** : Commandes existantes
- **Steps** :
  1. /orders
  2. Vérifier liste des commandes
  3. Vérifier filtres statut
- **Résultat attendu** : Liste avec ID, date, total, statut pour UNIQUEMENT ses commandes
- **Status** : [ ]

**F-010 : Détail d'une Commande**

- **Pré-requis** : Sur /orders
- **Steps** :
  1. Cliquer sur une commande
  2. Voir détails (articles, quantités, total)
- **Résultat attendu** : Détails complets affichés
- **Status** : [ ]

**F-011 : Laisser un Avis**

- **Pré-requis** : Produit acheté
- **Steps** :
  1. /products/[id] d'un produit acheté
  2. Remplir formulaire avis (note, commentaire)
  3. Soumettre
- **Résultat attendu** : Toast confirmation, avis affiché sur la page
- **Status** : [ ]

**F-012 : Modifier Profil**

- **Pré-requis** : Authentifié
- **Steps** :
  1. /profile
  2. Modifier nom complet
  3. Modifier email
  4. Cliquer "Mettre à jour"
- **Résultat attendu** : Toast succès, données mises à jour, skeleton pendant chargement
- **Status** : [ ]

**F-013 : Changer Mot de Passe**

- **Pré-requis** : Sur /profile
- **Steps** :
  1. Section "Changer mot de passe"
  2. Entrer mot de passe actuel
  3. Entrer nouveau mot de passe (2x)
  4. Soumettre
- **Résultat attendu** : Toast succès, champs vidés
- **Status** : [ ]

**F-014 : Voir Notifications**

- **Pré-requis** : Notifications reçues
- **Steps** :
  1. /notifications
  2. Voir liste historique
  3. Tester filtres type/statut
- **Résultat attendu** : Historique complet avec filtres fonctionnels
- **Status** : [ ]

**F-015 : Badge Notifications Temps Réel**

- **Pré-requis** : Authentifié
- **Steps** :
  1. Vérifier badge dans header
  2. Simuler réception notification
  3. Vérifier compteur +1
- **Résultat attendu** : Badge affiche nombre non lus, se met à jour
- **Status** : [ ]

**F-016 : Skeleton Loading**

- **Pré-requis** : N/A
- **Steps** :
  1. Charger une page avec données (profil, commandes, etc.)
  2. Observer pendant chargement
- **Résultat attendu** : Skeleton UI affiché (pas "Chargement...")
- **Status** : [ ]

**F-017 : Toast Notifications**

- **Pré-requis** : N/A
- **Steps** :
  1. Effectuer une action (ajout panier, update profil, etc.)
  2. Observer notification
- **Résultat attendu** : Toast avec react-hot-toast (top-right), couleurs succès/erreur
- **Status** : [ ]

**F-018 : Responsive Design**

- **Pré-requis** : N/A
- **Steps** :
  1. Tester sur mobile (DevTools responsive)
  2. Tester sur tablette
  3. Tester sur desktop
- **Résultat attendu** : Layout adapté, menu hamburger sur mobile
- **Status** : [ ]

**F-019 : Dark Mode**

- **Pré-requis** : N/A
- **Steps** :
  1. Vérifier si dark mode disponible
  2. Changer préférence système
  3. Vérifier adaptation couleurs
- **Résultat attendu** : Dark mode natif (Tailwind) s'adapte
- **Status** : [ ]

**F-020 : Progress Bar Navigation**

- **Pré-requis** : N/A
- **Steps** :
  1. Naviguer entre pages
  2. Observer barre bleue en haut
- **Résultat attendu** : NProgress bar bleue s'affiche pendant navigation
- **Status** : [ ]

---

### Tests Merchant Staff

**Compte de test :** `staff1@tech-store.com` / `Staff123!`

#### A. Tests d'Authentification

| ID | Test | Steps | Résultat Attendu | Status |
|----|------|-------|------------------|--------|
| S-AUTH-001 | Connexion réussie | 1. /login<br>2. Credentials staff<br>3. Submit | Redirection vers /dashboard<br>Token stocké | [ ] |
| S-AUTH-002 | Vérification rôle | 1. Connecté<br>2. Aller sur /profile | Role = merchant_staff affiché | [ ] |

#### B. Tests de Navigation

| ID | Test | Vérification | Status |
|----|------|--------------|--------|
| S-NAV-001 | Header - Liens visibles | Accueil, Produits, **Dashboard**, Favoris, Commandes, Profil, Notifications | [ ] |
| S-NAV-002 | Header - Liens masqués | **Équipe** ne doit PAS être visible | [ ] |
| S-NAV-003 | Dashboard accessible | Lien Dashboard cliquable, redirige vers /dashboard | [ ] |

#### C. Tests d'Accès aux Pages

**Pages Accessibles ✅**

| Page | URL | Test | Status |
|------|-----|------|--------|
| Dashboard | /dashboard | KPIs, graphiques, top produits affichés | [ ] |
| Paiements | /payments | Historique paiements du tenant, export CSV | [ ] |
| Produits (gestion) | /products | Peut ajouter/modifier/supprimer produits | [ ] |
| Commandes (merchant) | /orders | Toutes commandes du tenant, peut modifier statut | [ ] |

**Pages Interdites ❌**

| Page | URL | Test Redirection | Status |
|------|-----|------------------|--------|
| Équipe | /team | Accès → Redirection vers / | [ ] |

#### D. Tests des Fonctionnalités

**F-021 : Accès Dashboard**

- **Pré-requis** : Authentifié as staff
- **Steps** :
  1. Cliquer Dashboard dans header
  2. Vérifier /dashboard affiché
  3. Vérifier sections présentes
- **Résultat attendu** : Dashboard complet visible
- **Status** : [ ]

**F-022 : KPIs Dashboard**

- **Pré-requis** : Sur /dashboard
- **Steps** :
  1. Vérifier 4 cartes KPI
  2. Chiffre d'affaires
  3. Nombre commandes
  4. Panier moyen
  5. Nombre produits
- **Résultat attendu** : 4 StatsCard avec valeurs correctes
- **Status** : [ ]

**F-023 : Commission Plateforme**

- **Pré-requis** : Sur /dashboard
- **Steps** :
  1. Vérifier section commission (5%)
  2. Vérifier calcul : Total Brut, Commission, Net
- **Résultat attendu** : Calculs corrects, affichage clair
- **Status** : [ ]

**F-024 : Graphique Ventes**

- **Pré-requis** : Sur /dashboard
- **Steps** :
  1. Vérifier graphique Recharts
  2. Vérifier 6 derniers mois
  3. Vérifier 2 courbes (CA + Commandes)
- **Résultat attendu** : Graphique interactif, données cohérentes
- **Status** : [ ]

**F-025 : Top 5 Produits**

- **Pré-requis** : Sur /dashboard
- **Steps** :
  1. Vérifier tableau top produits
  2. Vérifier colonnes : nom, quantité, CA
  3. Vérifier tri par quantité
- **Résultat attendu** : Top 5 affiché, données correctes
- **Status** : [ ]

**F-026 : Actions Rapides Dashboard**

- **Pré-requis** : Sur /dashboard
- **Steps** :
  1. Cliquer "Gérer commandes"
  2. Cliquer "Gérer produits"
  3. Cliquer "Voir paiements"
- **Résultat attendu** : Redirections vers /orders, /products, /payments
- **Status** : [ ]

**F-027 : Gérer Produits - Ajouter**

- **Pré-requis** : Authentifié staff, sur /products
- **Steps** :
  1. Cliquer "Ajouter produit"
  2. Remplir formulaire (nom, prix, stock, catégorie)
  3. Upload image
  4. Soumettre
- **Résultat attendu** : Toast succès, produit créé dans DB et affiché
- **Status** : [ ]

**F-028 : Gérer Produits - Modifier**

- **Pré-requis** : Produit existant
- **Steps** :
  1. Sur /products
  2. Cliquer "Modifier" sur un produit
  3. Changer prix/stock
  4. Soumettre
- **Résultat attendu** : Toast succès, modifications enregistrées
- **Status** : [ ]

**F-029 : Gérer Produits - Supprimer**

- **Pré-requis** : Produit existant
- **Steps** :
  1. Cliquer "Supprimer"
  2. Confirmer
- **Résultat attendu** : Produit supprimé, toast confirmation
- **Status** : [ ]

**F-030 : Voir Commandes Tenant**

- **Pré-requis** : Sur /orders
- **Steps** :
  1. Vérifier liste commandes
  2. Vérifier TOUTES commandes du tenant affichées
  3. Vérifier filtre par statut
- **Résultat attendu** : Liste complète du tenant uniquement
- **Status** : [ ]

**F-031 : Modifier Statut Commande**

- **Pré-requis** : Commande "En attente"
- **Steps** :
  1. /orders
  2. Sélectionner commande
  3. Changer statut "En attente" → "Confirmée"
  4. Vérifier notification email client
- **Résultat attendu** : Statut mis à jour, email envoyé
- **Status** : [ ]

**F-032 : Voir Historique Paiements**

- **Pré-requis** : Sur /payments
- **Steps** :
  1. Vérifier liste paiements
  2. Vérifier colonnes : ID, Commande, Montant, Commission, Net, Statut, Date
- **Résultat attendu** : Historique complet du tenant
- **Status** : [ ]

**F-033 : Résumé Financier**

- **Pré-requis** : Sur /payments
- **Steps** :
  1. Vérifier 3 cartes résumé
  2. Total Brut
  3. Commission 5%
  4. Total Net
- **Résultat attendu** : Calculs corrects
- **Status** : [ ]

**F-034 : Export CSV Paiements**

- **Pré-requis** : Paiements existants
- **Steps** :
  1. /payments
  2. Cliquer "Exporter CSV"
  3. Vérifier fichier téléchargé
  4. Ouvrir CSV
- **Résultat attendu** : Fichier CSV valide avec toutes colonnes
- **Status** : [ ]

**F-035 : Isolation Tenant**

- **Pré-requis** : 2 tenants avec données
- **Steps** :
  1. Connecté en <staff1@tech-store.com>
  2. Vérifier dashboard ne montre QUE Tech Store
  3. Vérifier commandes ne montrent QUE Tech Store
  4. Se déconnecter
  5. Connecter <staff2@fashion-boutique.com>
  6. Vérifier données Fashion Boutique uniquement
- **Résultat attendu** : Isolation complète, pas de fuite de données
- **Status** : [ ]

**F-036 : Tentative Accès Équipe**

- **Pré-requis** : Authentifié staff
- **Steps** :
  1. Taper manuellement URL /team
  2. Observer résultat
- **Résultat attendu** : Redirection automatique vers /, toast optionnel
- **Status** : [ ]

**F-037 : Breadcrumbs Dashboard**

- **Pré-requis** : Sur /dashboard
- **Steps** :
  1. Vérifier breadcrumbs affichés
  2. Cliquer sur "Accueil" dans breadcrumbs
- **Résultat attendu** : Breadcrumbs "Accueil / Dashboard", navigation fonctionnelle
- **Status** : [ ]

**F-038 : Skeleton Dashboard**

- **Pré-requis** : N/A
- **Steps** :
  1. Aller sur /dashboard
  2. Observer chargement initial
- **Résultat attendu** : Skeleton UI (pas "Chargement...")
- **Status** : [ ]

**F-039 : Responsive Dashboard**

- **Pré-requis** : N/A
- **Steps** :
  1. Ouvrir /dashboard
  2. Tester responsive (mobile/tablette/desktop)
  3. Vérifier graphique Recharts responsive
- **Résultat attendu** : Layout adapté, graphique lisible
- **Status** : [ ]

**F-040 : Actions Toasts Staff**

- **Pré-requis** : N/A
- **Steps** :
  1. Effectuer actions (ajout produit, update commande, etc.)
  2. Vérifier toasts affichés
- **Résultat attendu** : Toast succès/erreur pour chaque action
- **Status** : [ ]

---

### Tests Merchant Owner

**Compte de test :** `merchant1@tech-store.com` / `Merchant123!`

#### A. Tests d'Authentification

| ID | Test | Steps | Résultat Attendu | Status |
|----|------|-------|------------------|--------|
| O-AUTH-001 | Connexion réussie | 1. /login<br>2. Credentials owner<br>3. Submit | Redirection vers /dashboard<br>Token stocké | [ ] |
| O-AUTH-002 | Vérification rôle | 1. Connecté<br>2. /profile | Role = merchant_owner | [ ] |

#### B. Tests de Navigation

| ID | Test | Vérification | Status |
|----|------|--------------|--------|
| O-NAV-001 | Header complet | Accueil, Produits, Dashboard, **Équipe**, Favoris, Commandes, Profil, Notifications | [ ] |
| O-NAV-002 | Lien Équipe visible | Lien "Équipe" présent dans header | [ ] |
| O-NAV-003 | Accès Équipe | Clic Équipe → /team accessible | [ ] |

#### C. Tests d'Accès aux Pages

**Toutes pages Staff + Équipe ✅**

| Page | URL | Test | Status |
|------|-----|------|--------|
| Équipe | /team | Liste membres, invitation, actions | [ ] |
| Onboarding | /onboarding | Wizard 5 étapes | [ ] |

#### D. Tests des Fonctionnalités

**F-041 : Toutes Fonctionnalités Staff**

- **Pré-requis** : Authentifié owner
- **Steps** : Vérifier toutes fonctionnalités F-021 à F-040 fonctionnent
- **Résultat attendu** : Identique à Staff
- **Status** : [ ]

**F-042 : Accès Page Équipe**

- **Pré-requis** : Authentifié owner
- **Steps** :
  1. Cliquer "Équipe" dans header
  2. Vérifier /team chargé
  3. Vérifier sections présentes
- **Résultat attendu** : Page équipe complète
- **Status** : [ ]

**F-043 : Voir Liste Membres**

- **Pré-requis** : Sur /team
- **Steps** :
  1. Vérifier tableau membres
  2. Colonnes : Utilisateur, Rôle, Statut, Email vérifié, Actions
  3. Vérifier son propre compte visible
- **Résultat attendu** : Liste complète du tenant
- **Status** : [ ]

**F-044 : Inviter Nouveau Membre**

- **Pré-requis** : Sur /team
- **Steps** :
  1. Cliquer "Inviter un membre"
  2. Formulaire affiché
  3. Remplir : email (<test@test.com>), nom (Test User), rôle (Staff)
  4. Soumettre
  5. Vérifier toast succès
  6. Vérifier membre ajouté liste
- **Résultat attendu** : Membre créé, email invitation envoyé, statut "Inactif"
- **Status** : [ ]

**F-045 : Email Invitation**

- **Pré-requis** : Invitation envoyée
- **Steps** :
  1. Vérifier email reçu (ou logs notification-service)
  2. Vérifier contenu : email, mot de passe temporaire
- **Résultat attendu** : Email invitation envoyé via notification-service
- **Status** : [ ]

**F-046 : Désactiver Membre**

- **Pré-requis** : Membre actif (pas soi-même)
- **Steps** :
  1. /team
  2. Cliquer "Désactiver" sur un membre
  3. Vérifier toast
  4. Vérifier statut "Inactif"
  5. Vérifier badge rouge
- **Résultat attendu** : Membre désactivé, ne peut plus se connecter
- **Status** : [ ]

**F-047 : Réactiver Membre**

- **Pré-requis** : Membre inactif
- **Steps** :
  1. /team
  2. Cliquer "Activer"
  3. Vérifier toast
  4. Vérifier statut "Actif"
- **Résultat attendu** : Membre réactivé, peut se connecter
- **Status** : [ ]

**F-048 : Impossible Modifier Soi-Même Statut**

- **Pré-requis** : Sur /team
- **Steps** :
  1. Trouver son propre compte
  2. Vérifier pas de bouton "Désactiver"
  3. Tenter via API directe si possible
- **Résultat attendu** : Bouton absent, API refuse (403)
- **Status** : [ ]

**F-049 : Impossible Modifier Soi-Même Rôle**

- **Pré-requis** : Sur /team
- **Steps** :
  1. Trouver son propre compte
  2. Vérifier pas d'option modifier rôle
  3. Tenter via API si possible
- **Résultat attendu** : Option absente, API refuse
- **Status** : [ ]

**F-050 : Badges Rôles**

- **Pré-requis** : /team avec Owner et Staff
- **Steps** :
  1. Vérifier badge Owner (violet)
  2. Vérifier badge Staff (bleu)
  3. Vérifier lisibilité
- **Résultat attendu** : Badges colorés distincts
- **Status** : [ ]

**F-051 : Onboarding Étape 1 - Infos**

- **Pré-requis** : Accès /onboarding
- **Steps** :
  1. Vérifier formulaire infos boutique
  2. Nom boutique (requis)
  3. Logo URL (optionnel)
  4. Bouton "Suivant" actif
- **Résultat attendu** : Formulaire fonctionnel, validation requise
- **Status** : [ ]

**F-052 : Onboarding Étape 2 - Plan**

- **Pré-requis** : Étape 1 OK
- **Steps** :
  1. Vérifier 4 plans affichés
  2. Sélectionner un plan (highlight)
  3. Vérifier détails plan (prix, features)
- **Résultat attendu** : Plans clairs, sélection visuelle
- **Status** : [ ]

**F-053 : Onboarding Étape 3 - Config**

- **Pré-requis** : Étape 2 OK
- **Steps** :
  1. Champs domaine et description
  2. Remplir ou laisser vide
  3. Passage étape suivante
- **Résultat attendu** : Champs optionnels, navigation fluide
- **Status** : [ ]

**F-054 : Onboarding Étape 4 - Produits**

- **Pré-requis** : Étape 3 OK
- **Steps** :
  1. 2 options : Manuel ou CSV
  2. Sélectionner une option
  3. Option highlighted
- **Résultat attendu** : Sélection claire
- **Status** : [ ]

**F-055 : Onboarding Étape 5 - Équipe**

- **Pré-requis** : Étape 4 OK
- **Steps** :
  1. Ajouter emails (optionnel)
  2. Bouton "+ Ajouter membre"
  3. Bouton "Terminer"
  4. Vérifier redirection /dashboard
- **Résultat attendu** : Emails facultatifs, fin onboarding
- **Status** : [ ]

**F-056 : Onboarding Bouton Précédent**

- **Pré-requis** : Étape 2+
- **Steps** :
  1. Cliquer "Précédent" depuis chaque étape
  2. Vérifier données conservées
- **Résultat attendu** : Navigation arrière fluide, pas de perte données
- **Status** : [ ]

**F-057 : Onboarding Progress Visual**

- **Pré-requis** : Dans wizard
- **Steps** :
  1. Vérifier progress bar bleue
  2. Vérifier stepper avec 5 étapes
  3. Vérifier étapes complétées (checkmark vert)
- **Résultat attendu** : Feedback visuel clair de progression
- **Status** : [ ]

**F-058 : Onboarding Sauvegarde**

- **Pré-requis** : En cours wizard
- **Steps** :
  1. Compléter 2 étapes
  2. Fermer onglet
  3. Revenir /onboarding
  4. Vérifier reprise étape 3
- **Résultat attendu** : Sauvegarde auto, reprise où arrêté
- **Status** : [ ]

**F-059 : Gestion Équipe Complète**

- **Pré-requis** : /team
- **Steps** :
  1. Inviter membre
  2. Modifier rôle
  3. Désactiver/Activer
  4. Vérifier toasts
- **Résultat attendu** : Toutes actions équipe fonctionnelles
- **Status** : [ ]

**F-060 : Owner = Staff + Team**

- **Pré-requis** : Authentifié owner
- **Steps** :
  1. Tester TOUTES fonctionnalités F-021 à F-040
  2. Tester fonctionnalités équipe F-042 à F-059
- **Résultat attendu** : Toutes fonctionnent
- **Status** : [ ]

---

### Tests Platform Admin

**Compte de test :** `admin@example.com` / `Admin123!`

#### A. Tests d'Authentification

| ID | Test | Steps | Résultat Attendu | Status |
|----|------|-------|------------------|--------|
| A-AUTH-001 | Connexion admin | 1. /login<br>2. Credentials admin<br>3. Submit | Connexion OK, token stocké | [ ] |
| A-AUTH-002 | Vérification rôle | 1. Connecté<br>2. /profile | Role = platform_admin | [ ] |

#### B. Tests de Navigation

| ID | Test | Vérification | Status |
|----|------|--------------|--------|
| A-NAV-001 | Header - Accès total | Tous liens visibles y compris merchant | [ ] |
| A-NAV-002 | Accès toutes pages | Dashboard, Équipe, Paiements accessibles | [ ] |

#### C. Tests d'Accès aux Pages

**Toutes pages accessibles ✅**

| Page | URL | Test | Status |
|------|-----|------|--------|
| Toutes pages Customer | / → /notifications | Accès complet | [ ] |
| Toutes pages Merchant | /dashboard, /team, /payments, /onboarding | Accès complet | [ ] |
| Admin Panel (futur) | /admin | Si implémenté | [ ] |

#### D. Tests des Fonctionnalités

**F-061 : Accès Total**

- **Pré-requis** : Authentifié admin
- **Steps** :
  1. Tester accès à /dashboard
  2. Tester accès à /team
  3. Tester accès à /payments
  4. Tester toutes autres pages
- **Résultat attendu** : Aucune restriction
- **Status** : [ ]

**F-062 : Voir Données Multi-Tenant**

- **Pré-requis** : Admin sur dashboard/orders/etc
- **Steps** :
  1. Vérifier si peut voir données de tous tenants
  2. Ou si limité à un tenant comme owner
- **Résultat attendu** : Selon implémentation (documenter résultat)
- **Status** : [ ]

**F-063 : Toutes Fonctionnalités Customer**

- **Pré-requis** : Authentifié admin
- **Steps** : Vérifier F-001 à F-020 fonctionnent
- **Résultat attendu** : Toutes fonctionnalités customer disponibles
- **Status** : [ ]

**F-064 : Toutes Fonctionnalités Merchant**

- **Pré-requis** : Authentifié admin
- **Steps** : Vérifier F-021 à F-060 fonctionnent
- **Résultat attendu** : Toutes fonctionnalités merchant disponibles
- **Status** : [ ]

**F-065 : Gestion Multi-Tenant (si implémenté)**

- **Pré-requis** : Admin panel disponible
- **Steps** :
  1. Accès /admin ou panel admin
  2. Voir liste de tous les tenants
  3. Actions sur tenants
- **Résultat attendu** : Vue globale plateforme
- **Status** : [ ] N/A si pas implémenté

---

## Scénarios de Test Complets

### Scénario 1 : Customer - Parcours d'Achat Complet

**Objectif :** Valider le parcours complet d'un customer de la découverte à la commande

**Durée estimée :** 15-20 minutes

**Compte :** `customer1@example.com` / `Customer123!`

#### Étapes Détaillées

**ÉTAPE 1 : Connexion**

```
1. Ouvrir http://localhost:3000
2. Cliquer "Connexion" dans header
3. Entrer : customer1@example.com / Customer123!
4. Cliquer "Se connecter"

✓ Vérifications :
  [ ] Redirection vers / ou /products
  [ ] Header affiche email utilisateur
  [ ] Liens : Favoris, Commandes, Profil, Notifications visibles
  [ ] Liens Dashboard, Équipe PAS visibles
  [ ] Toast "Connexion réussie !"
```

**ÉTAPE 2 : Découverte Catalogue**

```
5. Cliquer "Produits" dans header
6. Vérifier /products affiché
7. Observer liste produits

✓ Vérifications :
  [ ] Liste de produits avec images
  [ ] Prix affichés en euros
  [ ] Catégories visibles
  [ ] Barre de recherche dans header
  [ ] Breadcrumbs "Accueil / Produits"
```

**ÉTAPE 3 : Recherche Produit**

```
8. Utiliser barre de recherche
9. Taper "laptop" (ou autre mot-clé)
10. Appuyer Entrée ou clic icône recherche

✓ Vérifications :
  [ ] Redirection vers /products?search=laptop
  [ ] Résultats filtrés affichés
  [ ] Nombre résultats cohérent
```

**ÉTAPE 4 : Détail Produit**

```
11. Cliquer sur un produit
12. Vérifier URL /products/[id]
13. Observer détails

✓ Vérifications :
  [ ] Image produit en grand
  [ ] Nom, description, prix, stock
  [ ] Bouton "Ajouter au panier"
  [ ] Icône cœur "Ajouter aux favoris"
  [ ] Section avis clients
  [ ] Breadcrumbs correct
```

**ÉTAPE 5 : Ajouter aux Favoris**

```
14. Cliquer icône cœur (favoris)

✓ Vérifications :
  [ ] Toast "Ajouté aux favoris"
  [ ] Icône cœur change (rempli/rouge)
  [ ] Requête API réussie (DevTools Network)
```

**ÉTAPE 6 : Vérifier Favoris**

```
15. Cliquer "Favoris" dans header
16. Vérifier /favorites

✓ Vérifications :
  [ ] Produit ajouté visible dans liste
  [ ] Bouton "Retirer des favoris" présent
  [ ] Bouton "Ajouter au panier" disponible
```

**ÉTAPE 7 : Ajouter au Panier**

```
17. Depuis /favorites ou /products/[id]
18. Cliquer "Ajouter au panier"

✓ Vérifications :
  [ ] Toast "Ajouté au panier"
  [ ] Badge panier +1 dans header
  [ ] Animation badge (si applicable)
```

**ÉTAPE 8 : Gérer Panier**

```
19. Cliquer icône panier dans header
20. Vérifier /cart
21. Observer contenu

✓ Vérifications :
  [ ] Produit listé avec quantité 1
  [ ] Prix unitaire et total affichés
  [ ] Boutons +/- pour quantité
  [ ] Bouton retirer produit
  [ ] Total général calculé
  [ ] Bouton "Procéder au paiement"
```

**ÉTAPE 9 : Modifier Quantité**

```
22. Cliquer bouton "+" pour augmenter quantité
23. Observer changements

✓ Vérifications :
  [ ] Quantité passe à 2
  [ ] Total ligne mis à jour (prix × 2)
  [ ] Total général recalculé
  [ ] Mise à jour instantanée
```

**ÉTAPE 10 : Checkout**

```
24. Cliquer "Procéder au paiement"
25. Vérifier /checkout
26. Remplir formulaire

✓ Vérifications :
  [ ] Formulaire livraison présent
  [ ] Récapitulatif commande visible
  [ ] Total affiché
  [ ] Intégration Stripe chargée
```

**ÉTAPE 11 : Paiement Test**

```
27. Entrer infos carte test Stripe :
    - Numéro : 4242 4242 4242 4242
    - Expiration : 12/25
    - CVC : 123
28. Soumettre paiement

✓ Vérifications :
  [ ] Processing affiché
  [ ] Paiement réussi
  [ ] Toast "Commande créée avec succès"
  [ ] Redirection vers /orders
```

**ÉTAPE 12 : Vérification Commande**

```
29. Sur /orders, vérifier nouvelle commande
30. Cliquer sur la commande pour détails

✓ Vérifications :
  [ ] Commande apparaît en haut de liste
  [ ] Statut "En attente"
  [ ] Total correct
  [ ] Articles corrects
  [ ] Date/heure correctes
```

**ÉTAPE 13 : Notification Reçue**

```
31. Cliquer "Notifications" (header)
32. Vérifier /notifications

✓ Vérifications :
  [ ] Email confirmation commande dans historique
  [ ] Statut "Envoyé"
  [ ] Badge notification mis à jour
```

**ÉTAPE 14 : Vérification Panier Vidé**

```
33. Vérifier badge panier header

✓ Vérifications :
  [ ] Badge = 0 ou disparu
  [ ] /cart vide
```

**ÉTAPE 15 : Profil Utilisateur**

```
34. Cliquer "Mon Profil" (header)
35. Vérifier /profile

✓ Vérifications :
  [ ] Nom, email affichés
  [ ] Rôle : customer
  [ ] Statut : Actif
  [ ] Formulaires modification fonctionnels
```

**RÉSULTAT GLOBAL SCÉNARIO 1**

```
[ ] SUCCÈS - Parcours complet fonctionnel
[ ] ÉCHEC - Problèmes identifiés (lister ci-dessous)

Problèmes trouvés :
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________
```

---

### Scénario 2 : Merchant Staff - Gestion d'une Commande

**Objectif :** Valider le workflow de traitement d'une commande par un merchant staff

**Durée estimée :** 10-15 minutes

**Compte :** `staff1@tech-store.com` / `Staff123!`

**Pré-requis :** Au moins 1 commande en statut "En attente" existe (créée par customer)

#### Étapes Détaillées

**ÉTAPE 1 : Connexion Merchant**

```
1. /login
2. Entrer credentials staff
3. Submit

✓ Vérifications :
  [ ] Redirection automatique vers /dashboard
  [ ] Toast "Connexion réussie !"
  [ ] Header montre liens merchant (Dashboard visible)
```

**ÉTAPE 2 : Consultation Dashboard**

```
4. Observer /dashboard

✓ Vérifications KPIs :
  [ ] Chiffre d'affaires affiché (€)
  [ ] Nombre de commandes
  [ ] Panier moyen calculé
  [ ] Nombre de produits
  [ ] Tous avec valeurs numériques
```

**ÉTAPE 3 : Commission Plateforme**

```
5. Vérifier section commission bleue

✓ Vérifications :
  [ ] Commission 5% affichée
  [ ] Montant commission calculé
  [ ] Revenu net affiché
  [ ] Formule : Net = Brut - (Brut × 5%)
```

**ÉTAPE 4 : Graphique Ventes**

```
6. Observer graphique Recharts

✓ Vérifications :
  [ ] Graphique ligne bleu (CA)
  [ ] Graphique ligne verte (Commandes)
  [ ] 6 mois affichés
  [ ] Axes X (mois) et Y (montants) lisibles
  [ ] Tooltip au survol
  [ ] Responsive
```

**ÉTAPE 5 : Top Produits**

```
7. Vérifier tableau "Top 5 Produits"

✓ Vérifications :
  [ ] Maximum 5 produits
  [ ] Colonnes : Produit, Quantité, CA
  [ ] Tri par quantité décroissant
  [ ] Badges numérotés (1, 2, 3, 4, 5)
```

**ÉTAPE 6 : Navigation Commandes**

```
8. Cliquer "Gérer les commandes" (actions rapides)
9. Vérifier redirection /orders

✓ Vérifications :
  [ ] Liste de TOUTES commandes du tenant
  [ ] Pas de commandes d'autres tenants
  [ ] Filtres disponibles (statut)
```

**ÉTAPE 7 : Traiter Commande**

```
10. Trouver commande "En attente"
11. Cliquer pour ouvrir détails
12. Vérifier infos :
    - Client
    - Articles
    - Total
    - Date
13. Changer statut : "En attente" → "Confirmée"

✓ Vérifications :
  [ ] Liste déroulante statuts disponibles
  [ ] Changement enregistré
  [ ] Toast "Commande mise à jour"
  [ ] Badge statut mis à jour (vert)
  [ ] Email envoyé au client (vérifier /notifications ou logs)
```

**ÉTAPE 8 : Expédition**

```
14. Même commande
15. Changer statut : "Confirmée" → "Expédiée"

✓ Vérifications :
  [ ] Statut mis à jour
  [ ] Toast confirmation
  [ ] Email expédition envoyé client
```

**ÉTAPE 9 : Vérification Paiement**

```
16. Cliquer "Paiements" dans header
17. Vérifier /payments

✓ Vérifications :
  [ ] Historique paiements du tenant
  [ ] Commande traitée présente
  [ ] Montant brut correct
  [ ] Commission 5% calculée
  [ ] Montant net affiché
```

**ÉTAPE 10 : Résumé Financier**

```
18. Observer 3 cartes en haut de /payments

✓ Vérifications :
  [ ] Total Brut = somme paiements
  [ ] Commission = Total × 5%
  [ ] Total Net = Brut - Commission
  [ ] Calculs corrects (vérifier manuellement)
```

**ÉTAPE 11 : Export CSV**

```
19. Cliquer "Exporter CSV"
20. Télécharger fichier
21. Ouvrir CSV dans Excel/LibreOffice

✓ Vérifications :
  [ ] Fichier téléchargé
  [ ] Nom : paiements_YYYY-MM-DD.csv
  [ ] Colonnes : ID, Commande, Montant Brut, Commission, Net, Statut, Date
  [ ] Données correctes
  [ ] Séparateur virgule
  [ ] Encodage UTF-8
```

**ÉTAPE 12 : Isolation Tenant**

```
22. Noter nombre commandes/paiements affichés
23. Se déconnecter
24. Connecter avec staff2@fashion-boutique.com / Staff123!
25. Aller sur /dashboard, /orders, /payments

✓ Vérifications :
  [ ] Données différentes
  [ ] Aucune donnée Tech Store visible
  [ ] Fashion Boutique isolé
  [ ] Pas de fuite de données entre tenants
```

**RÉSULTAT GLOBAL SCÉNARIO 2**

```
[ ] SUCCÈS - Workflow merchant staff complet
[ ] ÉCHEC - Problèmes identifiés

Problèmes :
_____________________________________________________________
_____________________________________________________________
```

---

### Scénario 3 : Merchant Owner - Gestion d'Équipe

**Objectif :** Valider la gestion complète d'équipe par un owner

**Durée estimée :** 10-12 minutes

**Compte :** `merchant1@tech-store.com` / `Merchant123!`

#### Étapes Détaillées

**ÉTAPE 1 : Connexion Owner**

```
1. /login
2. merchant1@tech-store.com / Merchant123!
3. Submit

✓ Vérifications :
  [ ] Connexion OK
  [ ] Header affiche lien "Équipe"
  [ ] Lien cliquable
```

**ÉTAPE 2 : Accès Page Équipe**

```
4. Cliquer "Équipe" (header)
5. Vérifier /team chargé

✓ Vérifications :
  [ ] Page équipe affichée
  [ ] Breadcrumbs "Accueil / Équipe"
  [ ] Titre "Gestion de l'équipe"
  [ ] Bouton "Inviter un membre"
  [ ] Tableau membres présent
```

**ÉTAPE 3 : Voir Membres Actuels**

```
6. Observer tableau membres

✓ Vérifications :
  [ ] Au moins 2 membres (owner + staff seeded)
  [ ] merchant1@tech-store.com visible (Owner, Actif)
  [ ] staff1@tech-store.com visible (Staff, Actif)
  [ ] Colonnes complètes
  [ ] Badges rôles colorés
  [ ] Actions disponibles (sauf sur soi-même)
```

**ÉTAPE 4 : Inviter Nouveau Membre**

```
7. Cliquer "Inviter un membre"
8. Formulaire apparaît
9. Remplir :
   - Email : nouveau-staff@tech-store.com
   - Nom : Nouveau Staff Test
   - Rôle : Staff
10. Cliquer "Envoyer l'invitation"

✓ Vérifications :
  [ ] Formulaire validé
  [ ] Toast "Invitation envoyée avec succès"
  [ ] Formulaire fermé
  [ ] Rechargement liste automatique
```

**ÉTAPE 5 : Vérifier Membre Ajouté**

```
11. Chercher "Nouveau Staff Test" dans liste

✓ Vérifications :
  [ ] Membre visible
  [ ] Email : nouveau-staff@tech-store.com
  [ ] Rôle : Staff (badge bleu)
  [ ] Statut : Inactif (badge rouge/orange)
  [ ] Email vérifié : Non
  [ ] Boutons actions disponibles
```

**ÉTAPE 6 : Vérifier Email Envoyé**

```
12. Option A : Vérifier boîte mail (si notification-service configuré)
    Option B : Vérifier logs notification-service
    Option C : /notifications pour voir trace

✓ Vérifications :
  [ ] Email invitation tracé quelque part
  [ ] Type : email
  [ ] Destinataire : nouveau-staff@tech-store.com
  [ ] Statut : sent ou pending
```

**ÉTAPE 7 : Désactiver un Membre**

```
13. Sur membre staff1@tech-store.com
14. Cliquer "Désactiver"

✓ Vérifications :
  [ ] Toast "Statut mis à jour"
  [ ] Badge statut devient "Inactif" (rouge)
  [ ] Changement visuel immédiat
```

**ÉTAPE 8 : Vérifier Membre Désactivé**

```
15. Se déconnecter
16. Tenter connexion staff1@tech-store.com
17. Observer résultat

✓ Vérifications :
  [ ] Connexion refusée OU
  [ ] Connexion OK mais accès limité
  [ ] Message "Compte désactivé" (selon implémentation)
```

**ÉTAPE 9 : Réactiver Membre**

```
18. Reconnexion owner
19. /team
20. Cliquer "Activer" sur staff1@tech-store.com

✓ Vérifications :
  [ ] Toast "Statut mis à jour"
  [ ] Badge "Actif" (vert)
  [ ] staff1 peut se reconnecter
```

**ÉTAPE 10 : Tenter Modifier Soi-Même**

```
21. Sur ligne merchant1@tech-store.com (soi-même)
22. Vérifier boutons actions

✓ Vérifications :
  [ ] PAS de bouton "Désactiver" sur soi-même
  [ ] PAS d'option "Modifier rôle" sur soi-même
  [ ] Protection implémentée
```

**ÉTAPE 11 : Modifier Rôle (si implémenté)**

```
23. Sur un staff
24. Option "Changer rôle" (si bouton existe)
25. Changer Staff → Owner
26. Confirmer

✓ Vérifications :
  [ ] Rôle mis à jour
  [ ] Badge devient violet (Owner)
  [ ] Toast confirmation
  [ ] Membre a maintenant accès /team
```

**RÉSULTAT GLOBAL SCÉNARIO 3**

```
[ ] SUCCÈS - Gestion équipe complète
[ ] ÉCHEC - Problèmes identifiés

Problèmes :
_____________________________________________________________
_____________________________________________________________
```

---

### Scénario 4 : Tests Négatifs & Sécurité

**Objectif :** Valider que les restrictions d'accès fonctionnent correctement

**Durée estimée :** 15 minutes

**Comptes :** Tous

#### Tests de Redirection

**TEST NEG-001 : Customer tente Dashboard**

```
1. Connecté en customer1@example.com
2. Taper manuellement : http://localhost:3000/dashboard
3. Appuyer Entrée

✓ Vérifications :
  [ ] Redirection automatique vers /
  [ ] Pas d'accès au dashboard
  [ ] Toast optionnel "Accès non autorisé"
  [ ] Console : pas d'erreur JavaScript
```

**TEST NEG-002 : Customer tente Équipe**

```
1. Connecté customer
2. URL manuelle : /team

✓ Vérifications :
  [ ] Redirection vers /
  [ ] Accès refusé
```

**TEST NEG-003 : Customer tente Paiements**

```
1. Connecté customer
2. URL manuelle : /payments

✓ Vérifications :
  [ ] Redirection vers /
  [ ] Pas d'accès paiements
```

**TEST NEG-004 : Staff tente Équipe**

```
1. Connecté staff1@tech-store.com
2. Vérifier lien "Équipe" absent header
3. URL manuelle : /team

✓ Vérifications :
  [ ] Lien "Équipe" PAS dans header
  [ ] URL /team → Redirection vers /
  [ ] Accès refusé
```

**TEST NEG-005 : Staff tente API Équipe**

```
1. Connecté staff
2. DevTools Console :
   fetch('/api/team/users', {
     headers: { Authorization: 'Bearer ' + localStorage.getItem('token') }
   })
3. Observer réponse

✓ Vérifications :
  [ ] API refuse (403 Forbidden)
  [ ] Message "Owner role required"
  [ ] Backend vérifie permissions
```

#### Tests Isolation Tenant

**TEST NEG-006 : Accès Données Autre Tenant**

```
1. Connecté merchant1@tech-store.com (Tech Store)
2. Noter ID d'une commande Fashion Boutique
3. Tenter accès : /orders/[id-fashion-boutique]
4. Ou via API direct

✓ Vérifications :
  [ ] Accès refusé ou 404
  [ ] Ne peut pas voir données autre tenant
  [ ] Backend filtre par tenant_id
```

**TEST NEG-007 : Modifier Data Autre Tenant via API**

```
1. Connecté staff1@tech-store.com
2. DevTools : Tenter PATCH /api/orders/[id-autre-tenant]
3. Observer réponse

✓ Vérifications :
  [ ] API refuse (403 ou 404)
  [ ] Modification impossible
  [ ] Logs backend tracent tentative
```

#### Tests Sans Authentification

**TEST NEG-008 : Accès Page Sans Token**

```
1. Mode navigation privée (ou localStorage.clear())
2. URL directe : /dashboard

✓ Vérifications :
  [ ] Redirection vers /login
  [ ] Middleware auth fonctionne
```

**TEST NEG-009 : API Sans Token**

```
1. DevTools Console :
   fetch('/api/orders')
2. Sans header Authorization

✓ Vérifications :
  [ ] 401 Unauthorized
  [ ] Message "Token manquant"
```

#### Tests Token Invalide

**TEST NEG-010 : Token Expiré/Invalide**

```
1. localStorage.setItem('token', 'fake-token-123')
2. Tenter accès /profile ou autre page auth

✓ Vérifications :
  [ ] Redirection /login
  [ ] Token supprimé
  [ ] Message erreur approprié
```

#### Tests Formulaires

**TEST NEG-011 : Validation Email Invalide**

```
1. /profile
2. Modifier email avec format invalide (test@)
3. Soumettre

✓ Vérifications :
  [ ] Validation HTML5 bloque
  [ ] Ou backend refuse
  [ ] Message erreur clair
```

**TEST NEG-012 : Mot de Passe Court**

```
1. /profile
2. Changer mot de passe avec moins de 8 caractères
3. Soumettre

✓ Vérifications :
  [ ] Frontend bloque (minLength=8)
  [ ] Ou backend refuse
  [ ] Message "8 caractères minimum"
```

**TEST NEG-013 : Mot de Passe Identique**

```
1. /profile changement mot de passe
2. Nouveau = actuel
3. Soumettre

✓ Vérifications :
  [ ] Backend refuse
  [ ] Message "Mot de passe doit être différent"
```

#### Tests Limites

**TEST NEG-014 : Panier Vide Checkout**

```
1. Panier vide
2. Tenter accès /checkout

✓ Vérifications :
  [ ] Redirection ou message "Panier vide"
  [ ] Impossible procéder paiement
```

**TEST NEG-015 : Quantité Négative/Zéro**

```
1. Panier avec produit
2. Tenter quantité 0 ou négative

✓ Vérifications :
  [ ] Validation empêche
  [ ] Minimum = 1
  [ ] Ou produit retiré si 0
```

**RÉSULTAT GLOBAL SCÉNARIO 4**

```
[ ] SUCCÈS - Toutes restrictions fonctionnent
[ ] ÉCHEC - Failles de sécurité trouvées

Failles identifiées :
_____________________________________________________________
_____________________________________________________________
```

---

## Matrice de Validation

### Légende

- ✅ **OK** : Test passé avec succès
- ❌ **KO** : Test échoué, bug identifié
- ⚠️ **Partiel** : Fonctionne mais avec limitations
- 🚫 **N/A** : Non applicable pour ce rôle
- ⏸️ **Pending** : Non testé encore

### Matrice Pages - Accessibilité par Rôle

| Page | URL | Customer | Staff | Owner | Admin | Notes |
|------|-----|----------|-------|-------|-------|-------|
| **Accueil** | / | ✅ | ✅ | ✅ | ✅ | |
| **Login** | /login | ✅ | ✅ | ✅ | ✅ | |
| **Register** | /register | ✅ | ✅ | ✅ | ✅ | |
| **Produits** | /products | ✅ | ✅ | ✅ | ✅ | |
| **Détail Produit** | /products/[id] | ✅ | ✅ | ✅ | ✅ | |
| **Favoris** | /favorites | ✅ | ✅ | ✅ | ✅ | |
| **Panier** | /cart | ✅ | ✅ | ✅ | ✅ | |
| **Checkout** | /checkout | ✅ | ✅ | ✅ | ✅ | |
| **Commandes** | /orders | ✅ | ✅ | ✅ | ✅ | Vue différente selon rôle |
| **Mon Profil** | /profile | ✅ | ✅ | ✅ | ✅ | |
| **Notifications** | /notifications | ✅ | ✅ | ✅ | ✅ | |
| **Dashboard** | /dashboard | 🚫 | ✅ | ✅ | ✅ | Redirection si customer |
| **Paiements** | /payments | 🚫 | ✅ | ✅ | ✅ | Merchant uniquement |
| **Équipe** | /team | 🚫 | 🚫 | ✅ | ✅ | Owner+ uniquement |
| **Onboarding** | /onboarding | 🚫 | 🚫 | ✅ | ✅ | Owner initial setup |
| **404** | /not-found | ✅ | ✅ | ✅ | ✅ | |

### Matrice Fonctionnalités - Par Rôle

#### Fonctionnalités Shopping

| Fonctionnalité | Customer | Staff | Owner | Admin |
|----------------|----------|-------|-------|-------|
| Voir catalogue | ✅ | ✅ | ✅ | ✅ |
| Rechercher produits | ✅ | ✅ | ✅ | ✅ |
| Voir détails produit | ✅ | ✅ | ✅ | ✅ |
| Ajouter favoris | ✅ | ✅ | ✅ | ✅ |
| Retirer favoris | ✅ | ✅ | ✅ | ✅ |
| Ajouter panier | ✅ | ✅ | ✅ | ✅ |
| Modifier quantité panier | ✅ | ✅ | ✅ | ✅ |
| Retirer du panier | ✅ | ✅ | ✅ | ✅ |
| Checkout / Paiement | ✅ | ✅ | ✅ | ✅ |
| Voir ses commandes | ✅ | ⚠️ | ⚠️ | ⚠️ |
| Laisser avis | ✅ | ✅ | ✅ | ✅ |

**Notes :**

- ⚠️ Staff/Owner/Admin voient toutes commandes du tenant, pas uniquement les leurs

#### Fonctionnalités Gestion Produits

| Fonctionnalité | Customer | Staff | Owner | Admin |
|----------------|----------|-------|-------|-------|
| Ajouter produit | 🚫 | ✅ | ✅ | ✅ |
| Modifier produit | 🚫 | ✅ | ✅ | ✅ |
| Supprimer produit | 🚫 | ✅ | ✅ | ✅ |
| Gérer stock | 🚫 | ✅ | ✅ | ✅ |
| Upload image | 🚫 | ✅ | ✅ | ✅ |

#### Fonctionnalités Dashboard

| Fonctionnalité | Customer | Staff | Owner | Admin |
|----------------|----------|-------|-------|-------|
| Accès dashboard | 🚫 | ✅ | ✅ | ✅ |
| Voir KPIs | 🚫 | ✅ | ✅ | ✅ |
| Graphique ventes | 🚫 | ✅ | ✅ | ✅ |
| Top produits | 🚫 | ✅ | ✅ | ✅ |
| Commission plateforme | 🚫 | ✅ | ✅ | ✅ |

#### Fonctionnalités Commandes Merchant

| Fonctionnalité | Customer | Staff | Owner | Admin |
|----------------|----------|-------|-------|-------|
| Voir toutes commandes tenant | 🚫 | ✅ | ✅ | ✅ |
| Modifier statut commande | 🚫 | ✅ | ✅ | ✅ |
| Filtrer commandes | 🚫 | ✅ | ✅ | ✅ |

#### Fonctionnalités Paiements

| Fonctionnalité | Customer | Staff | Owner | Admin |
|----------------|----------|-------|-------|-------|
| Voir historique paiements | 🚫 | ✅ | ✅ | ✅ |
| Voir résumé financier | 🚫 | ✅ | ✅ | ✅ |
| Export CSV paiements | 🚫 | ✅ | ✅ | ✅ |

#### Fonctionnalités Gestion Équipe

| Fonctionnalité | Customer | Staff | Owner | Admin |
|----------------|----------|-------|-------|-------|
| Accès page équipe | 🚫 | 🚫 | ✅ | ✅ |
| Voir liste membres | 🚫 | 🚫 | ✅ | ✅ |
| Inviter membre | 🚫 | 🚫 | ✅ | ✅ |
| Modifier rôle membre | 🚫 | 🚫 | ✅ | ✅ |
| Activer/Désactiver membre | 🚫 | 🚫 | ✅ | ✅ |

#### Fonctionnalités Onboarding

| Fonctionnalité | Customer | Staff | Owner | Admin |
|----------------|----------|-------|-------|-------|
| Accès wizard | 🚫 | 🚫 | ✅ | ✅ |
| Compléter étapes | 🚫 | 🚫 | ✅ | ✅ |
| Choisir plan | 🚫 | 🚫 | ✅ | ✅ |
| Config boutique | 🚫 | 🚫 | ✅ | ✅ |

#### Fonctionnalités Profil & Notifications

| Fonctionnalité | Customer | Staff | Owner | Admin |
|----------------|----------|-------|-------|-------|
| Voir profil | ✅ | ✅ | ✅ | ✅ |
| Modifier nom/email | ✅ | ✅ | ✅ | ✅ |
| Changer mot de passe | ✅ | ✅ | ✅ | ✅ |
| Voir notifications | ✅ | ✅ | ✅ | ✅ |
| Badge notifications | ✅ | ✅ | ✅ | ✅ |

#### Fonctionnalités UI/UX

| Fonctionnalité | Customer | Staff | Owner | Admin |
|----------------|----------|-------|-------|-------|
| Toast notifications | ✅ | ✅ | ✅ | ✅ |
| Skeleton loading | ✅ | ✅ | ✅ | ✅ |
| Breadcrumbs | ✅ | ✅ | ✅ | ✅ |
| Barre recherche | ✅ | ✅ | ✅ | ✅ |
| Dark mode | ✅ | ✅ | ✅ | ✅ |
| Progress bar nav | ✅ | ✅ | ✅ | ✅ |
| Responsive design | ✅ | ✅ | ✅ | ✅ |

### Matrice Tests de Sécurité

| Test Sécurité | Attendu | Résultat | Notes |
|---------------|---------|----------|-------|
| Customer → /dashboard | Redirection / | ⏸️ | |
| Customer → /team | Redirection / | ⏸️ | |
| Customer → /payments | Redirection / | ⏸️ | |
| Staff → /team | Redirection / | ⏸️ | |
| Staff API équipe | 403 Forbidden | ⏸️ | |
| Accès data autre tenant | 403/404 | ⏸️ | |
| API sans token | 401 Unauthorized | ⏸️ | |
| Token invalide | Redirection /login | ⏸️ | |
| Owner désactive soi-même | Impossible | ⏸️ | |
| Panier vide checkout | Bloqué | ⏸️ | |

### Résumé Matrice

**À remplir après tests :**

```
Total pages testées : ___ / 15
Total fonctionnalités testées : ___ / 80+
Total tests sécurité : ___ / 10

Taux de réussite Customer : ____%
Taux de réussite Staff : ____%
Taux de réussite Owner : ____%
Taux de réussite Admin : ____%

Taux de réussite global : ____%
```

**Bugs critiques trouvés :**

```
1. ___________________________________________________________
2. ___________________________________________________________
3. ___________________________________________________________
```

**Bugs mineurs :**

```
1. ___________________________________________________________
2. ___________________________________________________________
```

---

## Template de Rapport de Test

> Copier ce template pour chaque session de tests

---

### 📋 RAPPORT DE TEST - Session [Numéro]

**Date :** _____________  
**Testeur :** _____________  
**Durée :** ___h___min  
**Environnement :** Local / Docker / Kubernetes / Autre : _______

#### Configuration Testée

**Frontend :**

- URL : <http://localhost>:____
- Version : _____________
- Navigateur : _____________ (version : _____)

**Services Backend :**

- [ ] Auth Service (port 8000) - Version : _______
- [ ] Product Service (port 8001) - Version : _______
- [ ] Order Service (port 8002) - Version : _______
- [ ] Payment Service (port 8003) - Version : _______
- [ ] Notification Service (port 8004) - Version : _______
- [ ] Tenant Service (port 8005) - Version : _______

**Bases de données :**

- [ ] PostgreSQL (Tenants)
- [ ] SQLite (Auth, Orders)

**Services externes :**

- [ ] Stripe (mode test)
- [ ] SendGrid / Twilio (notifications)

---

### 🧪 Tests Effectués

#### Rôle : Customer

| Test ID | Nom du Test | Résultat | Durée | Notes |
|---------|-------------|----------|-------|-------|
| C-AUTH-001 | Connexion | ✅ / ❌ | __s | |
| C-AUTH-002 | Connexion échouée | ✅ / ❌ | __s | |
| C-NAV-001 | Header liens | ✅ / ❌ | __s | |
| F-001 | Catalogue | ✅ / ❌ | __s | |
| F-002 | Recherche | ✅ / ❌ | __s | |
| F-003 | Favoris ajout | ✅ / ❌ | __s | |
| F-005 | Panier ajout | ✅ / ❌ | __s | |
| F-008 | Checkout | ✅ / ❌ | __s | |
| ... | ... | ... | ... | |

**Résultat Customer :** _**/20 tests passés (**_%])

---

#### Rôle : Merchant Staff

| Test ID | Nom du Test | Résultat | Durée | Notes |
|---------|-------------|----------|-------|-------|
| S-AUTH-001 | Connexion staff | ✅ / ❌ | __s | |
| F-021 | Accès dashboard | ✅ / ❌ | __s | |
| F-022 | KPIs affichage | ✅ / ❌ | __s | |
| F-024 | Graphique ventes | ✅ / ❌ | __s | |
| F-027 | Ajout produit | ✅ / ❌ | __s | |
| F-031 | Modifier commande | ✅ / ❌ | __s | |
| F-034 | Export CSV | ✅ / ❌ | __s | |
| F-036 | Tentative /team | ✅ / ❌ | __s | |
| ... | ... | ... | ... | |

**Résultat Staff :** _**/20 tests passés (**_%])

---

#### Rôle : Merchant Owner

| Test ID | Nom du Test | Résultat | Durée | Notes |
|---------|-------------|----------|-------|-------|
| O-AUTH-001 | Connexion owner | ✅ / ❌ | __s | |
| O-NAV-002 | Lien équipe visible | ✅ / ❌ | __s | |
| F-042 | Accès /team | ✅ / ❌ | __s | |
| F-044 | Inviter membre | ✅ / ❌ | __s | |
| F-046 | Désactiver membre | ✅ / ❌ | __s | |
| F-048 | Impossible soi-même | ✅ / ❌ | __s | |
| F-051 | Onboarding étape 1 | ✅ / ❌ | __s | |
| F-055 | Onboarding étape 5 | ✅ / ❌ | __s | |
| ... | ... | ... | ... | |

**Résultat Owner :** _**/20 tests passés (**_%])

---

#### Rôle : Platform Admin

| Test ID | Nom du Test | Résultat | Durée | Notes |
|---------|-------------|----------|-------|-------|
| A-AUTH-001 | Connexion admin | ✅ / ❌ | __s | |
| F-061 | Accès total | ✅ / ❌ | __s | |
| F-062 | Multi-tenant | ✅ / ❌ | __s | |
| ... | ... | ... | ... | |

**Résultat Admin :** _**/5 tests passés (**_%])

---

### 🎯 Scénarios Complets

| Scénario | Résultat | Durée | Étapes OK | Étapes KO |
|----------|----------|-------|-----------|-----------|
| 1. Customer - Parcours d'achat | ✅ / ❌ | __min | ___/15 | |
| 2. Staff - Gestion commande | ✅ / ❌ | __min | ___/12 | |
| 3. Owner - Gestion équipe | ✅ / ❌ | __min | ___/11 | |
| 4. Tests négatifs | ✅ / ❌ | __min | ___/15 | |

---

### 🔒 Tests de Sécurité

| Test | Résultat | Conforme | Notes |
|------|----------|----------|-------|
| Customer → Dashboard | ✅ / ❌ | Oui / Non | |
| Customer → Team | ✅ / ❌ | Oui / Non | |
| Staff → Team | ✅ / ❌ | Oui / Non | |
| API sans token | ✅ / ❌ | Oui / Non | |
| Token invalide | ✅ / ❌ | Oui / Non | |
| Isolation tenant | ✅ / ❌ | Oui / Non | |
| Owner auto-désactivation | ✅ / ❌ | Oui / Non | |

**Résultat Sécurité :** _**/10 tests passés (**_%])

---

### 📊 Résumé Global

```
┌─────────────────────────────────────────────────┐
│          RÉSULTATS SESSION DE TESTS             │
├─────────────────────────────────────────────────┤
│ Tests Customer       : ___/20 (___%)            │
│ Tests Staff          : ___/20 (___%)            │
│ Tests Owner          : ___/20 (___%)            │
│ Tests Admin          : ___/5  (___%)            │
│ Scénarios complets   : ___/4  (___%)            │
│ Tests sécurité       : ___/10 (___%)            │
├─────────────────────────────────────────────────┤
│ TOTAL                : ___/__ (___%)            │
└─────────────────────────────────────────────────┘
```

**Verdict Global :**

- [ ] ✅ **VALIDÉ** - Application prête pour déploiement
- [ ] ⚠️ **VALIDÉ AVEC RÉSERVES** - Bugs mineurs à corriger
- [ ] ❌ **NON VALIDÉ** - Bugs critiques bloquants

---

### 🐛 Bugs Identifiés

#### 🔴 Bugs Critiques (Bloquants)

**BUG-C-001**

- **Titre :** _____________________________________________
- **Sévérité :** Critique
- **Rôle affecté :** _____________
- **Page/Fonction :** _____________
- **Description :**

  ```
  _________________________________________________________
  _________________________________________________________
  ```

- **Steps to reproduce :**
  1. _______________
  2. _______________
  3. _______________
- **Résultat attendu :** _______________
- **Résultat actuel :** _______________
- **Impact :** _______________
- **Screenshot :** (optionnel)

---

**BUG-C-002**

- **Titre :** _____________________________________________
- (même structure)

---

#### 🟠 Bugs Majeurs (Non bloquants mais gênants)

**BUG-M-001**

- **Titre :** _____________________________________________
- **Sévérité :** Majeur
- **Description :** _______________
- **Impact :** _______________

---

#### 🟡 Bugs Mineurs (Cosmétiques ou peu impactants)

**BUG-m-001**

- **Titre :** _____________________________________________
- **Sévérité :** Mineur
- **Description :** _______________
- **Impact :** _______________

---

### ✨ Améliorations Suggérées

1. **Amélioration UI :** _______________________________________
2. **Performance :** ___________________________________________
3. **UX :** ___________________________________________________
4. **Accessibilité :** _________________________________________
5. **Autre :** ________________________________________________

---

### 🎨 Tests Visuels

#### Responsive Design

| Device | Résolution | Résultat | Notes |
|--------|------------|----------|-------|
| Mobile | 375x667 | ✅ / ❌ | iPhone SE |
| Mobile | 390x844 | ✅ / ❌ | iPhone 14 |
| Tablet | 768x1024 | ✅ / ❌ | iPad |
| Desktop | 1920x1080 | ✅ / ❌ | Full HD |
| Desktop | 2560x1440 | ✅ / ❌ | 2K |

#### Navigateurs

| Navigateur | Version | Résultat | Notes |
|------------|---------|----------|-------|
| Chrome | ___ | ✅ / ❌ | |
| Firefox | ___ | ✅ / ❌ | |
| Safari | ___ | ✅ / ❌ | |
| Edge | ___ | ✅ / ❌ | |

---

### 📸 Screenshots (Optionnel)

**Bug Screenshot 1 :**

- Fichier : `screenshot_bug_001.png`
- Description : _______________

**Bug Screenshot 2 :**

- Fichier : `screenshot_bug_002.png`
- Description : _______________

---

### 📝 Notes Additionnelles

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

### ✅ Checklist Pré-Déploiement

**Backend :**

- [ ] Tous services démarrent sans erreur
- [ ] Health checks répondent 200 OK
- [ ] Base de données initialisées et seedées
- [ ] JWT auth fonctionne
- [ ] API retournent données correctes
- [ ] Logs propres sans erreurs critiques

**Frontend :**

- [ ] Build sans erreurs ni warnings
- [ ] Pas d'erreurs console JavaScript
- [ ] Toasts fonctionnels
- [ ] Skeleton UI affichés pendant chargements
- [ ] Redirections auth fonctionnent
- [ ] Images chargées correctement

**Intégration :**

- [ ] Frontend <-> Backend communication OK
- [ ] Stripe test payments fonctionnent
- [ ] Emails notifications envoyés
- [ ] Isolation tenant validée
- [ ] Guards de rôle fonctionnent
- [ ] Export CSV génère fichiers valides

**Performance :**

- [ ] Pages chargent en < 2s
- [ ] API répondent en < 500ms
- [ ] Pas de memory leaks
- [ ] Graphiques Recharts performants

---

### 🚀 Recommandation Finale

**Pour mise en production :**

- [ ] ✅ GO - Tous tests verts, application stable
- [ ] ⚠️ GO CONDITIONNEL - Correction bugs mineurs d'abord
- [ ] ❌ NO-GO - Bugs critiques à résoudre

**Prochaines étapes suggérées :**

1. _________________________________________________________
2. _________________________________________________________
3. _________________________________________________________

---

**Signé :** _____________  
**Date :** _____________  
**Rôle :** Testeur QA / Développeur / Autre : _________

---

## Annexes

### Commandes Utiles pour les Tests

**Démarrer tous les services :**

```bash
cd /home/paul/efrei-project/DevOpsMicroServiceApp
docker-compose up -d
```

**Vérifier statut services :**

```bash
docker-compose ps
```

**Voir logs d'un service :**

```bash
docker-compose logs -f auth-service
docker-compose logs -f frontend
```

**Redémarrer un service :**

```bash
docker-compose restart tenant-service
```

**Seed base de données (si nécessaire) :**

```bash
# Auth service seeding automatique au démarrage
# Ou manuellement :
docker-compose exec auth-service python -m app.services.seed_service
```

**Vérifier health checks :**

```bash
curl http://localhost:8000/health  # Auth
curl http://localhost:8001/health  # Product
curl http://localhost:8002/health  # Order
curl http://localhost:8003/health  # Payment
curl http://localhost:8004/health  # Notification
curl http://localhost:8005/health  # Tenant
```

**Nettoyer environnement :**

```bash
docker-compose down -v  # Supprime volumes
docker-compose up -d    # Redémarre propre
```

---

### Cartes de Test Stripe

**Succès :**

- Numéro : `4242 4242 4242 4242`
- Expiration : Toute date future (ex: 12/25)
- CVC : N'importe quel 3 chiffres (ex: 123)

**Échec (carte déclinée) :**

- Numéro : `4000 0000 0000 0002`

**3D Secure requis :**

- Numéro : `4000 0027 6000 3184`

---

### Liens Documentation

- [ROLES-ET-PERMISSIONS.md](./ROLES-ET-PERMISSIONS.md) - Documentation rôles
- [NAVIGATION-PAR-ROLE.md](./NAVIGATION-PAR-ROLE.md) - Guide navigation
- [README.md](../README.md) - Documentation principale

---

**FIN DU PLAN DE TESTS MANUELS**

> Pour toute question ou clarification, contacter l'équipe DevOps ou consulter la documentation projet.
