# Plan de refonte complète du Frontend

> Ce document liste chronologiquement toutes les étapes de développement nécessaires  
> pour produire un frontend fonctionnel, connecté aux 6 microservices existants.  
> Chaque étape est vérifiable indépendamment avant de passer à la suivante.

---

## Principes directeurs

- **Pas de mock ni simulation UI** : toutes les données affichées proviennent de la base de données via les APIs. Les modes "simulation" sont gérés côté backend (payment, notification) — le frontend se contente d'afficher ce que les APIs retournent.
- **Stack maintenue** : Next.js 16 App Router, TypeScript, Tailwind CSS v4.
- **Design system unifié** : un seul fichier de tokens (couleurs, typographie, espacements) utilisé partout.
- **API Gateway strict** : zéro appel direct aux services backend, tout passe par les routes `/api/*` du Next.js.
- **Données réelles** : les seeds du backend fournissent des produits, tenants et utilisateurs réels — pas de placeholder côté frontend.

---

## Phase 0 — Nettoyage et mise en place

### Étape 0.1 — Suppression de l'existant

- [x] Supprimer tout le contenu du dossier `frontend/`
- [x] Initialiser un nouveau projet Next.js 16 avec TypeScript et App Router :

  ```bash
  npx create-next-app@latest frontend --typescript --tailwind --app --src-dir=false --import-alias="@/*"
  ```

- [x] Conserver le `Dockerfile` multi-stage existant (standalone mode)
- [x] Conserver le `next.config.ts` avec `output: 'standalone'`

**Validation** : `docker compose up -d --build frontend` démarre sans erreur, <http://localhost:3001> retourne HTTP 200.

---

### Étape 0.2 — Design system et configuration globale

- [x] Définir les tokens CSS dans `app/globals.css` :
  - Palette de couleurs (primary, secondary, success, warning, error, neutral)
  - Typographie (tailles, poids)
  - Espacements, radius, shadows
- [x] Créer `lib/constants.ts` : URLs des services, messages d'erreur, énumérations (rôles, statuts)
- [x] Créer `lib/types.ts` : tous les types TypeScript basés sur les modèles de données des 6 services
- [x] Créer `lib/utils.ts` : fonctions utilitaires (formatage prix, dates, statuts)
- [x] Installer les dépendances UI : `clsx`, `tailwind-merge`, `lucide-react` (icônes)

**Validation** : `npm run build` sans erreur TypeScript.

---

### Étape 0.3 — Couche API Gateway (routes proxy)

Créer **toutes** les routes `app/api/*/route.ts` qui proxifient vers les services backend.  
Chaque route doit :

- Extraire le JWT du cookie `auth-token` ou du header `Authorization`
- Extraire `X-Tenant-ID` du cookie `x-tenant-id` ou du header
- Forwarder ces headers au service backend
- Retourner la réponse telle quelle (statut + body)

#### Routes à créer

**Auth Service (port 8000)**

- [x] `POST /api/auth/register` → `AUTH_SERVICE/auth/register`
- [x] `POST /api/auth/login` → `AUTH_SERVICE/auth/login`
- [x] `GET /api/auth/validate` → `AUTH_SERVICE/auth/validate`
- [x] `POST /api/auth/logout` → `AUTH_SERVICE/auth/logout`
- [x] `GET /api/users/me` → `AUTH_SERVICE/api/v1/users/me`
- [x] `PATCH /api/users/me` → `AUTH_SERVICE/api/v1/users/me`
- [x] `PATCH /api/users/me/password` → `AUTH_SERVICE/api/v1/users/me/password`
- [x] `GET /api/tenants` → `AUTH_SERVICE/tenants` (admin only)
- [x] `GET /api/tenants/[id]` → `AUTH_SERVICE/tenants/{id}`
- [x] `PATCH /api/tenants/[id]` → `AUTH_SERVICE/tenants/{id}`

**Product Service (port 4000)**

