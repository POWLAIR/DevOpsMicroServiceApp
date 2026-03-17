-- ============================================
-- SCRIPT DE SEEDING COMPLET - DevOps MicroService App
-- ============================================
-- Ce script crée des données réalistes pour tous les services
-- À exécuter après le démarrage de Docker Compose
-- ============================================

-- Note: Les tenants et users sont créés par le seeding Python existant
-- Ce script ajoute : commandes, paiements, avis, favoris

-- ============================================
-- 1. FAVORIS (Product Service - PostgreSQL)
-- ============================================

-- Customer1 (Tech Store) a 3 favoris
INSERT INTO favorites (id, tenant_id, user_id, product_id, "createdAt")
SELECT 
    gen_random_uuid(),
    '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid, -- Tech Store
    (SELECT id FROM users WHERE email = 'customer1@example.com' LIMIT 1),
    p.id,
    NOW() - (random() * interval '30 days')
FROM products p
WHERE p.tenant_id = '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid
AND p.name IN ('iPhone 15 Pro', 'MacBook Pro 16"', 'Apple Watch Series 9')
ON CONFLICT DO NOTHING;

-- Customer2 (Fashion Boutique) a 2 favoris
INSERT INTO favorites (id, tenant_id, user_id, product_id, "createdAt")
SELECT 
    gen_random_uuid(),
    '1574b85d-a3df-400f-9e82-98831aa32934'::uuid, -- Fashion Boutique
    (SELECT id FROM users WHERE email = 'customer2@example.com' LIMIT 1),
    p.id,
    NOW() - (random() * interval '20 days')
FROM products p
WHERE p.tenant_id = '1574b85d-a3df-400f-9e82-98831aa32934'::uuid
LIMIT 2
ON CONFLICT DO NOTHING;

-- ============================================
-- 2. AVIS PRODUITS (Product Service - PostgreSQL)
-- ============================================

-- Avis pour les produits Tech Store
INSERT INTO reviews (id, tenant_id, user_id, product_id, rating, comment, "createdAt", "updatedAt")
SELECT 
    gen_random_uuid(),
    '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid,
    (SELECT id FROM users WHERE email = 'customer1@example.com' LIMIT 1),
    p.id,
    CASE 
        WHEN random() < 0.7 THEN 5
        WHEN random() < 0.9 THEN 4
        ELSE 3
    END,
    CASE (random() * 5)::int
        WHEN 0 THEN 'Excellent produit, je recommande vivement !'
        WHEN 1 THEN 'Très satisfait de mon achat, livraison rapide.'
        WHEN 2 THEN 'Bon rapport qualité-prix, conforme à la description.'
        WHEN 3 THEN 'Produit de qualité, je suis content.'
        ELSE 'Parfait, exactement ce que je cherchais.'
    END,
    NOW() - (random() * interval '60 days'),
    NOW() - (random() * interval '60 days')
FROM products p
WHERE p.tenant_id = '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid
AND random() < 0.6 -- 60% des produits ont un avis
ON CONFLICT DO NOTHING;

-- Avis supplémentaires par customer-test
INSERT INTO reviews (id, tenant_id, user_id, product_id, rating, comment, "createdAt", "updatedAt")
SELECT 
    gen_random_uuid(),
    '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid,
    (SELECT id FROM users WHERE email = 'customer-test@test.com' LIMIT 1),
    p.id,
    CASE 
        WHEN random() < 0.6 THEN 5
        WHEN random() < 0.85 THEN 4
        ELSE 3
    END,
    CASE (random() * 4)::int
        WHEN 0 THEN 'Super produit, très content de mon achat !'
        WHEN 1 THEN 'Livraison rapide et produit conforme.'
        WHEN 2 THEN 'Bon produit, je recommande.'
        ELSE 'Satisfait, bon rapport qualité-prix.'
    END,
    NOW() - (random() * interval '45 days'),
    NOW() - (random() * interval '45 days')
FROM products p
WHERE p.tenant_id = '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid
AND random() < 0.4 -- 40% des produits ont un deuxième avis
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. COMMANDES (Order Service - SQLite)
-- ============================================
-- Note: SQLite est utilisé par order-service
-- Ces commandes seront créées via l'API ou un script Python séparé
-- Car SQLite ne supporte pas les mêmes fonctions que PostgreSQL

-- ============================================
-- 4. MISE À JOUR DES NOTES PRODUITS
-- ============================================
-- Recalculer les notes moyennes et le nombre d'avis

UPDATE products p
SET 
    rating = COALESCE((
        SELECT AVG(r.rating)::numeric(3,2)
        FROM reviews r
        WHERE r.product_id = p.id AND r.tenant_id = p.tenant_id
    ), 0),
    "reviewCount" = COALESCE((
        SELECT COUNT(*)::int
        FROM reviews r
        WHERE r.product_id = p.id AND r.tenant_id = p.tenant_id
    ), 0),
    "updatedAt" = NOW()
WHERE p.tenant_id IN (
    '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid,
    '1574b85d-a3df-400f-9e82-98831aa32934'::uuid
);

-- ============================================
-- 5. STATISTIQUES FINALES
-- ============================================

DO $$
DECLARE
    v_favorites_count int;
    v_reviews_count int;
    v_products_count int;
BEGIN
    SELECT COUNT(*) INTO v_favorites_count FROM favorites;
    SELECT COUNT(*) INTO v_reviews_count FROM reviews;
    SELECT COUNT(*) INTO v_products_count FROM products;
    
    RAISE NOTICE '============================================';
    RAISE NOTICE 'SEEDING COMPLET TERMINÉ';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Produits créés: %', v_products_count;
    RAISE NOTICE 'Favoris créés: %', v_favorites_count;
    RAISE NOTICE 'Avis créés: %', v_reviews_count;
    RAISE NOTICE '============================================';
END $$;
