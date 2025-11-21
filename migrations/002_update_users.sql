-- Migration 002: Update Users Table for Multi-Tenancy
-- Description: Ajout du tenant_id et RBAC aux users

-- Créer l'ENUM des rôles
CREATE TYPE user_role AS ENUM (
    'platform_admin',    -- Super admin de la plateforme
    'merchant_owner',    -- Propriétaire du shop
    'merchant_staff',    -- Employé du shop
    'customer'           -- Client acheteur
);

-- Créer la nouvelle table users (multi-tenant)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'customer',
    full_name VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT uq_tenant_email UNIQUE(tenant_id, email)
);

-- Créer les index
CREATE INDEX idx_users_tenant_email ON users(tenant_id, email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_email ON users(email);

-- Trigger updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE
ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row-Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_users ON users
    USING (tenant_id = current_setting('app.current_tenant_id', true)::UUID);

-- Policy pour platform admin (peut tout voir)
CREATE POLICY platform_admin_users ON users
    USING (
        EXISTS (
            SELECT 1 FROM users u 
            WHERE u.id = current_setting('app.current_user_id', true)::UUID 
            AND u.role = 'platform_admin'
        )
    );

-- Commentaires
COMMENT ON TABLE users IS 'Utilisateurs multi-tenant avec RBAC';
COMMENT ON COLUMN users.tenant_id IS 'Référence au tenant (merchant)';
COMMENT ON COLUMN users.role IS 'Rôle RBAC: platform_admin, merchant_owner, merchant_staff, customer';
COMMENT ON COLUMN users.email IS 'Email unique PAR tenant (pas globalement unique)';

-- Migration des données existantes (si applicable)
-- Si vous avez des users SQLite à migrer, décommenter et adapter:
/*
INSERT INTO users (id, tenant_id, email, password_hash, role, created_at)
SELECT 
    id, 
    (SELECT id FROM tenants WHERE slug = 'demo-shop'),  -- Assigner au tenant par défaut
    email,
    password_hash,
    'customer',  -- Rôle par défaut
    created_at
FROM old_users_table;
*/




