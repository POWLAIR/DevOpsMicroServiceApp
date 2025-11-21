-- Migration 003: Update Products Table for Multi-Tenancy
-- Description: Ajout du tenant_id aux produits pour isolation

-- Créer la nouvelle table products (multi-tenant)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    category VARCHAR(100),
    image_url VARCHAR(500),
    stock INTEGER DEFAULT 0 CHECK (stock >= 0),
    rating DECIMAL(3, 2) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0 CHECK (review_count >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Créer les index
CREATE INDEX idx_products_tenant ON products(tenant_id);
CREATE INDEX idx_products_category ON products(tenant_id, category);
CREATE INDEX idx_products_active ON products(tenant_id, is_active);
CREATE INDEX idx_products_price ON products(price);

-- Index full-text search sur nom et description (PostgreSQL)
CREATE INDEX idx_products_search ON products USING gin(to_tsvector('french', name || ' ' || COALESCE(description, '')));

-- Trigger updated_at
CREATE TRIGGER update_products_updated_at BEFORE UPDATE
ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row-Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_products ON products
    USING (tenant_id = current_setting('app.current_tenant_id', true)::UUID);

-- Policy pour lecture publique (produits actifs)
CREATE POLICY public_read_products ON products
    FOR SELECT
    USING (is_active = TRUE);

-- Commentaires
COMMENT ON TABLE products IS 'Catalogue produits avec isolation par tenant';
COMMENT ON COLUMN products.tenant_id IS 'Référence au tenant propriétaire du produit';
COMMENT ON COLUMN products.is_active IS 'Produit visible sur le storefront';
COMMENT ON COLUMN products.rating IS 'Moyenne des avis (calculée automatiquement)';

-- Table pour les favoris (many-to-many users <-> products)
CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

CREATE INDEX idx_favorites_user ON favorites(user_id);
CREATE INDEX idx_favorites_product ON favorites(product_id);

COMMENT ON TABLE favorites IS 'Produits favoris des utilisateurs';

-- Table pour les avis (reviews)
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, product_id)  -- Un avis par user par produit
);

CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE
ON reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE reviews IS 'Avis produits laissés par les clients';

-- Fonction pour recalculer le rating d'un produit
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET 
        rating = (SELECT AVG(rating) FROM reviews WHERE product_id = NEW.product_id),
        review_count = (SELECT COUNT(*) FROM reviews WHERE product_id = NEW.product_id)
    WHERE id = NEW.product_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour le rating automatiquement
CREATE TRIGGER update_product_rating_on_review
AFTER INSERT OR UPDATE ON reviews
FOR EACH ROW EXECUTE FUNCTION update_product_rating();

-- Migration des données existantes (si applicable)
/*
INSERT INTO products (id, tenant_id, name, description, price, category, image_url, stock, created_at)
SELECT 
    id,
    (SELECT id FROM tenants WHERE slug = 'demo-shop'),
    name,
    description,
    price,
    category,
    image_url,
    stock,
    created_at
FROM old_products_table;
*/




