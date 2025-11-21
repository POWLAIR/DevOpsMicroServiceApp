-- Migration 001: Create Tenants Table
-- Description: Création de la table tenants pour le multi-tenancy

-- Activer l'extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Créer les types ENUM
CREATE TYPE tenant_status AS ENUM ('trial', 'active', 'suspended', 'cancelled');
CREATE TYPE tenant_plan AS ENUM ('free', 'starter', 'pro', 'enterprise');

-- Créer la table tenants
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(100) UNIQUE,
    custom_domain VARCHAR(255),
    plan tenant_plan NOT NULL DEFAULT 'free',
    status tenant_status NOT NULL DEFAULT 'trial',
    trial_ends_at TIMESTAMP,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Créer les index
CREATE INDEX idx_tenants_slug ON tenants(slug);
CREATE INDEX idx_tenants_subdomain ON tenants(subdomain);
CREATE INDEX idx_tenants_status ON tenants(status);
CREATE INDEX idx_tenants_plan ON tenants(plan);

-- Fonction trigger pour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Trigger pour mettre à jour updated_at automatiquement
CREATE TRIGGER update_tenants_updated_at BEFORE UPDATE
ON tenants FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Commentaires
COMMENT ON TABLE tenants IS 'Table des tenants (merchants) de la plateforme SaaS';
COMMENT ON COLUMN tenants.slug IS 'URL-friendly identifier (ex: ma-boutique)';
COMMENT ON COLUMN tenants.subdomain IS 'Subdomain pour accès (ex: ma-boutique.plateforme.com)';
COMMENT ON COLUMN tenants.custom_domain IS 'Domaine personnalisé (ex: www.ma-boutique.com)';
COMMENT ON COLUMN tenants.settings IS 'Configuration JSON (theme, logo, etc.)';

-- Données de test (optionnel - à supprimer en production)
INSERT INTO tenants (slug, name, subdomain, plan, status) VALUES 
('demo-shop', 'Demo Shop', 'demo', 'pro', 'active');




