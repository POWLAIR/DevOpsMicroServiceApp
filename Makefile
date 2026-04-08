# DevOps MicroService App — Commandes locales
# Usage : make dev | make up | make seed | make down

.PHONY: dev up seed down logs

# Démarrage local complet avec hot reload : build + up + seed (usage recommandé en local)
dev:
	./scripts/start-local.sh

# Démarrage des conteneurs uniquement en production (sans seed, sans hot reload)
up:
	docker compose up -d --build

# Seed des données (après docker compose up -d)
seed:
	bash scripts/init-complete-data.sh

# Arrêt des conteneurs
down:
	docker compose down

# Logs de tous les services
logs:
	docker compose logs -f
