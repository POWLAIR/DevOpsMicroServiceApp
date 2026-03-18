-- ============================================
-- SCRIPT DE SEEDING COMPLET - DevOps MicroService App
-- ============================================
-- SOURCE CANONIQUE : toutes les données de seed passent par ce fichier.
-- Usage : bash scripts/init-complete-data.sh
--
-- Convention de nommage des colonnes :
--   NestJS/TypeORM (products, reviews, favorites, orders) : camelCase ("tenantId", "imageUrl", ...)
--   SQLAlchemy/Python (users, tenants)                    : snake_case (tenant_id, email, ...)
-- ============================================

-- ============================================
-- NETTOYAGE PRÉALABLE (reseed idempotent)
-- ============================================
DELETE FROM reviews;
DELETE FROM favorites;
DELETE FROM products;

-- ============================================
-- 1. PRODUITS (60 au total)
-- ============================================
-- IDs fixes pour idempotence : 10000000-00XX-0000-0000-0000000000YY
--   XX = catégorie (01=Electronics, 02=Computers, 03=Clothing, 04=Beauty, 05=Home, 06=Sports)
--   YY = index produit (01 à 10)
--
-- Tech Store   : 36ee6e56-0344-4a85-999f-4730bf5c38c2
-- Fashion      : 1ddfe264-3415-4dec-9bc1-af3e60809745
-- Default      : 1574b85d-a3df-400f-9e82-98831aa32934
-- ============================================

