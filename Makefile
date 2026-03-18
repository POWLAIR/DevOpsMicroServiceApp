# DevOps MicroService App — Commandes locales
# Usage : make dev | make hotreload | make up | make seed | make down

.PHONY: dev hotreload up seed down logs

# Démarrage local complet : build + up + seed (usage recommandé en local)
dev:
	./scripts/start-local.sh

# Démarrage en mode hot reload (toutes les modifications de code sont prises en compte à chaud)
# Chaque service surveille ses fichiers sources et se recompile/redémarre automatiquement.
hotreload:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build

# Démarrage des conteneurs uniquement (sans seed)
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
