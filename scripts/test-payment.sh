#!/bin/bash

# Script de test Payment Service
# Teste la création d'un Payment Intent (nécessite JWT)

set -e

echo "💳 Test Payment Service"
echo "======================="
echo ""

# Configuration
PAYMENT_URL="http://localhost:5000"
TENANT_ID="test-tenant-123"

# 1. Health check
echo "1️⃣  Health check..."
curl -s "$PAYMENT_URL/health" | jq '.'
echo ""

# 2. Créer un Payment Intent (nécessite JWT)
echo "2️⃣  Créer Payment Intent..."
echo ""
echo "⚠️  Cette requête nécessite un JWT token valide."
echo ""
echo "Exemple de requête :"
echo ""
cat <<'EOF'
curl -X POST http://localhost:5000/api/v1/payments/create-intent \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "X-Tenant-ID: test-tenant-123" \
  -d '{
    "amount": 100.00,
    "currency": "eur",
    "order_id": "order-uuid-123"
  }'
EOF
echo ""
echo ""

# 3. Liste des paiements (nécessite JWT)
echo "3️⃣  Liste des paiements..."
echo ""
echo "Exemple de requête :"
echo ""
cat <<'EOF'
curl -X GET http://localhost:5000/api/v1/payments \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "X-Tenant-ID: test-tenant-123"
EOF
echo ""
echo ""

echo "✅ Pour obtenir un JWT token, authentifiez-vous via Auth Service :"
echo ""
echo "curl -X POST http://localhost:8000/api/v1/auth/login \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"email\": \"user@example.com\", \"password\": \"password\"}'"
echo ""



