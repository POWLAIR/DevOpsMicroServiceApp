# Guide d'utilisation — DevOps MicroService App

> Application SaaS multi-tenant : catalogue produits, commandes, paiements, notifications.  
> Frontend accessible sur **http://localhost:3001**

---

## Sommaire

1. [Prérequis et démarrage](#1-prérequis-et-démarrage)
2. [Comptes disponibles par défaut](#2-comptes-disponibles-par-défaut)
3. [Manipulation 1 — Inscription et connexion](#3-manipulation-1--inscription-et-connexion)
4. [Manipulation 2 — Catalogue et recherche produits](#4-manipulation-2--catalogue-et-recherche-produits)
5. [Manipulation 3 — Panier](#5-manipulation-3--panier)
6. [Manipulation 4 — Passer une commande (checkout)](#6-manipulation-4--passer-une-commande-checkout)
7. [Manipulation 5 — Suivi des commandes](#7-manipulation-5--suivi-des-commandes)
8. [Manipulation 6 — Paiements](#8-manipulation-6--paiements)
9. [Manipulation 7 — Favoris](#9-manipulation-7--favoris)
10. [Manipulation 8 — Profil utilisateur](#10-manipulation-8--profil-utilisateur)
11. [Manipulation 9 — Notifications](#11-manipulation-9--notifications)
12. [Manipulation 10 — Dashboard marchand](#12-manipulation-10--dashboard-marchand)
13. [Manipulation 11 — Onboarding (configuration boutique)](#13-manipulation-11--onboarding-configuration-boutique)
14. [Tableau des rôles et accès](#14-tableau-des-rôles-et-accès)
15. [Fonctionnalités non disponibles](#15-fonctionnalités-non-disponibles)
16. [Référence des services et ports](#16-référence-des-services-et-ports)

---

## 1. Prérequis et démarrage

### Lancer les conteneurs

```bash
cd DevOpsMicroServiceApp
docker compose up -d
```

Attendre que tous les services soient `healthy` (environ 60 secondes) :

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### URLs d'accès

| Service | URL |
|---|---|
| **Frontend (point d'entrée)** | http://localhost:3001 |
| Auth Service (API) | http://localhost:8000 |
| Order Service (API) | http://localhost:3000 |
| Product Service (API) | http://localhost:4000 |
| Payment Service (API) | http://localhost:5000 |
| Notification Service (API) | http://localhost:6000 |
| Tenant Service (API) | http://localhost:7000 |

> Toutes les interactions utilisateur passent exclusivement par **http://localhost:3001**.

---

## 2. Comptes disponibles par défaut

Ces comptes sont créés automatiquement au démarrage (seed service de l'auth-service).

| Email | Mot de passe | Rôle | Tenant |
|---|---|---|---|
| `admin@example.com` | `Test1234!` | `platform_admin` | Tenant par défaut |
| `admin-test@test.com` | `Test1234!` | `platform_admin` | Tenant par défaut |
| `merchant1@tech-store.com` | `Test1234!` | `merchant_owner` | Tech Store |
| `staff1@tech-store.com` | `Test1234!` | `merchant_staff` | Tech Store |
| `staff2@tech-store.com` | `Test1234!` | `merchant_staff` | Tech Store |

> Le **tenant par défaut** utilisé sans configuration préalable est `1574b85d-a3df-400f-9e82-98831aa32934`.

---

## 3. Manipulation 1 — Inscription et connexion

### Connexion

1. Ouvrir http://localhost:3001/login
2. Saisir les identifiants (ex. `admin@example.com` / `Test1234!`)
3. Cliquer **"Se connecter"**
4. Redirection automatique vers la page d'accueil

### Inscription d'un nouveau compte

1. Ouvrir http://localhost:3001/register
2. Saisir un email et un mot de passe (minimum 8 caractères)
3. Cliquer **"S'inscrire"**
4. Le compte est créé avec le rôle `customer` sur le tenant par défaut

### Déconnexion

- Cliquer sur l'avatar / menu utilisateur en haut à droite
- Sélectionner **"Déconnexion"**
- Le JWT est supprimé du localStorage et la session est terminée

---

## 4. Manipulation 2 — Catalogue et recherche produits

**URL** : http://localhost:3001/products  
**Accès** : Public (pas de connexion requise)

### Parcourir le catalogue

1. La page affiche tous les produits disponibles (20+ produits importés depuis FakeStoreAPI)
2. Les produits sont regroupés par catégories visibles dans la barre de navigation

### Filtrer les produits

| Filtre | Comment | Valeurs possibles |
|---|---|---|
| **Catégorie** | Barre latérale ou barre de catégories | Men's Clothing, Women's Clothing, Electronics, Jewelery |
| **Recherche textuelle** | Barre de recherche en haut | Nom du produit ou description |
| **Fourchette de prix** | Slider min/max | 0 à 1000€ |
| **Stock disponible** | Case à cocher | Affiche uniquement les articles en stock |
| **Tri** | Menu déroulant | Prix croissant, Prix décroissant, Note, Popularité, Nouveauté |

### Consulter une fiche produit

1. Cliquer sur un produit dans la grille
2. La fiche affiche : image, nom, catégorie, prix, note, stock disponible, description
3. Actions disponibles (connecté) :
   - Ajuster la quantité avec les boutons `+` / `−`
   - **"Ajouter au panier"**
   - **"Acheter maintenant"** (raccourci vers le checkout)
   - **Cœur** : ajouter/retirer des favoris

---

## 5. Manipulation 3 — Panier

**URL** : http://localhost:3001/cart  
**Accès** : Public (le panier est stocké localement dans le navigateur)

### Gérer le panier

| Action | Comment |
|---|---|
| Voir le contenu | Icône panier dans le header (badge avec compteur) ou URL `/cart` |
| Modifier la quantité | Boutons `+` / `−` à côté de chaque article |
| Supprimer un article | Icône poubelle à droite de l'article |
| Vider le panier | Bouton **"Vider le panier"** en bas de page |
| Accéder au checkout | Bouton **"Passer la commande"** dans le résumé |

### Résumé du panier

- Sous-total des articles
- Frais de livraison (calculés automatiquement)
- **Total TTC**

---

## 6. Manipulation 4 — Passer une commande (checkout)

**URL** : http://localhost:3001/checkout  
**Accès** : Connexion requise (redirige vers `/login` sinon)

### Étape 1 — Validation de la commande

1. Vérifier le récapitulatif des articles (quantité, prix unitaire, total)
2. Cliquer **"Confirmer et payer"**
3. La commande est créée avec le statut `pending` dans l'order-service

### Étape 2 — Paiement

1. Le formulaire Stripe s'affiche avec le `client_secret` généré par le payment-service
2. **En mode simulation** (sans vraie clé Stripe) : un `client_secret` fictif est généré au format `pi_sim_xxxxx_secret_xxxxx`
3. En production : saisir les informations de carte bancaire dans le formulaire Stripe
4. Cliquer **"Payer"**

### Après le paiement

- Le panier est vidé automatiquement
- Redirection vers http://localhost:3001/orders
- Un email de confirmation est envoyé (simulé si SendGrid non configuré)

> **Note** : Pour un paiement Stripe réel, ajouter la clé `STRIPE_SECRET_KEY=sk_test_...` dans le fichier `.env` et reconstruire le payment-service.

---

## 7. Manipulation 5 — Suivi des commandes

**URL** : http://localhost:3001/orders  
**Accès** : Connexion requise

### Selon le rôle

| Rôle | Ce qui est visible |
|---|---|
| `customer` | Uniquement ses propres commandes |
| `merchant_staff` | Toutes les commandes du tenant |
| `merchant_owner` | Toutes les commandes du tenant |
| `platform_admin` | Toutes les commandes de tous les tenants |

### Actions disponibles

| Action | Rôles autorisés |
|---|---|
| Voir la liste des commandes | Tous |
| Voir le détail d'une commande | Tous |
| **Créer une commande manuellement** | `merchant_staff`, `merchant_owner`, `platform_admin` |
| **Modifier le statut d'une commande** | `merchant_staff`, `merchant_owner`, `platform_admin` |

### Statuts possibles d'une commande

| Statut | Signification |
|---|---|
| `pending` | En attente de traitement |
| `confirmed` | Commande confirmée |
| `shipped` | Expédiée |
| `cancelled` | Annulée |

### Créer une commande manuellement (marchands)

1. Cliquer **"+ Nouvelle commande"**
2. Renseigner le(s) produit(s) avec productId, quantité et prix unitaire
3. Sélectionner le statut initial
4. Cliquer **"Créer"**

---

## 8. Manipulation 6 — Paiements

**URL** : http://localhost:3001/payments  
**Accès** : Rôles `merchant_staff`, `merchant_owner`, `platform_admin` uniquement

### Consulter les paiements

1. La page liste tous les paiements du tenant avec :
   - ID du paiement
   - Montant
   - Statut (`pending`, `succeeded`, `failed`)
   - Date de création
2. En haut : résumé financier
   - **Total brut** : somme de tous les paiements réussis
   - **Commission plateforme (5%)** : part reversée à la plateforme
   - **Net marchand** : montant après commission

### Exporter les paiements

- Bouton **"Exporter CSV"** : génère un fichier CSV téléchargeable avec tous les paiements

---

## 9. Manipulation 7 — Favoris

**URL** : http://localhost:3001/favorites  
**Accès** : Connexion requise

### Gérer les favoris

| Action | Comment |
|---|---|
| Ajouter un favori | Icône cœur sur une fiche produit (page `/products/[id]`) |
| Retirer un favori | Re-cliquer sur le cœur (toggle) |
| Voir tous ses favoris | Menu utilisateur → **"Favoris"** ou URL `/favorites` |
| Accéder à un produit favori | Cliquer sur la carte produit dans la liste des favoris |

---

## 10. Manipulation 8 — Profil utilisateur

**URL** : http://localhost:3001/profile  
**Accès** : Connexion requise

### Modifier le profil

1. Ouvrir http://localhost:3001/profile
2. **Section "Informations"** :
   - Modifier le nom complet
   - Modifier l'adresse email
   - Cliquer **"Sauvegarder"**
3. **Section "Mot de passe"** :
   - Saisir le mot de passe actuel
   - Saisir le nouveau mot de passe (minimum 8 caractères)
   - Confirmer le nouveau mot de passe
   - Cliquer **"Changer le mot de passe"**

---

## 11. Manipulation 9 — Notifications

**URL** : http://localhost:3001/notifications  
**Accès** : Connexion requise

### Consulter l'historique

1. La page affiche toutes les notifications envoyées (emails et SMS)
2. Chaque entrée indique :
   - **Type** : EMAIL ou SMS
   - **Destinataire** : adresse email ou numéro de téléphone
   - **Sujet** : titre de la notification
   - **Statut** : `queued`, `sent`, `failed`
   - **Date** d'envoi

### Filtrer les notifications

| Filtre | Valeurs possibles |
|---|---|
| **Type** | Tous, Email, SMS |
| **Statut** | Tous, En attente, Envoyé, Échoué |

> **Note** : Les emails sont simulés si `SENDGRID_API_KEY` n'est pas configuré. Les SMS sont simulés si les clés Twilio ne sont pas configurées. Les notifications apparaissent dans l'historique avec le statut `sent` même en simulation.

---

## 12. Manipulation 10 — Dashboard marchand

**URL** : http://localhost:3001/dashboard  
**Accès** : Rôles `merchant_staff`, `merchant_owner`, `platform_admin` uniquement

### KPIs affichés

| Indicateur | Source |
|---|---|
| Chiffre d'affaires total | Paiements réussis (payment-service) |
| Nombre de commandes | Order-service |
| Panier moyen | Total / Nombre de commandes |
| Nombre de produits | Product-service |
| Commission plateforme (5%) | Calculé côté frontend |
| Net marchand | CA − commission |

### Accès rapides

- **Voir les commandes** → `/orders`
- **Voir les produits** → `/products`
- **Voir les paiements** → `/payments`

---

## 13. Manipulation 11 — Onboarding (configuration boutique)

**URL** : http://localhost:3001/onboarding  
**Accès** : Rôles `merchant_owner`, `platform_admin` uniquement

### Wizard en 5 étapes

| Étape | Champs | Action |
|---|---|---|
| 1. Infos boutique | Nom de la boutique, URL du logo | Saisir et cliquer **"Suivant"** |
| 2. Choix du plan | Free / Starter (29€/mois) / Pro (99€/mois) / Enterprise (299€/mois) | Sélectionner et cliquer **"Suivant"** |
| 3. Configuration | Nom de domaine (subdomain), Description | Saisir et cliquer **"Suivant"** |
| 4. Produits | Méthode d'import (Manuel ou CSV) | Choisir et cliquer **"Suivant"** |
| 5. Équipe | Emails des membres à inviter | Saisir les emails et cliquer **"Terminer"** |

À la fin du wizard, redirection automatique vers `/dashboard`.

---

## 14. Tableau des rôles et accès

| Page / Fonctionnalité | `customer` | `merchant_staff` | `merchant_owner` | `platform_admin` |
|---|:---:|:---:|:---:|:---:|
| Accueil, Catalogue, Aide | ✅ | ✅ | ✅ | ✅ |
| Connexion / Inscription | ✅ | ✅ | ✅ | ✅ |
| Panier | ✅ | ✅ | ✅ | ✅ |
| Checkout / Paiement | ✅ | ✅ | ✅ | ✅ |
| Mes commandes (lecture) | ✅ | ✅ | ✅ | ✅ |
| Créer / Modifier commande | ❌ | ✅ | ✅ | ✅ |
| Favoris | ✅ | ✅ | ✅ | ✅ |
| Profil (modifier) | ✅ | ✅ | ✅ | ✅ |
| Notifications | ✅ | ✅ | ✅ | ✅ |
| Dashboard marchand | ❌ | ✅ | ✅ | ✅ |
| Historique paiements + CSV | ❌ | ✅ | ✅ | ✅ |
| Onboarding | ❌ | ❌ | ✅ | ✅ |
| Gestion équipe | ❌ | ❌ | ✅ | ✅ |

---

## 15. Fonctionnalités non disponibles

### Gestion d'équipe (`/team`) — Partiellement non fonctionnelle

La page `/team` est accessible dans l'interface mais les appels backend retournent **404** car les routes `GET /api/v1/team/users`, `POST /api/v1/team/invite` et `PATCH /api/v1/team/users/{id}/status` **ne sont pas implémentées dans l'auth-service**.

**Impact** : La liste des membres et l'invitation de nouveaux membres ne fonctionnent pas.  
**Contournement** : Les utilisateurs peuvent s'inscrire directement via `/register`.

### Paiement Stripe réel

En l'absence d'une vraie clé Stripe, le payment-service fonctionne en **mode simulation** :
- Les `client_secret` générés sont fictifs (`pi_sim_xxxxx_secret_xxxxx`)
- Le formulaire Stripe affiche une erreur si on tente de compléter le paiement avec ces données fictives

**Pour activer le vrai Stripe** :
1. Créer un compte sur https://dashboard.stripe.com
2. Récupérer la clé de test `sk_test_...`
3. Ajouter dans `.env` :
   ```
   STRIPE_SECRET_KEY=sk_test_VOTRE_CLE
   STRIPE_WEBHOOK_SECRET=whsec_VOTRE_SECRET
   ```
4. Reconstruire le container : `docker compose up -d --build payment-service`

### Envoi réel d'emails (SendGrid)

Les emails sont **simulés** en dev. Pour activer les vrais emails :
1. Créer un compte sur https://sendgrid.com
2. Générer une API Key
3. Ajouter dans `.env` :
   ```
   SENDGRID_API_KEY=SG.VOTRE_CLE
   SENDGRID_FROM_EMAIL=votre@email.com
   ```
4. Redémarrer : `docker compose restart notification-service notification-worker`

### Envoi réel de SMS (Twilio)

Les SMS sont **simulés** en dev. Pour activer les vrais SMS :
1. Créer un compte sur https://www.twilio.com
2. Ajouter dans `.env` :
   ```
   TWILIO_ACCOUNT_SID=AC...
   TWILIO_AUTH_TOKEN=...
   TWILIO_PHONE_NUMBER=+1XXXXXXXXXX
   ```
3. Redémarrer : `docker compose restart notification-service notification-worker`

---

## 16. Référence des services et ports

| Service | Technologie | Port | Base de données |
|---|---|---|---|
| Frontend (API Gateway) | Next.js 16 | 3001 | — |
| Auth Service | Python FastAPI | 8000 | PostgreSQL |
| Order Service | NestJS 10 | 3000 | PostgreSQL |
| Product Service | NestJS 10 | 4000 | PostgreSQL |
| Payment Service | Go + Fiber | 5000 | PostgreSQL |
| Notification Service | Python FastAPI + Celery | 6000 | PostgreSQL |
| Tenant Service | NestJS 10 | 7000 | PostgreSQL |
| PostgreSQL | — | 5433 (host) | — |
| Redis | — | 6380 (host) | — |

### Commandes utiles

```bash
# Voir tous les conteneurs et leur état
docker ps

# Voir les logs d'un service
docker logs auth-service --tail 50 -f

# Redémarrer un service
docker compose restart auth-service

# Reconstruire et relancer un service
docker compose up -d --build payment-service

# Arrêter tout
docker compose down

# Arrêter et supprimer les volumes (reset complet)
docker compose down -v
```
