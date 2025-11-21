-- Migration 004: Update Orders Table for Multi-Tenancy
-- Description: Ajout du tenant_id aux commandes

-- Créer les ENUMs
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');

-- Créer la table orders (multi-tenant)
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_name VARCHAR(255),
    shipping_address JSONB,
    status order_status NOT NULL DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    tax DECIMAL(10, 2) DEFAULT 0 CHECK (tax >= 0),
    shipping DECIMAL(10, 2) DEFAULT 0 CHECK (shipping >= 0),
    total DECIMAL(10, 2) NOT NULL CHECK (total >= 0),
    payment_status payment_status DEFAULT 'pending',
    payment_intent_id VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Créer les index
CREATE INDEX idx_orders_tenant ON orders(tenant_id);
CREATE INDEX idx_orders_user ON orders(tenant_id, user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_customer_email ON orders(customer_email);

-- Trigger updated_at
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE
ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sequence pour les numéros de commande
CREATE SEQUENCE order_number_seq START 1;

-- Fonction pour générer un numéro de commande unique
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL THEN
        NEW.order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(nextval('order_number_seq')::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour générer le numéro automatiquement
CREATE TRIGGER set_order_number BEFORE INSERT
ON orders FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- Row-Level Security
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_orders ON orders
    USING (tenant_id = current_setting('app.current_tenant_id', true)::UUID);

COMMENT ON TABLE orders IS 'Commandes avec isolation par tenant';
COMMENT ON COLUMN orders.order_number IS 'Numéro de commande unique (format: ORD-YYYYMMDD-XXXXXX)';
COMMENT ON COLUMN orders.shipping_address IS 'Adresse de livraison (JSON: {street, city, postal_code, country})';

-- Table pour les items de commande
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(255) NOT NULL,
    product_image_url VARCHAR(500),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0)
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

COMMENT ON TABLE order_items IS 'Détail des produits dans une commande';
COMMENT ON COLUMN order_items.product_name IS 'Nom du produit au moment de la commande (snapshot)';

-- Fonction pour calculer le total d'une commande
CREATE OR REPLACE FUNCTION calculate_order_total(order_uuid UUID)
RETURNS DECIMAL AS $$
DECLARE
    items_total DECIMAL;
    order_tax DECIMAL;
    order_shipping DECIMAL;
BEGIN
    SELECT COALESCE(SUM(total_price), 0) INTO items_total
    FROM order_items WHERE order_id = order_uuid;
    
    SELECT tax, shipping INTO order_tax, order_shipping
    FROM orders WHERE id = order_uuid;
    
    RETURN items_total + COALESCE(order_tax, 0) + COALESCE(order_shipping, 0);
END;
$$ LANGUAGE plpgsql;

-- Vue pour les commandes avec statistiques
CREATE OR REPLACE VIEW orders_with_stats AS
SELECT 
    o.*,
    COUNT(oi.id) as items_count,
    SUM(oi.quantity) as total_quantity,
    t.name as tenant_name,
    u.email as user_email
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN tenants t ON o.tenant_id = t.id
LEFT JOIN users u ON o.user_id = u.id
GROUP BY o.id, t.name, u.email;

COMMENT ON VIEW orders_with_stats IS 'Vue enrichie des commandes avec statistiques';

-- Migration des données existantes (si applicable)
/*
INSERT INTO orders (id, tenant_id, user_id, customer_email, status, subtotal, total, created_at)
SELECT 
    id,
    (SELECT id FROM tenants WHERE slug = 'demo-shop'),
    user_id,
    customer_email,
    status::order_status,
    subtotal,
    total,
    created_at
FROM old_orders_table;
*/




