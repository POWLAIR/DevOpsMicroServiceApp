#!/bin/bash
# ============================================
# DÉMARRAGE LOCAL COMPLET — Build + Up + Seed
# ============================================
# Lance la stack Docker, attend que les services soient healthy,
# puis exécute le seed des données (produits, avis, favoris, commandes).
# Usage : ./scripts/start-local.sh
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

echo "============================================"
echo "🚀 DÉMARRAGE LOCAL — Build + Up + Seed"
echo "============================================"

# 1. Build et démarrage
echo ""
echo "▶ Build et démarrage des conteneurs..."
$COMPOSE up -d --build

# 2. Attendre que les services soient healthy
echo ""
echo "▶ Attente de la disponibilité des services (healthchecks)..."
MAX_WAIT=120
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
  if $COMPOSE ps 2>/dev/null | grep -q "unhealthy"; then
    sleep 5
    ELAPSED=$((ELAPSED + 5))
    continue
  fi
  # Vérifier que auth-service et product-service sont up
  if $COMPOSE ps auth-service product-service postgres 2>/dev/null | grep -q "Up"; then
    echo "   Services démarrés, attente supplémentaire (30s) pour les healthchecks..."
    sleep 30
    break
  fi
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
  echo "⚠️  Timeout. Les services peuvent ne pas être tous prêts."
  echo "   Vous pouvez lancer manuellement : bash scripts/init-complete-data.sh"
fi

# 3. Seed des données
echo ""
bash "$SCRIPT_DIR/init-complete-data.sh"

echo ""
echo "============================================"
echo "✅ Environnement local prêt !"
echo "   Frontend : http://localhost:3001"
echo "============================================"
