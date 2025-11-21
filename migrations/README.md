# Migrations SQL - Multi-Tenant SaaS

Scripts SQL pour transformer la base de données en architecture multi-tenant.

---

## 📋 Liste des Migrations

| Fichier | Description | Dépendances |
|---------|-------------|-------------|
| `001_create_tenants.sql` | Création table `tenants` | - |
| `002_update_users.sql` | Ajout `tenant_id` + RBAC | 001 |
| `003_update_products.sql` | Ajout `tenant_id` + favoris + avis | 001, 002 |
| `004_update_orders.sql` | Ajout `tenant_id` + order_items | 001, 002, 003 |
| `005_create_payments.sql` | Paiements + subscriptions | 001, 002, 004 |

---

## 🚀 Exécution

### Option 1 : Script automatique (recommandé)

```bash
# Exécuter toutes les migrations
cd /home/paul/efrei-project/DevOpsMicroServiceApp/transform/migrations
./run-migrations.sh

# Dry-run (test sans exécution)
./run-migrations.sh --dry-run

# Exécuter une migration spécifique
./run-migrations.sh -f 001_create_tenants.sql

# Voir le statut
./run-migrations.sh --status
```

### Option 2 : Manuellement

```bash
# Se connecter à PostgreSQL
psql -U saas_admin -d saas_platform

# Exécuter les migrations dans l'ordre
\i 001_create_tenants.sql
\i 002_update_users.sql
\i 003_update_products.sql
\i 004_update_orders.sql
\i 005_create_payments.sql
```

### Option 3 : Docker Compose

Les migrations peuvent être exécutées automatiquement au démarrage :

```yaml
# docker-compose.yml
services:
  postgres:
    volumes:
      - ./transform/migrations:/docker-entrypoint-initdb.d:ro
```

---

## 🗄️ Détail des Migrations

### 001_create_tenants.sql

**Crée :**
- Type ENUM `tenant_status` (trial, active, suspended, cancelled)
- Type ENUM `tenant_plan` (free, starter, pro, enterprise)
- Table `tenants` avec colonnes :
  - `id` (UUID, PK)
  - `slug` (unique, pour URL)
  - `name` (nom du shop)
  - `subdomain` (unique, pour multi-tenant routing)
  - `custom_domain` (domaine personnalisé, optionnel)
  - `plan` (free/starter/pro/enterprise)
  - `status` (trial/active/suspended/cancelled)
  - `settings` (JSONB pour config flexible)
- Index sur `slug`, `subdomain`, `status`, `plan`
- Trigger `updated_at` automatique

**Exemple :**
```sql
INSERT INTO tenants (slug, name, subdomain, plan) 
VALUES ('mon-shop', 'Mon Super Shop', 'mon-shop', 'free');
```

---

### 002_update_users.sql

**Crée :**
- Type ENUM `user_role` (platform_admin, merchant_owner, merchant_staff, customer)
- Table `users` avec colonnes :
  - `id` (UUID, PK)
  - `tenant_id` (FK vers tenants, CASCADE)
  - `email` (unique PAR tenant)
  - `password_hash`
  - `role` (RBAC)
  - `full_name`
  - `is_active`
  - `email_verified`
- Contrainte UNIQUE sur `(tenant_id, email)` → Email peut exister dans plusieurs tenants
- Index sur `tenant_id`, `email`, `role`
- Row-Level Security (RLS) activé
- Policies :
  - `tenant_isolation_users` : users voient uniquement leur tenant
  - `platform_admin_users` : platform_admin voit tous les tenants

**Exemple :**
```sql
-- Créer un merchant owner
INSERT INTO users (tenant_id, email, password_hash, role) 
VALUES (
    '...tenant-uuid...', 
    'owner@shop.com', 
    '...hash...', 
    'merchant_owner'
);
```

---

### 003_update_products.sql

**Crée :**
- Table `products` avec colonnes :
  - `id` (UUID, PK)
  - `tenant_id` (FK vers tenants, CASCADE)
  - `name`, `description`, `price`, `category`
  - `stock`, `rating`, `review_count`
  - `is_active` (visible sur storefront)
