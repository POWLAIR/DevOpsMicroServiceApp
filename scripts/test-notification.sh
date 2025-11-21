#!/bin/bash

# Script de test Notification Service
# Teste l'envoi d'emails et SMS

set -e

echo "📧 Test Notification Service"
echo "============================="
echo ""

# Configuration
NOTIFICATION_URL="http://localhost:6000"

# 1. Health check
echo "1️⃣  Health check..."
curl -s "$NOTIFICATION_URL/health" | jq '.'
echo ""

# 2. Envoyer email de confirmation
echo "2️⃣  Test email de confirmation de commande..."
curl -X POST "$NOTIFICATION_URL/api/v1/notifications/order-confirmation" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer@example.com",
    "order_data": {
      "orderNumber": "ORD-001",
      "total": 100.00,
      "status": "confirmed",
      "createdAt": "2025-01-21T10:00:00Z",
      "items": [
        {
          "name": "Product 1",
          "quantity": 2,
          "price": 50.00
        }
      ]
    },
    "tenant_settings": {
      "name": "Mon Shop",
      "email": "contact@shop.com",
      "url": "https://shop.com"
    }
  }' | jq '.'
echo ""

# 3. Envoyer email de bienvenue
echo "3️⃣  Test email de bienvenue..."
curl -X POST "$NOTIFICATION_URL/api/v1/notifications/welcome-email" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "user_data": {
      "name": "John Doe"
    },
    "tenant_settings": {
      "name": "Mon Shop",
      "email": "contact@shop.com",
      "url": "https://shop.com"
    }
  }' | jq '.'
echo ""

# 4. Envoyer SMS
echo "4️⃣  Test SMS..."
curl -X POST "$NOTIFICATION_URL/api/v1/notifications/sms" \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+33612345678",
    "message": "Votre commande a été confirmée ! Merci."
  }' | jq '.'
echo ""

echo "✅ Tests terminés !"
echo ""
echo "📝 Notes :"
echo "  - Les emails sont envoyés via SendGrid (si configuré)"
echo "  - Les SMS sont envoyés via Twilio (si configuré)"
echo "  - Les tâches sont traitées en async par Celery Worker"
echo ""
echo "🔍 Pour voir les logs du worker Celery :"
echo "  docker-compose logs -f notification-worker"
echo ""