- [x] `GET /api/products` → `PRODUCT_SERVICE/products` (tenant) ou `/products/all` (marketplace)
- [x] `POST /api/products` → `PRODUCT_SERVICE/products` (création)
- [x] `GET /api/products/[id]` → `PRODUCT_SERVICE/products/{id}`
- [x] `PUT /api/products/[id]` → `PRODUCT_SERVICE/products/{id}`
- [x] `DELETE /api/products/[id]` → `PRODUCT_SERVICE/products/{id}`
- [x] `PATCH /api/products/[id]/stock` → `PRODUCT_SERVICE/products/{id}/stock`
- [x] `GET /api/products/search` → `PRODUCT_SERVICE/products/search?q=`
- [x] `GET /api/categories` → `PRODUCT_SERVICE/categories`
- [x] `GET /api/products/[id]/reviews` → `PRODUCT_SERVICE/products/{id}/reviews`
- [x] `POST /api/products/[id]/reviews` → `PRODUCT_SERVICE/products/{id}/review`
- [x] `PUT /api/reviews/[id]` → `PRODUCT_SERVICE/reviews/{id}`
- [x] `DELETE /api/reviews/[id]` → `PRODUCT_SERVICE/reviews/{id}`
- [x] `GET /api/favorites` → `PRODUCT_SERVICE/favorites`
- [x] `POST /api/favorites/[productId]` → `PRODUCT_SERVICE/products/{id}/favorite`
- [x] `DELETE /api/favorites/[productId]` → `PRODUCT_SERVICE/products/{id}/favorite`
- [x] `GET /api/favorites/check/[productId]` → `PRODUCT_SERVICE/favorites/check/{productId}`
- [x] `POST /api/products/validate-batch` → `PRODUCT_SERVICE/products/validate-batch`
- [x] `POST /api/products/decrement-stock` → `PRODUCT_SERVICE/products/decrement-stock`

**Order Service (port 3000)**

- [x] `GET /api/orders` → `ORDER_SERVICE/orders`
- [x] `POST /api/orders` → `ORDER_SERVICE/orders`
- [x] `GET /api/orders/[id]` → `ORDER_SERVICE/orders/{id}`
- [x] `PUT /api/orders/[id]` → `ORDER_SERVICE/orders/{id}`
- [x] `DELETE /api/orders/[id]` → `ORDER_SERVICE/orders/{id}`

**Payment Service (port 5000)**

- [x] `POST /api/payments/create-intent` → `PAYMENT_SERVICE/api/v1/payments/create-intent`
- [x] `GET /api/payments` → `PAYMENT_SERVICE/api/v1/payments/`
- [x] `GET /api/payments/[id]` → `PAYMENT_SERVICE/api/v1/payments/{id}`

**Notification Service (port 6000)**

- [x] `GET /api/notifications` → `NOTIFICATION_SERVICE/api/v1/notifications/history`
- [x] `GET /api/notifications/unread-count` → `NOTIFICATION_SERVICE/api/v1/notifications/unread-count`
- [x] `GET /api/notifications/stats` → `NOTIFICATION_SERVICE/api/v1/notifications/stats`

**Tenant Service (port 7000)**

- [x] `GET /api/plans` → `TENANT_SERVICE/plans`
- [x] `POST /api/tenant-onboarding` → `TENANT_SERVICE/tenants`
- [x] `GET /api/tenant-onboarding/[tenantId]/progress` → `TENANT_SERVICE/onboarding/{id}/progress`
- [x] `POST /api/tenant-onboarding/[tenantId]/complete-step` → `TENANT_SERVICE/onboarding/{id}/complete-step`

**Validation** : chaque route testée avec `curl -s http://localhost:3001/api/[route]` retourne un code HTTP attendu (200 ou 401 si non authentifié).

---

### Étape 0.4 — Gestion de l'authentification côté client

- [x] Créer `lib/auth.ts` :
  - `saveSession(token, user)` → stocke dans localStorage + cookie `auth-token`
  - `getSession()` → lit depuis localStorage
  - `clearSession()` → supprime token et cookies
  - `getToken()` → retourne le JWT courant
  - `getTenantId()` → retourne le `tenant_id` de l'utilisateur courant