- Table `favorites` (many-to-many users ↔ products)
- Table `reviews` (avis produits)
  - Contrainte UNIQUE `(user_id, product_id)` → 1 avis par user par produit
- Index sur `tenant_id`, `category`, `is_active`
- Index full-text search (PostgreSQL tsvector)
- Row-Level Security activé
- Fonction `update_product_rating()` : recalcule rating automatiquement
- Trigger pour mettre à jour rating après insertion/update review

**Exemple :**
```sql
-- Créer un produit
INSERT INTO products (tenant_id, name, price, category, stock) 
VALUES ('...tenant-uuid...', 'T-Shirt', 29.99, 'Fashion', 100);

-- Ajouter un avis
INSERT INTO reviews (user_id, product_id, rating, comment)
VALUES ('...user-uuid...', '...product-uuid...', 5, 'Excellent produit!');
```

---

### 004_update_orders.sql

**Crée :**
- Type ENUM `order_status` (pending, processing, shipped, delivered, cancelled, refunded)
- Type ENUM `payment_status` (pending, paid, failed, refunded)
- Table `orders` avec colonnes :
  - `id` (UUID, PK)
  - `order_number` (unique, format: ORD-YYYYMMDD-XXXXXX)
  - `tenant_id` (FK vers tenants)
  - `user_id` (FK vers users, nullable)
  - `customer_email`, `customer_name`
  - `shipping_address` (JSONB)
  - `status`, `subtotal`, `tax`, `shipping`, `total`
  - `payment_status`, `payment_intent_id`
- Table `order_items` (détail des produits)
- Sequence `order_number_seq` pour numéros uniques
- Fonction `generate_order_number()` : génère automatiquement le numéro
- Fonction `calculate_order_total()` : calcule le total
- Vue `orders_with_stats` : commandes enrichies avec statistiques
- Row-Level Security activé

**Exemple :**
```sql
-- Créer une commande
INSERT INTO orders (tenant_id, user_id, customer_email, subtotal, total)
VALUES ('...tenant-uuid...', '...user-uuid...', 'client@email.com', 100.00, 110.00);
-- order_number généré automatiquement: ORD-20250119-000001

-- Ajouter des items
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, total_price)
VALUES ('...order-uuid...', '...product-uuid...', 'T-Shirt', 2, 29.99, 59.98);
```

---

### 005_create_payments.sql

**Crée :**
- Type ENUM `payment_status_enum` (pending, processing, succeeded, failed, refunded, cancelled)
- Type ENUM `subscription_status_enum` (trial, active, past_due, cancelled, expired)
- Table `payments` avec colonnes :
  - `id` (UUID, PK)
  - `tenant_id` (FK vers tenants)
  - `order_id` (FK vers orders)
  - `payment_intent_id` (Stripe Payment Intent ID, unique)
  - `amount`, `currency`
  - `status`
  - `platform_commission` (5% par défaut)
  - `stripe_account_id` (Stripe Connect Account)
  - `metadata` (JSONB)
- Table `refunds` (remboursements liés aux paiements)
- Table `subscriptions` (abonnements des tenants aux plans)
- Vue `tenant_payment_stats` : statistiques de paiement par tenant
- Fonction `check_expired_subscriptions()` : vérifie les abonnements expirés
- Row-Level Security activé

**Exemple :**
```sql
-- Enregistrer un paiement
INSERT INTO payments (tenant_id, order_id, payment_intent_id, amount, platform_commission)
VALUES ('...tenant-uuid...', '...order-uuid...', 'pi_xxx', 110.00, 5.50);

-- Créer un abonnement
INSERT INTO subscriptions (tenant_id, plan, monthly_price, status)
VALUES ('...tenant-uuid...', 'pro', 99.00, 'active');
```

---

## ✅ Vérification

### Après exécution des migrations

```sql
-- Lister toutes les tables
\dt

-- Résultat attendu:
-- tenants, users, products, favorites, reviews, orders, order_items, payments, refunds, subscriptions

-- Vérifier les contraintes
\d tenants
\d users
\d products
\d orders
\d payments

-- Vérifier les policies RLS
\dp tenants
\dp users
\dp products
\dp orders

-- Tester l'isolation tenant
SET app.current_tenant_id = '...tenant-uuid...';
SELECT * FROM products;  -- Devrait voir uniquement les produits de ce tenant
```

