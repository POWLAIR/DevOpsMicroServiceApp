# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances
RUN npm ci

# Copier le code source
COPY . .

# Build l'application
RUN npm run build

# Stage 2: Production
FROM node:20-alpine

WORKDIR /app

# Installer curl pour le healthcheck
RUN apk add --no-cache curl

# Copier les fichiers de build depuis le stage précédent
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

# Créer le dossier pour la base de données
RUN mkdir -p /app/data

# Exposer le port
EXPOSE 4000

# Démarrer l'application
CMD ["node", "dist/main"]