- [x] Créer `lib/auth-context.tsx` : Context React qui expose `user`, `isAuthenticated`, `isLoading`, `login()`, `logout()`, `refreshUser()`
- [x] Envelopper `app/layout.tsx` dans `<AuthProvider>`
- [x] Créer le composant `components/auth/ProtectedRoute.tsx` : redirige vers `/login` si non authentifié

**Validation** : connexion sur <http://localhost:3001/login> avec `admin@example.com` / `Test1234!` → le token est stocké, l'utilisateur est chargé.

---

## Phase 1 — Layout et navigation

### Étape 1.1 — Layout principal

- [x] Créer `app/layout.tsx` : HTML global, `<AuthProvider>`, `<ToastProvider>`
- [x] Créer `components/layout/Header.tsx` :
  - Logo + nom de l'application (cliquable → `/`)
  - Barre de recherche globale (produits)
  - Icône panier avec badge (nombre d'articles)
  - Icône notifications avec badge (unread-count depuis l'API)
  - Menu utilisateur : avatar, nom, rôle → dropdown avec liens Profil / Déconnexion
  - Si non connecté : boutons "Connexion" et "S'inscrire"
- [x] Créer `components/layout/Footer.tsx` : liens légaux, version, état des services
- [x] Créer `components/layout/Sidebar.tsx` : navigation latérale conditionnelle selon le rôle

**Validation** : le header s'affiche sur toutes les pages, le badge notifications se charge depuis l'API.

---

### Étape 1.2 — Composants UI de base

Créer dans `components/ui/` :

- [x] `Button.tsx` : variantes primary, secondary, outline, ghost, danger ; tailles sm, md, lg ; état loading avec spinner
- [x] `Input.tsx` : label flottant, message d'erreur, icône optionnelle
- [x] `Badge.tsx` : variantes de couleur selon les statuts
- [x] `Card.tsx` : conteneur avec shadow et radius
- [x] `Modal.tsx` : dialog avec backdrop, header, body, footer
- [x] `Spinner.tsx` : animation de chargement
- [x] `Skeleton.tsx` : placeholder de chargement (1-5 lignes)
- [x] `Toast.tsx` + `ToastContainer.tsx` : notifications temporaires (success, error, info, warning)
- [x] `Pagination.tsx` : navigation entre pages
- [x] `EmptyState.tsx` : illustration + texte pour les listes vides
- [x] `ErrorBoundary.tsx` : capture des erreurs React avec message utilisateur
- [x] `Table.tsx` : tableau responsive avec tri et sélection

**Validation** : chaque composant visible dans un fichier de démonstration `/dev` (à supprimer en fin de projet).

---

### Étape 1.3 — Pages d'erreur

- [x] `app/not-found.tsx` : page 404 avec retour à l'accueil
- [x] `app/error.tsx` : page d'erreur globale avec retry
- [x] `app/loading.tsx` : skeleton global pendant les navigations

---

## Phase 2 — Authentification (pages)

### Étape 2.1 — Page de connexion

**URL** : `/login`

- [x] Formulaire : champ email, champ mot de passe (toggle visibilité), bouton "Se connecter"
- [x] Validation côté client : email valide, mot de passe non vide
- [x] Appel `POST /api/auth/login` avec `X-Tenant-ID` (depuis cookie ou tenant par défaut)
- [x] En cas de succès : `saveSession(token, user)`, redirection vers `/` ou URL de retour (`?redirect=`)
- [x] En cas d'erreur : message d'erreur sous le formulaire (pas de toast)
- [x] Lien "Pas encore de compte ? S'inscrire" → `/register`
- [x] Si déjà connecté : redirection immédiate vers `/`

**Validation** :

- Login avec `admin@example.com` / `Test1234!` → redirige vers `/`
- Login avec mauvais mot de passe → message "Identifiants incorrects" visible

---

### Étape 2.2 — Page d'inscription

**URL** : `/register`

- [x] Formulaire : email, mot de passe (min 8 caractères), confirmation mot de passe, nom complet (optionnel)
- [x] Validation : email unique, mots de passe identiques et conformes
- [x] Appel `POST /api/auth/register`
- [x] En cas de succès : session sauvegardée, redirection vers `/`
- [x] En cas d'erreur : affichage du message d'erreur backend (ex. email déjà utilisé)

**Validation** :

- Inscription avec un nouvel email → compte créé, session active
- Inscription avec un email déjà existant → message d'erreur affiché

---

## Phase 3 — Catalogue produits (pages publiques)

### Étape 3.1 — Page catalogue

**URL** : `/products`

- [x] Appel `GET /api/products` (avec `X-Tenant-ID` si connecté, sinon mode marketplace via `?all=true`)
- [x] Affichage en grille responsive (4 colonnes desktop, 2 tablette, 1 mobile)
- [x] Chaque `ProductCard` affiche : image, nom, catégorie, prix, note étoiles, stock disponible
- [x] **Filtres** (panneau latéral ou drawer mobile) :
  - Catégorie : `GET /api/categories` → liste de checkboxes
  - Fourchette de prix : slider double (min/max)
  - En stock seulement : checkbox
- [x] **Tri** : menu déroulant (Prix croissant, Prix décroissant, Note, Popularité)
- [x] **Recherche** : barre de recherche → `GET /api/products/search?q=` avec debounce 300ms
- [x] Nombre de résultats affiché ("X produits trouvés")
- [x] Pagination ou infinite scroll
- [x] Skeleton pendant le chargement (grille de 8 cartes fantômes)
- [x] État vide si aucun résultat avec message et reset des filtres

**Validation** :

- La page affiche les 20+ produits seedés
- Filtrage par catégorie "Electronics" → uniquement les produits electronics
- Recherche "laptop" → résultats filtrés
- Skeleton visible pendant 300ms+ au premier chargement

---

### Étape 3.2 — Page fiche produit

**URL** : `/products/[id]`

- [x] Appel `GET /api/products/[id]`
- [x] Layout deux colonnes : image (gauche) + informations (droite)
- [x] Informations affichées : nom, catégorie (badge), prix, note étoiles + nombre d'avis, stock (badge vert/rouge/orange), description
- [x] **Sélecteur de quantité** : input numérique avec `+` / `−`, max = stock disponible
- [x] **Bouton "Ajouter au panier"** : désactivé si stock = 0
- [x] **Bouton favori** (cœur) : `GET /api/favorites/check/[id]` pour l'état initial, `POST` / `DELETE /api/favorites/[id]` au clic (connecté requis)
- [x] Section **avis** :
  - Appel `GET /api/products/[id]/reviews`
  - Affichage de la liste (auteur anonymisé, note, commentaire, date)
  - Formulaire d'ajout d'avis si connecté : note (1-5 étoiles cliquables), commentaire optionnel → `POST /api/products/[id]/reviews`
- [x] Breadcrumb : Accueil > Produits > [Catégorie] > [Nom produit]
- [x] Skeleton pendant le chargement

**Validation** :

- Page charge les données réelles d'un produit
- Ajout au panier met à jour le badge du header
- Ajout d'un favori (connecté) persiste après refresh de la page
- Ajout d'un avis apparaît dans la liste sans reload de page

---

## Phase 4 — Panier

### Étape 4.1 — Gestion du panier (état local)

- [x] Créer `lib/cart.tsx` : Context React avec état du panier en localStorage
  - `addItem(product, quantity)` : vérifie le stock disponible via `POST /api/products/validate-batch`
  - `removeItem(productId)`
  - `updateQuantity(productId, quantity)`
  - `clearCart()`
  - `getTotal()` : calcule le total TTC
  - `itemCount` : nombre total d'articles
- [x] `CartButton` dans le header : icône + badge avec `itemCount`
- [x] `CartDropdown` : preview du panier (max 3 articles + "Voir le panier") au survol/clic

**Validation** : ajout de 2 produits différents → badge = 2, total correct affiché dans le dropdown.

---

### Étape 4.2 — Page panier

**URL** : `/cart`

- [x] Liste des articles avec : image miniature, nom, prix unitaire, quantité modifiable, total ligne, bouton suppression
- [x] Résumé : sous-total, frais de livraison (0€ si > 50€, sinon 5€), total TTC
- [x] **Vider le panier** (avec confirmation via Modal)
- [x] **Continuer les achats** → `/products`
- [x] **Passer la commande** → `/checkout` (redirige vers `/login?redirect=/checkout` si non connecté)
- [x] Si panier vide : `EmptyState` avec bouton "Découvrir les produits"
- [x] Vérification stock en temps réel via `POST /api/products/validate-batch` → alerte si un article n'est plus disponible

**Validation** :

- Modification de quantité met à jour le total instantanément
- Article hors stock : alerte visible, bouton checkout désactivé

---

## Phase 5 — Checkout et paiement

### Étape 5.1 — Page checkout

**URL** : `/checkout` (route protégée)

**Étape 1 : Récapitulatif**

- [x] Affichage de la liste des articles du panier (lecture seule)
- [x] Total de la commande
- [x] Bouton "Confirmer et payer" → appel `POST /api/orders` avec les articles et `status: "pending"`
- [x] En cas de succès : passer à l'étape 2 avec l'`orderId` retourné

**Étape 2 : Paiement**

- [x] Appel `POST /api/payments/create-intent` avec `amount` et `order_id`
- [x] Affichage du formulaire Stripe avec le `client_secret`
- [x] **En mode simulation** (clé Stripe fictive) : afficher un message "Mode test — aucun paiement réel" + bouton "Simuler le paiement réussi" qui marque le paiement comme `succeeded` directement (via un appel au webhook interne ou en redirigeant directement)
- [x] **En mode production** (vraie clé Stripe) : formulaire Stripe complet
- [x] En cas de succès : vider le panier + décrémenter le stock via `POST /api/products/decrement-stock` + redirection vers `/orders?success=true`
- [x] En cas d'erreur : message d'erreur explicite + bouton "Réessayer"

**Validation** :

- Commande créée apparaît dans `GET /api/orders`
- Paiement créé apparaît dans `GET /api/payments`
- Stock du produit décrémenté dans `GET /api/products/[id]`

---

## Phase 6 — Commandes

### Étape 6.1 — Page liste des commandes

**URL** : `/orders` (route protégée)

- [x] Appel `GET /api/orders`
- [x] Tableau des commandes avec colonnes : ID (tronqué), Date, Statut (badge coloré), Statut paiement (badge), Total, Actions
- [x] Badges de statut :
  - `pending` → jaune
  - `confirmed` → bleu
  - `shipped` → violet
  - `cancelled` → rouge
- [x] Badges paiement :
  - `unpaid` / `pending` → gris
  - `paid` / `succeeded` → vert
  - `failed` → rouge
- [x] **Filtre par statut** : tabs ou menu déroulant
- [x] Clic sur une commande → drawer ou page `/orders/[id]` avec le détail
- [x] **Pour les marchands/admins** : bouton "+ Nouvelle commande" → Modal `OrderForm`
- [x] Skeleton pendant le chargement
- [x] `EmptyState` si aucune commande

**Validation** :

- La commande créée au checkout apparaît dans la liste
- Filtrage par statut "pending" → uniquement les commandes pending

---

### Étape 6.2 — Page détail d'une commande

**URL** : `/orders/[id]` (route protégée)

- [x] Appel `GET /api/orders/[id]`
- [x] Affichage complet : ID, date, statuts, liste des articles avec prix, total détaillé
- [x] **Pour les marchands/admins** : sélecteur de statut modifiable → `PUT /api/orders/[id]`
- [x] Lien vers le paiement associé si `paymentId` existe

**Validation** : changement de statut `pending` → `confirmed` reflété immédiatement sans reload.

---

## Phase 7 — Paiements

### Étape 7.1 — Page historique des paiements

**URL** : `/payments` (marchands et admins uniquement)

- [x] Appel `GET /api/payments`
- [x] Résumé en haut (3 cartes KPI) :
  - Total encaissé (paiements `succeeded`)
  - Commission plateforme (5%)
  - Net marchand
- [x] Tableau des paiements : ID, Commande liée, Montant, Commission, Statut, Date
- [x] Badge de statut coloré (`succeeded` vert, `pending` jaune, `failed` rouge)
- [x] **Export CSV** : génération client-side du CSV à partir des données affichées
- [x] Pagination

**Validation** :

- Le paiement créé au checkout apparaît dans la liste
- L'export CSV contient toutes les lignes du tableau

---

## Phase 8 — Compte utilisateur

### Étape 8.1 — Page profil

**URL** : `/profile` (route protégée)

- [x] Appel `GET /api/users/me` au chargement
- [x] **Section "Informations"** :
  - Champs : nom complet, email (en lecture si `email_verified = false` → indication)
  - Bouton "Sauvegarder" → `PATCH /api/users/me`
  - Toast de confirmation
- [x] **Section "Mot de passe"** :
  - Champs : mot de passe actuel, nouveau mot de passe, confirmation
  - Bouton "Changer le mot de passe" → `PATCH /api/users/me/password`
  - Toast de confirmation ou message d'erreur
- [x] **Section "Mon compte"** :
  - Affichage du rôle, de la date de création, de l'état de vérification email

**Validation** :

- Changement de nom → visible immédiatement dans le header
- Changement de mot de passe incorrect → message d'erreur précis

---

### Étape 8.2 — Page favoris

**URL** : `/favorites` (route protégée)

- [x] Appel `GET /api/favorites`
- [x] Grille de `ProductCard` avec bouton "Retirer des favoris" sur chaque carte
- [x] Suppression optimiste (retire immédiatement de l'UI, rollback si erreur)
- [x] `EmptyState` avec lien vers `/products`

**Validation** :

- Produit ajouté en favori depuis `/products/[id]` apparaît ici
- Suppression : disparaît immédiatement de la grille

---

## Phase 9 — Notifications

### Étape 9.1 — Page historique des notifications

**URL** : `/notifications` (route protégée)

- [x] Appel `GET /api/notifications` avec pagination
- [x] Appel `GET /api/notifications/stats` pour le résumé en haut
- [x] Tableau des notifications : Type (Email/SMS), Destinataire, Sujet, Statut, Date d'envoi
- [x] **Filtres** : Type (Tous/Email/SMS), Statut (Tous/Envoyé/Échoué/En attente)
- [x] Badge de statut coloré (`sent` vert, `failed` rouge, `queued`/`pending` jaune)
- [x] **Badge "non lues"** dans le header : appel `GET /api/notifications/unread-count` au chargement et toutes les 30 secondes (polling)

**Validation** :

- La notification welcome-email apparaît après inscription
- La notification order-confirmation apparaît après un checkout
- Le badge dans le header affiche le bon compteur

---

## Phase 10 — Dashboard marchand

### Étape 10.1 — Page tableau de bord

**URL** : `/dashboard` (marchands et admins uniquement)

- [x] **KPIs** (4 cartes) chargés en parallèle :
  - Chiffre d'affaires : somme des `amount` des paiements `succeeded` (depuis `GET /api/payments`)
  - Nombre de commandes : count depuis `GET /api/orders`
  - Panier moyen : CA / nb commandes
  - Nombre de produits actifs : count depuis `GET /api/products`
- [x] Commission plateforme (5% du CA) et Net marchand
- [x] **Tableau des dernières commandes** (5 plus récentes) : colonnes ID, Statut, Total
- [x] **Accès rapides** : boutons vers `/orders`, `/products`, `/payments`
- [x] Skeleton sur chaque KPI en attente

**Validation** :

- Les KPIs correspondent aux données réelles des APIs
- Les chiffres se mettent à jour après un nouveau paiement

---

## Phase 11 — Gestion des produits (marchands)

### Étape 11.1 — Page gestion des produits

**URL** : `/products/manage` (marchands et admins uniquement)

- [x] Appel `GET /api/products` (vue tenant, pas marketplace)
- [x] Tableau avec colonnes : Image, Nom, Catégorie, Prix, Stock, Actif, Actions (Éditer, Supprimer)
- [x] **Créer un produit** : bouton → Modal `ProductForm` :
  - Champs : nom, description, prix, catégorie, URL image, stock initial
  - Appel `POST /api/products`
- [x] **Éditer un produit** : Modal pré-remplie → `PUT /api/products/[id]`
- [x] **Mettre à jour le stock** : input inline dans le tableau → `PATCH /api/products/[id]/stock`
- [x] **Supprimer un produit** : confirmation Modal → `DELETE /api/products/[id]`
- [x] Pagination

**Validation** :

- Produit créé apparaît immédiatement dans la liste
- Modification du stock reflétée dans `/products/[id]` (vue publique)

---

## Phase 12 — Onboarding (marchands)

### Étape 12.1 — Page onboarding

**URL** : `/onboarding` (marchands et admins uniquement)

- [ ] Au chargement : `GET /api/tenant-onboarding/[tenantId]/progress` pour reprendre où on en est
- [ ] Indicateur de progression (stepper 5 étapes)
- [ ] **Étape 1 — Infos boutique** :
  - Champs : nom de la boutique, email de contact, sous-domaine
  - Appel `PATCH /api/tenants/[id]` pour sauvegarder
- [ ] **Étape 2 — Choix du plan** :
  - Appel `GET /api/plans` → affichage des 4 plans (Free/Starter/Pro/Enterprise) en cards comparatives
  - Sélection du plan → `PATCH /api/tenants/[id]`
- [ ] **Étape 3 — Configuration** :
  - Champs : description de la boutique, domaine personnalisé optionnel
  - Sauvegarde → `PATCH /api/tenants/[id]`
- [ ] **Étape 4 — Produits** :
  - Choix de la méthode d'import (Manuel = lien vers `/products/manage`, CSV = upload futur)
  - Affichage du nombre de produits actuels
- [ ] **Étape 5 — Confirmation** :
  - Résumé de la configuration
  - Bouton "Terminer l'onboarding" → `POST /api/tenant-onboarding/[tenantId]/complete-step` avec `{ step: 5 }`
  - Redirection vers `/dashboard`
- [ ] À chaque "Suivant" : `POST /api/tenant-onboarding/[tenantId]/complete-step` avec le numéro de l'étape

**Validation** :

- Progression sauvegardée : refresh de la page → on reste à la même étape
- Fin de l'onboarding → redirection `/dashboard`, `onboardingCompleted: true` dans l'API

---

## Phase 13 — Administration (platform_admin)

### Étape 13.1 — Page gestion des tenants

**URL** : `/admin/tenants` (platform_admin uniquement)

- [ ] Appel `GET /api/tenants`
- [ ] Tableau des tenants : Nom, Slug, Plan, Statut, Date de création, Actions
- [ ] **Modifier un tenant** : Modal → `PATCH /api/tenants/[id]` (nom, plan, statut)
- [ ] **Créer un tenant** : Modal `TenantForm` → `POST /api/tenants` (via auth-service)

**Validation** :

- Changement de statut `active` → `suspended` visible immédiatement dans le tableau

---

### Étape 13.2 — Navigation admin

- [ ] Créer `components/layout/AdminSidebar.tsx` visible uniquement pour `platform_admin`
- [ ] Liens : Tenants, Toutes les commandes, Toutes les notifications, Utilisateurs

---

## Phase 14 — Qualité et finition

### Étape 14.1 — Gestion globale des erreurs réseau

- [ ] Créer `lib/api-client.ts` : wrapper fetch centralisé
  - Timeout de 10 secondes (AbortController)
  - Retry automatique x1 sur erreur 5xx
  - Interception des 401 → déconnexion automatique + redirection `/login`
  - Toast d'erreur automatique sur les erreurs réseau non gérées

**Validation** : arrêt de l'auth-service → toast "Service indisponible" apparaît sur toutes les pages qui l'appellent.

---

### Étape 14.2 — Accessibilité

- [ ] Tous les formulaires ont des `<label>` associés
- [ ] Navigation au clavier sur tous les composants interactifs
- [ ] `aria-live` sur les zones de feedback (erreurs, confirmations)
- [ ] Contrastes des couleurs conformes WCAG AA
- [ ] Balise `lang="fr"` sur `<html>`

---

### Étape 14.3 — Performance

- [ ] Images : Next.js `<Image>` avec `priority` sur le LCP de chaque page
- [ ] Favoris et produits : SWR ou React Query pour le cache et la revalidation
- [ ] Skeleton sur tous les appels API > 200ms
- [ ] Code splitting automatique par page (App Router)

---

### Étape 14.4 — Responsive mobile

- [ ] Header : menu hamburger sur mobile, drawer de navigation
- [ ] Catalogue : passage automatique 1 colonne sur mobile
- [ ] Formulaires : 100% largeur sur mobile
- [ ] Tableaux : scroll horizontal sur mobile ou vue cards alternatives

---

## Résumé chronologique

| Phase | Étapes | Prérequis | Livrable vérifiable |
|---|---|---|---|
| **0 — Setup** | 0.1 → 0.4 | Docker fonctionnel | Frontend démarre, toutes les routes proxy répondent |
| **1 — Layout** | 1.1 → 1.3 | Phase 0 | Header, footer, composants UI visibles |
| **2 — Auth** | 2.1 → 2.2 | Phase 1 | Login/register fonctionnels avec vrais comptes |
| **3 — Catalogue** | 3.1 → 3.2 | Phase 2 | Produits seedés affichés, filtres fonctionnels |
| **4 — Panier** | 4.1 → 4.2 | Phase 3 | Panier persistant, validation stock réelle |
| **5 — Checkout** | 5.1 | Phase 4 | Commande + paiement créés en DB |
| **6 — Commandes** | 6.1 → 6.2 | Phase 5 | Liste et détail commandes avec mise à jour statut |
| **7 — Paiements** | 7.1 | Phase 5 | Tableau paiements, export CSV |
| **8 — Compte** | 8.1 → 8.2 | Phase 2 | Profil modifiable, favoris persistants |
| **9 — Notifications** | 9.1 | Phase 5 | Historique réel, badge header temps réel |
| **10 — Dashboard** | 10.1 | Phases 6+7 | KPIs basés sur données réelles |
| **11 — Produits admin** | 11.1 | Phase 3 | CRUD produits complet |
| **12 — Onboarding** | 12.1 | Phase 2 | Wizard complet, progression sauvegardée |
| **13 — Admin** | 13.1 → 13.2 | Phase 2 | Gestion tenants fonctionnelle |
| **14 — Qualité** | 14.1 → 14.4 | Toutes phases | Pas d'erreur console, mobile OK |

---

## Points d'attention

### Pas de simulation dans l'UI

- Le payment-service retourne un vrai `client_secret` (fictif en mode simulation, réel avec Stripe) — l'UI affiche toujours ce que l'API retourne. Le paiement est toujours enregistré en DB.
- Le notification-service stocke toujours chaque notification en DB même sans clés SendGrid/Twilio — l'UI affiche l'historique réel.
- **Aucun `Math.random()` ni donnée hardcodée dans les composants d'affichage.**

### Fonctionnalité "Gestion d'équipe" — non implémentée en backend

Les routes `GET /api/v1/team/*` et `POST /api/v1/team/invite` **n'existent pas dans l'auth-service**. Cette fonctionnalité ne doit pas être présente dans le frontend avant d'être implémentée côté backend. Afficher une page "Bientôt disponible" si la navigation y mène.

### Multi-tenant

- Chaque requête vers product-service, order-service et payment-service doit inclure `X-Tenant-ID` dans les headers (extrait du JWT de l'utilisateur connecté).
- Le tenant par défaut `1574b85d-a3df-400f-9e82-98831aa32934` ne doit pas être hardcodé : lire `user.tenant_id` depuis le contexte d'authentification.
