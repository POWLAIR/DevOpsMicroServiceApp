#!/bin/bash
# ============================================
# SCRIPT D'INITIALISATION COMPLÈTE DES DONNÉES
# ============================================
# Ce script initialise les données applicatives :
# - Tenants et utilisateurs : créés au démarrage par auth-service
# - Produits, avis, favoris, commandes : via seed-complete-data.sql
# Usage : bash scripts/init-complete-data.sh
#         ou via scripts/start-local.sh (build + up + seed)
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# docker compose (v2) ou docker-compose (v1)
COMPOSE="docker compose"
if ! docker compose version &>/dev/null; then
  COMPOSE="docker-compose"
fi

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

step() { echo -e "${BLUE}▶ $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

echo "============================================"
echo "🚀 INITIALISATION COMPLÈTE DES DONNÉES"
echo "============================================"

step "Vérification des services Docker..."
if ! $COMPOSE ps 2>/dev/null | grep -q "Up"; then
  error "Les services Docker ne sont pas démarrés."
  echo "Lancez d'abord: $COMPOSE up -d"
  exit 1
fi
success "Services Docker actifs"

step "Attente de la disponibilité des services (30s)..."
sleep 30
success "Services prêts"

step "Seeding produits, avis, favoris, commandes (PostgreSQL)..."
cat "$SCRIPT_DIR/seed-complete-data.sql" | $COMPOSE exec -T postgres psql -U saas_admin -d saas_platform
success "Données créées"

step "Vérification des données..."
echo ""
echo "============================================"
echo "📊 STATISTIQUES"
echo "============================================"
USERS_COUNT=$($COMPOSE exec -T postgres psql -U saas_admin -d saas_platform -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d ' ')
PRODUCTS_COUNT=$($COMPOSE exec -T postgres psql -U saas_admin -d saas_platform -t -c "SELECT COUNT(*) FROM products;" 2>/dev/null | tr -d ' ')
FAVORITES_COUNT=$($COMPOSE exec -T postgres psql -U saas_admin -d saas_platform -t -c "SELECT COUNT(*) FROM favorites;" 2>/dev/null | tr -d ' ')
REVIEWS_COUNT=$($COMPOSE exec -T postgres psql -U saas_admin -d saas_platform -t -c "SELECT COUNT(*) FROM reviews;" 2>/dev/null | tr -d ' ')
ORDERS_COUNT=$($COMPOSE exec -T postgres psql -U saas_admin -d saas_platform -t -c "SELECT COUNT(*) FROM orders;" 2>/dev/null | tr -d ' ')
echo "👥 Utilisateurs: $USERS_COUNT"
echo "📦 Produits: $PRODUCTS_COUNT"
echo "❤️  Favoris: $FAVORITES_COUNT"
echo "⭐ Avis: $REVIEWS_COUNT"
echo "📋 Commandes: $ORDERS_COUNT"
echo "============================================"
success "INITIALISATION TERMINÉE !"
echo ""
echo "🎯 Comptes de test (mot de passe : Test1234!)"
echo "   Admin: admin@example.com"
echo "   Owner: merchant1@tech-store.com"
echo "   Staff: staff1@tech-store.com"
echo "   Customer: customer1@example.com"
echo ""
echo "🌐 Frontend: http://localhost:3001"
echo ""