-- === TECH STORE — Electronics (10 produits) ===
INSERT INTO products (id, "tenantId", name, description, price, category, "imageUrl", stock, rating, "reviewCount", "isActive", "createdAt", "updatedAt") VALUES
  ('10000000-0001-0000-0000-000000000001', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'iPhone 15 Pro', 'Smartphone Apple avec puce A17 Pro, écran OLED 6.1", triple caméra 48MP et Dynamic Island.', 1199.99, 'Electronics', 'https://picsum.photos/seed/elec-01/640/480', 45, 4.8, 312, true, NOW() - interval '90 days', NOW()),
  ('10000000-0001-0000-0000-000000000002', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Samsung Galaxy S24 Ultra', 'Smartphone haut de gamme avec S Pen intégré, écran 6.8" Dynamic AMOLED et IA avancée.', 1299.99, 'Electronics', 'https://picsum.photos/seed/elec-02/640/480', 32, 4.7, 287, true, NOW() - interval '85 days', NOW()),
  ('10000000-0001-0000-0000-000000000003', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Sony WH-1000XM5', 'Casque sans fil à réduction de bruit active leader du marché, 30h d''autonomie, audio Hi-Res.', 349.99, 'Electronics', 'https://picsum.photos/seed/elec-03/640/480', 78, 4.9, 542, true, NOW() - interval '80 days', NOW()),
  ('10000000-0001-0000-0000-000000000004', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Apple AirPods Pro 2', 'Écouteurs sans fil avec réduction de bruit active, audio spatial et autonomie 30h avec étui.', 279.99, 'Electronics', 'https://picsum.photos/seed/elec-04/640/480', 93, 4.7, 428, true, NOW() - interval '75 days', NOW()),
  ('10000000-0001-0000-0000-000000000005', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'GoPro Hero 12 Black', 'Caméra action 5.3K, stabilisation HyperSmooth 6.0, étanche 10m, Wi-Fi et Bluetooth.', 399.99, 'Electronics', 'https://picsum.photos/seed/elec-05/640/480', 41, 4.6, 198, true, NOW() - interval '70 days', NOW()),
  ('10000000-0001-0000-0000-000000000006', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Canon EOS R8', 'Appareil photo hybride plein format 24.2MP, vidéo 4K 60fps, autofocus Dual Pixel.', 1499.99, 'Electronics', 'https://picsum.photos/seed/elec-06/640/480', 18, 4.8, 134, true, NOW() - interval '65 days', NOW()),
  ('10000000-0001-0000-0000-000000000007', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Apple Watch Series 9', 'Montre connectée GPS+Cellular, geste Double Tap, écran Always-On Retina, santé avancée.', 449.99, 'Electronics', 'https://picsum.photos/seed/elec-07/640/480', 67, 4.8, 389, true, NOW() - interval '60 days', NOW()),
  ('10000000-0001-0000-0000-000000000008', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Samsung Galaxy Watch 6 Classic', 'Montre connectée avec cadran rotatif physique, suivi santé avancé et autonomie 40h.', 369.99, 'Electronics', 'https://picsum.photos/seed/elec-08/640/480', 54, 4.5, 176, true, NOW() - interval '55 days', NOW()),
  ('10000000-0001-0000-0000-000000000009', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'iPad Pro 12.9" M2', 'Tablette Apple avec puce M2, écran Liquid Retina XDR 12.9", compatible Apple Pencil 2.', 1099.99, 'Electronics', 'https://picsum.photos/seed/elec-09/640/480', 29, 4.7, 223, true, NOW() - interval '50 days', NOW()),
  ('10000000-0001-0000-0000-000000000010', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Amazon Echo Dot 5', 'Enceinte connectée Alexa compacte, son amélioré, horloge LED intégrée et hub Zigbee.', 59.99, 'Electronics', 'https://picsum.photos/seed/elec-10/640/480', 156, 4.4, 892, true, NOW() - interval '45 days', NOW());

-- === TECH STORE — Computers (10 produits) ===
INSERT INTO products (id, "tenantId", name, description, price, category, "imageUrl", stock, rating, "reviewCount", "isActive", "createdAt", "updatedAt") VALUES
  ('10000000-0002-0000-0000-000000000001', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'MacBook Pro 16" M3', 'Ordinateur portable Apple puce M3 Pro, 18h d''autonomie, écran Liquid Retina XDR 16".', 2499.99, 'Computers', 'https://picsum.photos/seed/comp-01/640/480', 14, 4.9, 267, true, NOW() - interval '88 days', NOW()),
  ('10000000-0002-0000-0000-000000000002', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Dell XPS 15', 'PC portable premium 15.6" OLED 3.5K, Intel Core i9-13900H, RTX 4070, 32 Go RAM.', 2199.99, 'Computers', 'https://picsum.photos/seed/comp-02/640/480', 22, 4.7, 189, true, NOW() - interval '83 days', NOW()),
  ('10000000-0002-0000-0000-000000000003', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'ASUS ROG Zephyrus G14', 'PC portable gaming 14" WQXGA 165Hz, AMD Ryzen 9, RTX 4060, 16 Go RAM.', 1699.99, 'Computers', 'https://picsum.photos/seed/comp-03/640/480', 19, 4.6, 156, true, NOW() - interval '78 days', NOW()),
  ('10000000-0002-0000-0000-000000000004', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'HP EliteBook 840 G10', 'PC portable professionnel 14" IPS, Intel Core i7-1355U, 16 Go RAM, garantie 3 ans.', 1399.99, 'Computers', 'https://picsum.photos/seed/comp-04/640/480', 35, 4.5, 98, true, NOW() - interval '73 days', NOW()),
  ('10000000-0002-0000-0000-000000000005', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'LG UltraWide 34"', 'Écran incurvé 34" WQHD 3440x1440, 160Hz, compatible USB-C 96W, HDR10.', 649.99, 'Computers', 'https://picsum.photos/seed/comp-05/640/480', 27, 4.6, 213, true, NOW() - interval '68 days', NOW()),
  ('10000000-0002-0000-0000-000000000006', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Samsung Odyssey G7 32"', 'Écran gaming 32" 4K UHD, 240Hz, HDR600, incurvé 1000R, compatible G-Sync.', 799.99, 'Computers', 'https://picsum.photos/seed/comp-06/640/480', 31, 4.7, 178, true, NOW() - interval '63 days', NOW()),
  ('10000000-0002-0000-0000-000000000007', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Logitech MX Master 3S', 'Souris sans fil ergonomique 8000 DPI, molette MagSpeed, connectivité multi-appareils.', 99.99, 'Computers', 'https://picsum.photos/seed/comp-07/640/480', 124, 4.8, 634, true, NOW() - interval '58 days', NOW()),
  ('10000000-0002-0000-0000-000000000008', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Keychron K2 Pro', 'Clavier mécanique compact sans fil 75%, switches hot-swap, rétroéclairage RVB.', 109.99, 'Computers', 'https://picsum.photos/seed/comp-08/640/480', 88, 4.7, 312, true, NOW() - interval '53 days', NOW()),
  ('10000000-0002-0000-0000-000000000009', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'WD My Passport 2TB', 'Disque dur externe portable 2TB, USB 3.0, protection par mot de passe, compatible Mac/PC.', 79.99, 'Computers', 'https://picsum.photos/seed/comp-09/640/480', 142, 4.5, 478, true, NOW() - interval '48 days', NOW()),
  ('10000000-0002-0000-0000-000000000010', '36ee6e56-0344-4a85-999f-4730bf5c38c2', 'Crucial P5 Plus SSD 1TB', 'SSD NVMe M.2 PCIe 4.0, vitesse lecture 6600 MB/s, idéal pour PC gaming et workstation.', 89.99, 'Computers', 'https://picsum.photos/seed/comp-10/640/480', 97, 4.6, 341, true, NOW() - interval '43 days', NOW());

-- === FASHION BOUTIQUE — Clothing (10 produits) ===
INSERT INTO products (id, "tenantId", name, description, price, category, "imageUrl", stock, rating, "reviewCount", "isActive", "createdAt", "updatedAt") VALUES
  ('10000000-0003-0000-0000-000000000001', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Veste en cuir noir', 'Veste en cuir véritable coupe slim, doublure satinée, fermetures YKK. Tailles XS-XXL.', 299.99, 'Clothing', 'https://picsum.photos/seed/fash-01/640/480', 23, 4.6, 87, true, NOW() - interval '90 days', NOW()),
  ('10000000-0003-0000-0000-000000000002', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Jean slim bleu marine', 'Jean slim stretch coupe moderne, taille mi-haute, 5 poches, 98% coton 2% élasthanne.', 89.99, 'Clothing', 'https://picsum.photos/seed/fash-02/640/480', 67, 4.4, 134, true, NOW() - interval '85 days', NOW()),
  ('10000000-0003-0000-0000-000000000003', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Robe fleurie d''été', 'Robe légère imprimé floral, col V, manches courtes, 100% viscose. Idéale pour l''été.', 69.99, 'Clothing', 'https://picsum.photos/seed/fash-03/640/480', 45, 4.5, 98, true, NOW() - interval '80 days', NOW()),
  ('10000000-0003-0000-0000-000000000004', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Manteau camel classique', 'Manteau long double boutonnage, 70% laine 30% polyester, col châle, poches plaquées.', 349.99, 'Clothing', 'https://picsum.photos/seed/fash-04/640/480', 18, 4.7, 76, true, NOW() - interval '75 days', NOW()),
  ('10000000-0003-0000-0000-000000000005', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Pull en laine mérinos', 'Pull col roulé 100% laine mérinos extra-fine, résistant aux odeurs, Oeko-Tex certifié.', 129.99, 'Clothing', 'https://picsum.photos/seed/fash-05/640/480', 52, 4.6, 112, true, NOW() - interval '70 days', NOW()),
  ('10000000-0003-0000-0000-000000000006', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Chemise Oxford blanche', 'Chemise en coton Oxford 120 fils, coupe droite, col boutonné, manchettes réglables.', 79.99, 'Clothing', 'https://picsum.photos/seed/fash-06/640/480', 84, 4.3, 89, true, NOW() - interval '65 days', NOW()),
  ('10000000-0003-0000-0000-000000000007', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Short en lin beige', 'Short en lin naturel lavé, taille élastique avec cordon, 2 poches latérales et 1 arrière.', 59.99, 'Clothing', 'https://picsum.photos/seed/fash-07/640/480', 63, 4.4, 67, true, NOW() - interval '60 days', NOW()),
  ('10000000-0003-0000-0000-000000000008', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Blazer gris chiné', 'Blazer en lainage chiné gris, coupe ajustée, 2 boutons, doublure satin, poches passepoilées.', 189.99, 'Clothing', 'https://picsum.photos/seed/fash-08/640/480', 31, 4.5, 58, true, NOW() - interval '55 days', NOW()),
  ('10000000-0003-0000-0000-000000000009', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Sneakers blanches cuir', 'Sneakers en cuir lisse blanc, semelle caoutchouc vulcanisé, lacets plats, unisexe.', 149.99, 'Clothing', 'https://picsum.photos/seed/fash-09/640/480', 78, 4.6, 156, true, NOW() - interval '50 days', NOW()),
  ('10000000-0003-0000-0000-000000000010', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Boots chelsea marron', 'Boots en cuir pleine fleur marron cognac, élastiques latéraux, semelle Goodyear welt.', 219.99, 'Clothing', 'https://picsum.photos/seed/fash-10/640/480', 34, 4.5, 93, true, NOW() - interval '45 days', NOW());

-- === FASHION BOUTIQUE — Beauty (10 produits) ===
INSERT INTO products (id, "tenantId", name, description, price, category, "imageUrl", stock, rating, "reviewCount", "isActive", "createdAt", "updatedAt") VALUES
  ('10000000-0004-0000-0000-000000000001', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Sérum vitamine C 20%', 'Sérum concentré éclat anti-taches 30ml, vitamine C pure stabilisée, sans parfum.', 49.99, 'Beauty', 'https://picsum.photos/seed/beau-01/640/480', 112, 4.7, 234, true, NOW() - interval '88 days', NOW()),
  ('10000000-0004-0000-0000-000000000002', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Crème hydratante SPF50', 'Crème visage protection solaire haute SPF50, texture légère non grasse, 50ml, Oeko-Tex.', 39.99, 'Beauty', 'https://picsum.photos/seed/beau-02/640/480', 145, 4.6, 312, true, NOW() - interval '83 days', NOW()),
  ('10000000-0004-0000-0000-000000000003', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Palette maquillage naturel', '24 fards à paupières tons naturels et dorés, pigmentation intense, longue tenue 12h.', 59.99, 'Beauty', 'https://picsum.photos/seed/beau-03/640/480', 89, 4.5, 178, true, NOW() - interval '78 days', NOW()),
  ('10000000-0004-0000-0000-000000000004', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Eau de parfum florale 50ml', 'Parfum femme aux notes fleuries de jasmin, rose et musc blanc, tenue 8h, vaporisateur.', 89.99, 'Beauty', 'https://picsum.photos/seed/beau-04/640/480', 67, 4.8, 198, true, NOW() - interval '73 days', NOW()),
  ('10000000-0004-0000-0000-000000000005', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Masque cheveux à l''argan', 'Masque nourrissant huile d''argan bio 300ml, sans sulfate ni parabène, pour cheveux secs.', 29.99, 'Beauty', 'https://picsum.photos/seed/beau-05/640/480', 134, 4.6, 267, true, NOW() - interval '68 days', NOW()),
  ('10000000-0004-0000-0000-000000000006', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Rouge à lèvres mat', 'Rouge à lèvres longue tenue mat 24h, formule hydratante enrichie en acide hyaluronique.', 24.99, 'Beauty', 'https://picsum.photos/seed/beau-06/640/480', 198, 4.4, 145, true, NOW() - interval '63 days', NOW()),
  ('10000000-0004-0000-0000-000000000007', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Fond de teint HD', 'Fond de teint liquide couvrance modulable 24h, fini naturel, 30ml, 30 teintes disponibles.', 44.99, 'Beauty', 'https://picsum.photos/seed/beau-07/640/480', 123, 4.5, 189, true, NOW() - interval '58 days', NOW()),
  ('10000000-0004-0000-0000-000000000008', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Huile corps amande douce', 'Huile sèche 100% naturelle amande douce pressée à froid, 200ml, certifiée bio.', 19.99, 'Beauty', 'https://picsum.photos/seed/beau-08/640/480', 167, 4.7, 312, true, NOW() - interval '53 days', NOW()),
  ('10000000-0004-0000-0000-000000000009', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Set soin visage complet', 'Coffret 5 étapes : nettoyant, tonique, sérum vitamine C, crème jour et contour des yeux.', 99.99, 'Beauty', 'https://picsum.photos/seed/beau-09/640/480', 43, 4.8, 134, true, NOW() - interval '48 days', NOW()),
  ('10000000-0004-0000-0000-000000000010', '1ddfe264-3415-4dec-9bc1-af3e60809745', 'Eau micellaire purifiante', 'Eau démaquillante douce peaux sensibles 400ml, sans rinçage, hypoallergénique, pH neutre.', 14.99, 'Beauty', 'https://picsum.photos/seed/beau-10/640/480', 234, 4.5, 423, true, NOW() - interval '43 days', NOW());

-- === DEFAULT TENANT — Home & Garden (10 produits) ===
INSERT INTO products (id, "tenantId", name, description, price, category, "imageUrl", stock, rating, "reviewCount", "isActive", "createdAt", "updatedAt") VALUES
  ('10000000-0005-0000-0000-000000000001', '1574b85d-a3df-400f-9e82-98831aa32934', 'Lampe de bureau LED', 'Lampe LED dimmable 12W bras articulé, température de couleur 2700-6500K, port USB-C intégré.', 69.99, 'Home & Garden', 'https://picsum.photos/seed/home-01/640/480', 87, 4.6, 178, true, NOW() - interval '90 days', NOW()),
  ('10000000-0005-0000-0000-000000000002', '1574b85d-a3df-400f-9e82-98831aa32934', 'Plaid sherpa gris', 'Plaid en polaire sherpa réversible 150x200cm, ultra doux, lavable en machine, tons neutres.', 49.99, 'Home & Garden', 'https://picsum.photos/seed/home-02/640/480', 112, 4.7, 234, true, NOW() - interval '85 days', NOW()),
  ('10000000-0005-0000-0000-000000000003', '1574b85d-a3df-400f-9e82-98831aa32934', 'Set couteaux chef 5 pièces', 'Ensemble 5 couteaux forgés acier inox allemand X50CrMoV15, manche ergonomique antidérapant.', 149.99, 'Home & Garden', 'https://picsum.photos/seed/home-03/640/480', 54, 4.8, 312, true, NOW() - interval '80 days', NOW()),
  ('10000000-0005-0000-0000-000000000004', '1574b85d-a3df-400f-9e82-98831aa32934', 'Cafetière à piston 1L', 'French press 1L en verre borosilicate thermique, filtre inox double paroi, manche en bois.', 39.99, 'Home & Garden', 'https://picsum.photos/seed/home-04/640/480', 89, 4.6, 198, true, NOW() - interval '75 days', NOW()),
  ('10000000-0005-0000-0000-000000000005', '1574b85d-a3df-400f-9e82-98831aa32934', 'Planche à découper bambou', 'Planche XL 40x30cm en bambou naturel anti-bactérien, rainure jus de viande, pieds antidérapants.', 34.99, 'Home & Garden', 'https://picsum.photos/seed/home-05/640/480', 134, 4.5, 156, true, NOW() - interval '70 days', NOW()),
  ('10000000-0005-0000-0000-000000000006', '1574b85d-a3df-400f-9e82-98831aa32934', 'Vase céramique artisanal', 'Vase fait main en céramique émaillée, forme organique contemporaine, hauteur 25cm. Unique.', 59.99, 'Home & Garden', 'https://picsum.photos/seed/home-06/640/480', 43, 4.7, 89, true, NOW() - interval '65 days', NOW()),
  ('10000000-0005-0000-0000-000000000007', '1574b85d-a3df-400f-9e82-98831aa32934', 'Bougie parfumée soja', 'Bougie en cire de soja naturelle 200g, senteur lin et musc blanc, mèche coton, durée 45h.', 24.99, 'Home & Garden', 'https://picsum.photos/seed/home-07/640/480', 178, 4.6, 267, true, NOW() - interval '60 days', NOW()),
  ('10000000-0005-0000-0000-000000000008', '1574b85d-a3df-400f-9e82-98831aa32934', 'Kit graines aromatiques', '10 sachets graines aromatiques bio : basilic, menthe, persil, ciboulette, thym et plus.', 19.99, 'Home & Garden', 'https://picsum.photos/seed/home-08/640/480', 234, 4.4, 145, true, NOW() - interval '55 days', NOW()),
  ('10000000-0005-0000-0000-000000000009', '1574b85d-a3df-400f-9e82-98831aa32934', 'Arrosoir design 2L', 'Arrosoir en acier inoxydable mat 2L, bec long précis, poignée ergonomique, finition brossée.', 44.99, 'Home & Garden', 'https://picsum.photos/seed/home-09/640/480', 67, 4.5, 112, true, NOW() - interval '50 days', NOW()),
  ('10000000-0005-0000-0000-000000000010', '1574b85d-a3df-400f-9e82-98831aa32934', 'Cadre photo bois naturel A4', 'Cadre en bois massif pin finition naturelle, format A4 (21x29.7cm), vitre anti-reflets.', 29.99, 'Home & Garden', 'https://picsum.photos/seed/home-10/640/480', 98, 4.3, 67, true, NOW() - interval '45 days', NOW());

-- === DEFAULT TENANT — Sports & Outdoor (10 produits) ===
INSERT INTO products (id, "tenantId", name, description, price, category, "imageUrl", stock, rating, "reviewCount", "isActive", "createdAt", "updatedAt") VALUES
  ('10000000-0006-0000-0000-000000000001', '1574b85d-a3df-400f-9e82-98831aa32934', 'Tapis de yoga antidérapant', 'Tapis 6mm TPE recyclé 183x61cm, texture biface, sangle de transport incluse, sans phtalates.', 49.99, 'Sports', 'https://picsum.photos/seed/sprt-01/640/480', 89, 4.7, 312, true, NOW() - interval '88 days', NOW()),
  ('10000000-0006-0000-0000-000000000002', '1574b85d-a3df-400f-9e82-98831aa32934', 'Gourde inox 750ml', 'Gourde isotherme double paroi 750ml, 24h froid / 12h chaud, sans BPA, couvercle étanche.', 34.99, 'Sports', 'https://picsum.photos/seed/sprt-02/640/480', 145, 4.8, 456, true, NOW() - interval '83 days', NOW()),
  ('10000000-0006-0000-0000-000000000003', '1574b85d-a3df-400f-9e82-98831aa32934', 'Set résistances élastiques', '5 bandes de résistance niveaux S/M/L/XL/XXL, en latex naturel, avec sac de rangement.', 29.99, 'Sports', 'https://picsum.photos/seed/sprt-03/640/480', 123, 4.5, 234, true, NOW() - interval '78 days', NOW()),
  ('10000000-0006-0000-0000-000000000004', '1574b85d-a3df-400f-9e82-98831aa32934', 'Casque vélo urbain', 'Casque certifié CE EN1078, réglage occipital rapide, 12 aérations, visière amovible.', 79.99, 'Sports', 'https://picsum.photos/seed/sprt-04/640/480', 56, 4.6, 167, true, NOW() - interval '73 days', NOW()),
  ('10000000-0006-0000-0000-000000000005', '1574b85d-a3df-400f-9e82-98831aa32934', 'Raquette de tennis', 'Raquette adulte 285g, tête 100 in², cadre graphite, cordage inclus, taille grip 3.', 119.99, 'Sports', 'https://picsum.photos/seed/sprt-05/640/480', 34, 4.5, 89, true, NOW() - interval '68 days', NOW()),
  ('10000000-0006-0000-0000-000000000006', '1574b85d-a3df-400f-9e82-98831aa32934', 'Chaussures de running', 'Chaussures légères mesh respirant, semelle amorti maximal, drop 8mm, tailles 36-47.', 139.99, 'Sports', 'https://picsum.photos/seed/sprt-06/640/480', 67, 4.6, 198, true, NOW() - interval '63 days', NOW()),
  ('10000000-0006-0000-0000-000000000007', '1574b85d-a3df-400f-9e82-98831aa32934', 'Sac de sport étanche 35L', 'Sac duffel 35L en nylon 600D étanche, compartiment chaussures, bandoulière amovible.', 89.99, 'Sports', 'https://picsum.photos/seed/sprt-07/640/480', 78, 4.4, 134, true, NOW() - interval '58 days', NOW()),
  ('10000000-0006-0000-0000-000000000008', '1574b85d-a3df-400f-9e82-98831aa32934', 'Montre GPS sport', 'Montre GPS 20 sports, capteur fréquence cardiaque optique, 7 jours autonomie, étanche 5ATM.', 199.99, 'Sports', 'https://picsum.photos/seed/sprt-08/640/480', 43, 4.7, 267, true, NOW() - interval '53 days', NOW()),
  ('10000000-0006-0000-0000-000000000009', '1574b85d-a3df-400f-9e82-98831aa32934', 'Corde à sauter intelligente', 'Corde à sauter avec compteur LCD intégré, longueur ajustable 2.5-3m, poignées ergonomiques.', 24.99, 'Sports', 'https://picsum.photos/seed/sprt-09/640/480', 167, 4.3, 312, true, NOW() - interval '48 days', NOW()),
  ('10000000-0006-0000-0000-000000000010', '1574b85d-a3df-400f-9e82-98831aa32934', 'Ballon de basket taille 7', 'Ballon officiel taille 7, caoutchouc vulcanisé haute durabilité, intérieur/extérieur, gonflé.', 39.99, 'Sports', 'https://picsum.photos/seed/sprt-10/640/480', 98, 4.5, 178, true, NOW() - interval '43 days', NOW());

-- ============================================
-- 2. AVIS PRODUITS (reviews)
-- ============================================
-- Utilise les emails des customers créés par auth-service/seed_service.py
-- Tech Store     : customer1, customer2, customer3 (tenant 36ee6e56-...)
-- Fashion        : customer6, customer7           (tenant 1ddfe264-...)
-- Default Tenant : customer4, customer5           (tenant 1574b85d-...)
-- ============================================

-- Reviews Tech Store — 2 customers × 20 produits = 40 avis
INSERT INTO reviews (id, "tenantId", "userId", "productId", rating, comment, "createdAt", "updatedAt")
SELECT
    gen_random_uuid(),
    p."tenantId",
    u.id,
    p.id,
    CASE floor(random() * 5 + 1)::int
        WHEN 5 THEN 5
        WHEN 4 THEN 5
        WHEN 3 THEN 4
        WHEN 2 THEN 4
        ELSE 3
    END,
    CASE floor(random() * 8)::int
        WHEN 0 THEN 'Excellent produit, je recommande vivement !'
        WHEN 1 THEN 'Très satisfait de mon achat, livraison rapide.'
        WHEN 2 THEN 'Bon rapport qualité-prix, conforme à la description.'
        WHEN 3 THEN 'Produit de qualité, exactement ce que je cherchais.'
        WHEN 4 THEN 'Parfait, fonctionne très bien depuis plusieurs semaines.'
        WHEN 5 THEN 'Super achat, je suis très content de ce produit !'
        WHEN 6 THEN 'Très bon produit, emballage soigné et livraison rapide.'
        ELSE 'Je recommande, rapport qualité-prix imbattable.'
    END,
    NOW() - (random() * interval '60 days'),
    NOW() - (random() * interval '60 days')
FROM products p
CROSS JOIN (
    SELECT id FROM users WHERE email IN ('customer1@example.com', 'customer2@example.com')
) u
WHERE p."tenantId" = '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid
ON CONFLICT ("tenantId", "userId", "productId") DO NOTHING;

-- Reviews Tech Store — customer3 sur ~60% des produits
INSERT INTO reviews (id, "tenantId", "userId", "productId", rating, comment, "createdAt", "updatedAt")
SELECT
    gen_random_uuid(),
    p."tenantId",
    (SELECT id FROM users WHERE email = 'customer3@example.com' LIMIT 1),
    p.id,
    CASE floor(random() * 4 + 2)::int
        WHEN 5 THEN 5
        WHEN 4 THEN 4
        ELSE 4
    END,
    CASE floor(random() * 5)::int
        WHEN 0 THEN 'Très bon produit, je suis satisfait de mon achat.'
        WHEN 1 THEN 'Conforme à la description, livraison dans les délais.'
        WHEN 2 THEN 'Bonne qualité, je recommande ce produit.'
        WHEN 3 THEN 'Excellent rapport qualité-prix, très satisfait.'
        ELSE 'Super produit, rien à redire !'
    END,
    NOW() - (random() * interval '45 days'),
    NOW() - (random() * interval '45 days')
FROM products p
WHERE p."tenantId" = '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid
  AND random() < 0.6
ON CONFLICT ("tenantId", "userId", "productId") DO NOTHING;

-- Reviews Fashion Boutique — 2 customers × 20 produits = 40 avis
INSERT INTO reviews (id, "tenantId", "userId", "productId", rating, comment, "createdAt", "updatedAt")
SELECT
    gen_random_uuid(),
    p."tenantId",
    u.id,
    p.id,
    CASE floor(random() * 5 + 1)::int
        WHEN 5 THEN 5
        WHEN 4 THEN 5
        WHEN 3 THEN 4
        WHEN 2 THEN 4
        ELSE 3
    END,
    CASE floor(random() * 8)::int
        WHEN 0 THEN 'Superbe qualité, je suis ravie de cet achat !'
        WHEN 1 THEN 'La coupe est parfaite, la matière douce et agréable.'
        WHEN 2 THEN 'Très beau produit, conforme aux photos. Je recommande.'
        WHEN 3 THEN 'Excellent produit, livraison rapide et bien emballé.'
        WHEN 4 THEN 'Parfait pour l''occasion, je suis très satisfaite !'
        WHEN 5 THEN 'Belle qualité, taille conforme au guide. Top !'
        WHEN 6 THEN 'Très bon achat, produit de qualité. Je reviendrai !'
        ELSE 'Magnifique, exactement ce que je cherchais.'
    END,
    NOW() - (random() * interval '60 days'),
    NOW() - (random() * interval '60 days')
FROM products p
CROSS JOIN (
    SELECT id FROM users WHERE email IN ('customer6@example.com', 'customer7@example.com')
) u
WHERE p."tenantId" = '1ddfe264-3415-4dec-9bc1-af3e60809745'::uuid
ON CONFLICT ("tenantId", "userId", "productId") DO NOTHING;

-- Reviews Default Tenant — 2 customers × 20 produits = 40 avis
INSERT INTO reviews (id, "tenantId", "userId", "productId", rating, comment, "createdAt", "updatedAt")
SELECT
    gen_random_uuid(),
    p."tenantId",
    u.id,
    p.id,
    CASE floor(random() * 5 + 1)::int
        WHEN 5 THEN 5
        WHEN 4 THEN 4
        WHEN 3 THEN 4
        WHEN 2 THEN 5
        ELSE 3
    END,
    CASE floor(random() * 8)::int
        WHEN 0 THEN 'Très bon produit, je recommande vivement !'
        WHEN 1 THEN 'Excellent rapport qualité-prix, livraison soignée.'
        WHEN 2 THEN 'Produit conforme à la description, je suis content.'
        WHEN 3 THEN 'Super qualité, rien à redire. Je commande à nouveau.'
        WHEN 4 THEN 'Parfait, exactement ce qu''il me fallait !'
        WHEN 5 THEN 'Très satisfait, produit robuste et bien fini.'
        WHEN 6 THEN 'Bon achat, je recommande sans hésitation.'
        ELSE 'Excellent produit, rapport qualité-prix imbattable !'
    END,
    NOW() - (random() * interval '60 days'),
    NOW() - (random() * interval '60 days')
FROM products p
CROSS JOIN (
    SELECT id FROM users WHERE email IN ('customer4@example.com', 'customer5@example.com')
) u
WHERE p."tenantId" = '1574b85d-a3df-400f-9e82-98831aa32934'::uuid
ON CONFLICT ("tenantId", "userId", "productId") DO NOTHING;

-- ============================================
-- 3. FAVORIS
-- ============================================

-- customer1 (Tech Store) : 3 favoris dans Electronics
INSERT INTO favorites (id, "tenantId", "userId", "productId", "createdAt")
SELECT
    gen_random_uuid(),
    '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid,
    (SELECT id FROM users WHERE email = 'customer1@example.com' LIMIT 1),
    p.id,
    NOW() - (random() * interval '30 days')
FROM products p
WHERE p."tenantId" = '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid
  AND p.name IN ('iPhone 15 Pro', 'MacBook Pro 16" M3', 'Apple Watch Series 9')
ON CONFLICT ("tenantId", "userId", "productId") DO NOTHING;

-- customer2 (Tech Store) : 2 favoris dans Computers
INSERT INTO favorites (id, "tenantId", "userId", "productId", "createdAt")
SELECT
    gen_random_uuid(),
    '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid,
    (SELECT id FROM users WHERE email = 'customer2@example.com' LIMIT 1),
    p.id,
    NOW() - (random() * interval '20 days')
FROM products p
WHERE p."tenantId" = '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid
  AND p.category = 'Computers'
ORDER BY random()
LIMIT 2
ON CONFLICT ("tenantId", "userId", "productId") DO NOTHING;

-- customer6 (Fashion) : 3 favoris dans Beauty
INSERT INTO favorites (id, "tenantId", "userId", "productId", "createdAt")
SELECT
    gen_random_uuid(),
    '1ddfe264-3415-4dec-9bc1-af3e60809745'::uuid,
    (SELECT id FROM users WHERE email = 'customer6@example.com' LIMIT 1),
    p.id,
    NOW() - (random() * interval '25 days')
FROM products p
WHERE p."tenantId" = '1ddfe264-3415-4dec-9bc1-af3e60809745'::uuid
  AND p.category = 'Beauty'
ORDER BY random()
LIMIT 3
ON CONFLICT ("tenantId", "userId", "productId") DO NOTHING;

-- customer4 (Default) : 2 favoris dans Sports
INSERT INTO favorites (id, "tenantId", "userId", "productId", "createdAt")
SELECT
    gen_random_uuid(),
    '1574b85d-a3df-400f-9e82-98831aa32934'::uuid,
    (SELECT id FROM users WHERE email = 'customer4@example.com' LIMIT 1),
    p.id,
    NOW() - (random() * interval '15 days')
FROM products p
WHERE p."tenantId" = '1574b85d-a3df-400f-9e82-98831aa32934'::uuid
  AND p.category = 'Sports'
ORDER BY random()
LIMIT 2
ON CONFLICT ("tenantId", "userId", "productId") DO NOTHING;

-- ============================================
-- 4. COMMANDES (orders — PostgreSQL, même DB)
-- ============================================
-- IDs fixes pour idempotence via ON CONFLICT (id) DO NOTHING
-- ============================================

-- Commande 1 : Tech Store, customer1, confirmée et payée
INSERT INTO orders (id, "tenantId", "userId", items, total, status, "paymentStatus", "createdAt", "updatedAt")
SELECT
    'aaaaaaaa-0000-0000-0000-000000000001'::uuid,
    '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid,
    (SELECT id FROM users WHERE email = 'customer1@example.com' LIMIT 1),
    jsonb_build_array(
        jsonb_build_object('productId', '10000000-0001-0000-0000-000000000001', 'quantity', 1, 'price', 1199.99),
        jsonb_build_object('productId', '10000000-0002-0000-0000-000000000007', 'quantity', 1, 'price', 99.99)
    ),
    1299.98,
    'confirmed',
    'paid',
    NOW() - interval '25 days',
    NOW() - interval '25 days'
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE id = 'aaaaaaaa-0000-0000-0000-000000000001'::uuid);

-- Commande 2 : Tech Store, customer2, en attente de paiement
INSERT INTO orders (id, "tenantId", "userId", items, total, status, "paymentStatus", "createdAt", "updatedAt")
SELECT
    'aaaaaaaa-0000-0000-0000-000000000002'::uuid,
    '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid,
    (SELECT id FROM users WHERE email = 'customer2@example.com' LIMIT 1),
    jsonb_build_array(
        jsonb_build_object('productId', '10000000-0002-0000-0000-000000000001', 'quantity', 1, 'price', 2499.99)
    ),
    2499.99,
    'pending',
    'unpaid',
    NOW() - interval '10 days',
    NOW() - interval '10 days'
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE id = 'aaaaaaaa-0000-0000-0000-000000000002'::uuid);

-- Commande 3 : Tech Store, customer1, expédiée
INSERT INTO orders (id, "tenantId", "userId", items, total, status, "paymentStatus", "createdAt", "updatedAt")
SELECT
    'aaaaaaaa-0000-0000-0000-000000000003'::uuid,
    '36ee6e56-0344-4a85-999f-4730bf5c38c2'::uuid,
    (SELECT id FROM users WHERE email = 'customer1@example.com' LIMIT 1),
    jsonb_build_array(
        jsonb_build_object('productId', '10000000-0001-0000-0000-000000000007', 'quantity', 1, 'price', 449.99),
        jsonb_build_object('productId', '10000000-0001-0000-0000-000000000003', 'quantity', 1, 'price', 349.99)
    ),
    799.98,
    'shipped',
    'paid',
    NOW() - interval '40 days',
    NOW() - interval '35 days'
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE id = 'aaaaaaaa-0000-0000-0000-000000000003'::uuid);

-- Commande 4 : Fashion Boutique, customer6
INSERT INTO orders (id, "tenantId", "userId", items, total, status, "paymentStatus", "createdAt", "updatedAt")
SELECT
    'aaaaaaaa-0000-0000-0000-000000000004'::uuid,
    '1ddfe264-3415-4dec-9bc1-af3e60809745'::uuid,
    (SELECT id FROM users WHERE email = 'customer6@example.com' LIMIT 1),
    jsonb_build_array(
        jsonb_build_object('productId', '10000000-0003-0000-0000-000000000001', 'quantity', 1, 'price', 299.99),
        jsonb_build_object('productId', '10000000-0004-0000-0000-000000000001', 'quantity', 2, 'price', 49.99)
    ),
    399.97,
    'confirmed',
    'paid',
    NOW() - interval '15 days',
    NOW() - interval '15 days'
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE id = 'aaaaaaaa-0000-0000-0000-000000000004'::uuid);

-- Commande 5 : Default Tenant, customer4
INSERT INTO orders (id, "tenantId", "userId", items, total, status, "paymentStatus", "createdAt", "updatedAt")
SELECT
    'aaaaaaaa-0000-0000-0000-000000000005'::uuid,
    '1574b85d-a3df-400f-9e82-98831aa32934'::uuid,
    (SELECT id FROM users WHERE email = 'customer4@example.com' LIMIT 1),
    jsonb_build_array(
        jsonb_build_object('productId', '10000000-0006-0000-0000-000000000002', 'quantity', 2, 'price', 34.99),
        jsonb_build_object('productId', '10000000-0006-0000-0000-000000000001', 'quantity', 1, 'price', 49.99)
    ),
    119.97,
    'confirmed',
    'paid',
    NOW() - interval '5 days',
    NOW() - interval '5 days'
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE id = 'aaaaaaaa-0000-0000-0000-000000000005'::uuid);

-- ============================================
-- 5. MISE À JOUR DES NOTES PRODUITS
-- ============================================
UPDATE products p
SET
    rating = COALESCE((
        SELECT ROUND(AVG(r.rating)::numeric, 2)
        FROM reviews r
        WHERE r."productId" = p.id AND r."tenantId" = p."tenantId"
    ), p.rating),
    "reviewCount" = COALESCE((
        SELECT COUNT(*)::int
        FROM reviews r
        WHERE r."productId" = p.id AND r."tenantId" = p."tenantId"
    ), 0),
    "updatedAt" = NOW();

-- ============================================
-- 6. STATISTIQUES FINALES
-- ============================================
DO $$
DECLARE
    v_products_count  int;
    v_reviews_count   int;
    v_favorites_count int;
    v_orders_count    int;
BEGIN
    SELECT COUNT(*) INTO v_products_count  FROM products;
    SELECT COUNT(*) INTO v_reviews_count   FROM reviews;
    SELECT COUNT(*) INTO v_favorites_count FROM favorites;
    SELECT COUNT(*) INTO v_orders_count    FROM orders;

    RAISE NOTICE '============================================';
    RAISE NOTICE 'SEEDING COMPLET TERMINÉ';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Produits  : %', v_products_count;
    RAISE NOTICE 'Avis      : %', v_reviews_count;
    RAISE NOTICE 'Favoris   : %', v_favorites_count;
    RAISE NOTICE 'Commandes : %', v_orders_count;
    RAISE NOTICE '============================================';
END $$;
