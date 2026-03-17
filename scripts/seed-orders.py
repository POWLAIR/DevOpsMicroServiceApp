#!/usr/bin/env python3
"""
Script de seeding pour créer des commandes réalistes
À exécuter après le démarrage de Docker Compose
"""

import sqlite3
import uuid
from datetime import datetime, timedelta
import random
import json

# Configuration
DB_PATH = "./order-service/orders.db"
TECH_STORE_TENANT = "36ee6e56-0344-4a85-999f-4730bf5c38c2"
FASHION_TENANT = "1574b85d-a3df-400f-9e82-98831aa32934"

# IDs des utilisateurs (à récupérer depuis auth-service)
# Pour simplifier, on utilise des UUIDs fictifs qui seront remplacés
CUSTOMERS = {
    "customer1": "customer1-uuid-placeholder",
    "customer2": "customer2-uuid-placeholder",
    "customer-test": "customer-test-uuid-placeholder",
}

# Produits exemple (prix)
PRODUCTS_TECH = [
    {"name": "Laptop HP EliteBook", "price": 1299.99},
    {"name": "iPhone 15 Pro", "price": 1199.99},
    {"name": "Samsung 4K TV 55\"", "price": 899.99},
    {"name": "Casque Sony WH-1000XM5", "price": 349.99},
    {"name": "Apple Watch Series 9", "price": 429.99},
]

STATUSES = ["pending", "processing", "shipped", "delivered", "cancelled"]
PAYMENT_STATUSES = ["pending", "paid", "failed", "refunded"]


def create_orders():
    """Créer des commandes réalistes"""
    
    print("🚀 Création des commandes...")
    
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # Créer la table si elle n'existe pas
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS orders (
                id TEXT PRIMARY KEY,
                tenant_id TEXT NOT NULL,
                user_id TEXT NOT NULL,
                status TEXT NOT NULL,
                total_amount REAL NOT NULL,
                payment_status TEXT NOT NULL,
                shipping_address TEXT,
                items TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        """)
        
        orders_created = 0
        
        # Créer 10 commandes pour Tech Store
        for i in range(10):
            order_id = str(uuid.uuid4())
            user_id = random.choice(list(CUSTOMERS.values()))
            
            # Sélectionner 1-3 produits aléatoires
            num_items = random.randint(1, 3)
            items = random.sample(PRODUCTS_TECH, num_items)
            
            total = sum(item["price"] * random.randint(1, 2) for item in items)
            
            status = random.choices(
                STATUSES,
                weights=[10, 20, 30, 35, 5],  # Plus de commandes livrées
                k=1
            )[0]
            
            payment_status = "paid" if status in ["processing", "shipped", "delivered"] else random.choice(PAYMENT_STATUSES)
            
            created_at = datetime.now() - timedelta(days=random.randint(1, 90))
            updated_at = created_at + timedelta(days=random.randint(0, 7))
            
            items_json = json.dumps([
                {
                    "product_id": str(uuid.uuid4()),
                    "name": item["name"],
                    "price": item["price"],
                    "quantity": random.randint(1, 2)
                }
                for item in items
            ])
            
            shipping_address = json.dumps({
                "street": f"{random.randint(1, 999)} rue de la Paix",
                "city": random.choice(["Paris", "Lyon", "Marseille", "Toulouse"]),
                "postal_code": f"{random.randint(10000, 99999)}",
                "country": "France"
            })
            
            cursor.execute("""
                INSERT INTO orders (
                    id, tenant_id, user_id, status, total_amount,
                    payment_status, shipping_address, items,
                    created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                order_id,
                TECH_STORE_TENANT,
                user_id,
                status,
                total,
                payment_status,
                shipping_address,
                items_json,
                created_at.isoformat(),
                updated_at.isoformat()
            ))
            
            orders_created += 1
        
        conn.commit()
        conn.close()
        
        print(f"✅ {orders_created} commandes créées avec succès!")
        print(f"📊 Répartition des statuts:")
        print(f"   - Pending: ~10%")
        print(f"   - Processing: ~20%")
        print(f"   - Shipped: ~30%")
        print(f"   - Delivered: ~35%")
        print(f"   - Cancelled: ~5%")
        
    except Exception as e:
        print(f"❌ Erreur lors de la création des commandes: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    create_orders()
