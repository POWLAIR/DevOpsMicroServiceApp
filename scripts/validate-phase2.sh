#!/bin/bash

# Script de validation Phase 2
# Teste tous les services (Auth, Order, Product, Payment, Notification)

set -e

echo "🔍 Validation Phase 2 - Services Polyglotte"
echo "=============================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de test
test_service() {
    local name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $name... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$response" -eq "$expected_status" ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $response)"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC} (HTTP $response, expected $expected_status)"
        return 1
    fi
}

# Tests
echo "1️⃣  Auth Service (Python FastAPI)"
test_service "Auth Health Check" "http://localhost:8000/health"

echo ""
echo "2️⃣  Order Service (NestJS)"
test_service "Order Health Check" "http://localhost:3000/health"

echo ""
echo "3️⃣  Product Service (NestJS)"
test_service "Product Health Check" "http://localhost:4000/health"

echo ""
echo "4️⃣  Payment Service (Go)"
test_service "Payment Health Check" "http://localhost:5000/health"

echo ""
echo "5️⃣  Notification Service (Python)"
test_service "Notification Health Check" "http://localhost:6000/health"

echo ""
echo "6️⃣  Frontend (Next.js)"
test_service "Frontend" "http://localhost:3001" 200 || test_service "Frontend" "http://localhost:3001" 307

echo ""
echo "=============================================="
echo -e "${GREEN}✅ Tous les services sont opérationnels !${NC}"
echo ""
echo "📊 Services actifs :"
echo "  - Auth Service (Python):       http://localhost:8000"
echo "  - Order Service (NestJS):      http://localhost:3000"
echo "  - Product Service (NestJS):    http://localhost:4000"
echo "  - Payment Service (Go):        http://localhost:5000"
echo "  - Notification Service (Py):   http://localhost:6000"
echo "  - Frontend (Next.js):          http://localhost:3001"
echo ""
echo "🔧 Backends :"
echo "  - PostgreSQL:                  localhost:5433"
echo "  - Redis:                       localhost:6380"
echo ""
echo "Pour tester les endpoints :"
echo "  Payment:      ./scripts/test-payment.sh"
echo "  Notification: ./scripts/test-notification.sh"