---

## 🔄 Rollback

**⚠️ ATTENTION : Le rollback supprime TOUTES les tables et données !**

```bash
# Via script
./run-migrations.sh --rollback

# Manuellement
psql -U saas_admin -d saas_platform << EOF
DROP TABLE IF EXISTS refunds CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS favorites CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS tenants CASCADE;

DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS tenant_status CASCADE;
DROP TYPE IF EXISTS tenant_plan CASCADE;
DROP TYPE IF EXISTS order_status CASCADE;
DROP TYPE IF EXISTS payment_status CASCADE;
EOF
```

---

## 🧪 Données de Test

### Insérer des données de test

```sql
-- 1. Créer un tenant de test
INSERT INTO tenants (slug, name, subdomain, plan, status) VALUES 
('demo-shop', 'Demo Shop', 'demo', 'pro', 'active')
RETURNING id;

-- 2. Créer un merchant owner
INSERT INTO users (tenant_id, email, password_hash, role, full_name) VALUES 
('...tenant-id...', 'owner@demo.com', '...hash...', 'merchant_owner', 'John Doe');

-- 3. Créer des produits
INSERT INTO products (tenant_id, name, description, price, category, stock) VALUES 
('...tenant-id...', 'T-Shirt Blanc', 'T-Shirt 100% coton', 29.99, 'Fashion', 50),
('...tenant-id...', 'Jean Slim', 'Jean bleu délavé', 79.99, 'Fashion', 30);

-- 4. Créer une commande de test
INSERT INTO orders (tenant_id, user_id, customer_email, subtotal, total) VALUES 
('...tenant-id...', '...user-id...', 'customer@email.com', 109.98, 120.98);
```

---

## 📊 Schema Visuel

```
tenants (merchants)
    ├── users (with RBAC)
    ├── products
    │   ├── favorites (user ↔ product)
    │   └── reviews (user → product)
    ├── orders
    │   └── order_items (order → product)
    ├── payments (Stripe)
    │   └── refunds
    └── subscriptions (plans tarifaires)
```

---

## 🔐 Row-Level Security (RLS)

### Concept

PostgreSQL RLS permet d'isoler les données au niveau des lignes. Chaque requête SQL ajoute automatiquement un filtre `WHERE tenant_id = current_tenant_id`.

### Configuration par service

```python
# Dans auth-service (Python/FastAPI)
from sqlalchemy import text

def set_tenant_context(db, tenant_id: str):
    db.execute(text(f"SET app.current_tenant_id = '{tenant_id}'"))
```

```typescript
// Dans product-service (NestJS/TypeORM)
await connection.query(`SET app.current_tenant_id = '${tenantId}'`);
```

### Test RLS

```sql
-- Sans contexte tenant : erreur ou résultat vide
SELECT * FROM products;

-- Avec contexte tenant : résultats filtrés automatiquement
SET app.current_tenant_id = '...tenant-uuid...';
SELECT * FROM products;  -- Voit uniquement les produits de ce tenant
```

---

## 🛠️ Maintenance

### Sauvegardes

```bash
# Backup complet
pg_dump -U saas_admin saas_platform | gzip > backup_$(date +%Y%m%d).sql.gz

# Backup d'une table spécifique
pg_dump -U saas_admin -t tenants saas_platform > tenants_backup.sql
```

### Vacuum & Analyze

```sql
-- Nettoyer et analyser les statistiques (recommandé régulièrement)
VACUUM ANALYZE tenants;
VACUUM ANALYZE users;
VACUUM ANALYZE products;
VACUUM ANALYZE orders;
VACUUM ANALYZE payments;
```

---

## 📚 Ressources

- [PostgreSQL DDL](https://www.postgresql.org/docs/current/ddl.html)
- [Row-Level Security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [JSONB](https://www.postgresql.org/docs/current/datatype-json.html)
- [Triggers](https://www.postgresql.org/docs/current/sql-createtrigger.html)

---

**Migrations complètes pour transformation Multi-Tenant SaaS** ✅




