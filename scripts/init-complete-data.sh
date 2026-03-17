#!/bin/bash
# ============================================
# SCRIPT D'INITIALISATION COMPLÈTE DES DONNÉES
# ============================================
# Ce script initialise toutes les données de l'application :
# - Tenants et utilisateurs (via auth-service)
# - Produits (via product-service)
# - Favoris et avis (via PostgreSQL)
# - Commandes (via order-service SQLite)
# ============================================

set -e  # Arrêter en cas d'erreur

echo "============================================"
echo "🚀 INITIALISATION COMPLÈTE DES DONNÉES"
echo "============================================"

# Couleurs pour les logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction pour afficher les étapes
step() {
    echo -e "${BLUE}▶ $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Vérifier que Docker Compose est lancé
step "Vérification des services Docker..."
if ! docker-compose ps | grep -q "Up"; then
    error "Les services Docker ne sont pas démarrés."
    echo "Lancez d'abord: docker-compose up -d"
    exit 1
fi
success "Services Docker actifs"

# Attendre que les services soient prêts
step "Attente de la disponibilité des services (30s)..."
sleep 30
success "Services prêts"

# 1. Seeding Auth Service (Tenants + Users)
step "1/5 - Seeding Auth Service (Tenants + Utilisateurs)..."
docker-compose exec -T auth-service python -c "
from app.database import SessionLocal
from app.services.seed_service import seed_all
db = SessionLocal()
try:
    seed_all(db)
    print('✅ Tenants et utilisateurs créés')
except Exception as e:
    print(f'❌ Erreur: {e}')
finally:
    db.close()
" || warning "Le seeding auth-service a peut-être déjà été effectué"

# 2. Seeding Product Service (Produits)
step "2/5 - Seeding Product Service (Produits)..."
docker-compose exec -T product-service npm run seed || warning "Le seeding product-service a peut-être déjà été effectué"

# Attendre que les produits soient créés
sleep 5

# 3. Seeding Favoris et Avis (PostgreSQL)
step "3/5 - Seeding Favoris et Avis..."
docker-compose exec -T postgres psql -U saas_admin -d saas_platform -f /scripts/seed-complete-data.sql 2>/dev/null || {
    # Si le fichier n'est pas monté, on l'exécute depuis l'hôte
    cat scripts/seed-complete-data.sql | docker-compose exec -T postgres psql -U saas_admin -d saas_platform
}
success "Favoris et avis créés"

# 4. Seeding Commandes (Order Service)
step "4/5 - Seeding Commandes..."
# Note: À implémenter selon la structure de order-service
warning "Seeding des commandes à implémenter (order-service utilise SQLite)"

# 5. Vérification finale
step "5/5 - Vérification des données..."

echo ""
echo "============================================"
echo "📊 STATISTIQUES DES DONNÉES CRÉÉES"
echo "============================================"

# Compter les utilisateurs
USERS_COUNT=$(docker-compose exec -T postgres psql -U saas_admin -d saas_platform -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d ' ')
echo "👥 Utilisateurs: $USERS_COUNT"

# Compter les produits
PRODUCTS_COUNT=$(docker-compose exec -T postgres psql -U saas_admin -d saas_platform -t -c "SELECT COUNT(*) FROM products;" 2>/dev/null | tr -d ' ')
echo "📦 Produits: $PRODUCTS_COUNT"

# Compter les favoris
FAVORITES_COUNT=$(docker-compose exec -T postgres psql -U saas_admin -d saas_platform -t -c "SELECT COUNT(*) FROM favorites;" 2>/dev/null | tr -d ' ')
echo "❤️  Favoris: $FAVORITES_COUNT"

# Compter les avis
REVIEWS_COUNT=$(docker-compose exec -T postgres psql -U saas_admin -d saas_platform -t -c "SELECT COUNT(*) FROM reviews;" 2>/dev/null | tr -d ' ')
echo "⭐ Avis: $REVIEWS_COUNT"

echo "============================================"
success "INITIALISATION COMPLÈTE TERMINÉE !"
echo "============================================"
echo ""
echo "🎯 Comptes de test disponibles:"
echo "   Customer: customer1@example.com / Customer123!"
echo "   Staff: staff1@tech-store.com / Staff123!"
echo "   Owner: merchant1@tech-store.com / Merchant123!"
echo "   Admin: admin@example.com / Admin123!"
echo ""
echo "🌐 Accès:"
echo "   Frontend: http://localhost:3000"
echo "   Auth API: http://localhost:8000"
echo "   Product API: http://localhost:4000"
echo ""
