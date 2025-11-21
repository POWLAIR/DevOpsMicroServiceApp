-- Migration 005: Create Payments Table
-- Description: Table pour le Payment Service avec Stripe

-- Créer l'ENUM
CREATE TYPE payment_status_enum AS ENUM ('pending', 'processing', 'succeeded', 'failed', 'refunded', 'cancelled');

-- Créer la table payments
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    payment_intent_id VARCHAR(255) UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(3) DEFAULT 'eur',
    status payment_status_enum NOT NULL DEFAULT 'pending',
    platform_commission DECIMAL(10, 2) DEFAULT 0 CHECK (platform_commission >= 0),
    stripe_account_id VARCHAR(255),
    metadata JSONB DEFAULT '{}',
    failure_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Créer les index
CREATE INDEX idx_payments_tenant ON payments(tenant_id);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_intent ON payments(payment_intent_id);
CREATE INDEX idx_payments_created_at ON payments(created_at);

-- Trigger updated_at
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE
ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row-Level Security
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_payments ON payments
    USING (tenant_id = current_setting('app.current_tenant_id', true)::UUID);

COMMENT ON TABLE payments IS 'Paiements Stripe avec commission plateforme';
COMMENT ON COLUMN payments.payment_intent_id IS 'ID du Payment Intent Stripe';
COMMENT ON COLUMN payments.platform_commission IS 'Commission prélevée par la plateforme (5% par défaut)';
COMMENT ON COLUMN payments.stripe_account_id IS 'Stripe Connect Account ID du merchant';

-- Table pour les remboursements
CREATE TABLE refunds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    reason VARCHAR(50),
    stripe_refund_id VARCHAR(255) UNIQUE,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_refunds_payment ON refunds(payment_id);
CREATE INDEX idx_refunds_status ON refunds(status);

COMMENT ON TABLE refunds IS 'Remboursements liés aux paiements';

-- Vue pour les statistiques de paiement par tenant
CREATE OR REPLACE VIEW tenant_payment_stats AS
SELECT 
    tenant_id,
    COUNT(*) as total_payments,
    COUNT(*) FILTER (WHERE status = 'succeeded') as successful_payments,
    COUNT(*) FILTER (WHERE status = 'failed') as failed_payments,
    SUM(amount) FILTER (WHERE status = 'succeeded') as total_revenue,
    SUM(platform_commission) FILTER (WHERE status = 'succeeded') as total_commission,
    AVG(amount) FILTER (WHERE status = 'succeeded') as average_transaction
FROM payments
GROUP BY tenant_id;

COMMENT ON VIEW tenant_payment_stats IS 'Statistiques de paiement par tenant';

-- Table pour les abonnements (subscriptions)
CREATE TYPE subscription_status_enum AS ENUM ('trial', 'active', 'past_due', 'cancelled', 'expired');

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    plan VARCHAR(50) NOT NULL,
    status subscription_status_enum NOT NULL DEFAULT 'trial',
    monthly_price DECIMAL(10, 2) NOT NULL CHECK (monthly_price >= 0),
    stripe_subscription_id VARCHAR(255),
    trial_ends_at TIMESTAMP,
    current_period_start TIMESTAMP,
    current_period_end TIMESTAMP,
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_tenant ON subscriptions(tenant_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_period_end ON subscriptions(current_period_end);

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE
ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE subscriptions IS 'Abonnements des tenants aux plans tarifaires';

-- Fonction pour vérifier les abonnements expirés
CREATE OR REPLACE FUNCTION check_expired_subscriptions()
RETURNS void AS $$
BEGIN
    UPDATE subscriptions
    SET status = 'expired'
    WHERE status = 'active'
    AND current_period_end < NOW()
    AND auto_renew = FALSE;
    
    UPDATE subscriptions
    SET status = 'past_due'
    WHERE status = 'active'
    AND current_period_end < NOW()
    AND auto_renew = TRUE;
END;
$$ LANGUAGE plpgsql;

-- Créer un cron job pour vérifier les expirations (si pg_cron installé)
-- SELECT cron.schedule('check-expired-subscriptions', '0 0 * * *', 'SELECT check_expired_subscriptions()');




