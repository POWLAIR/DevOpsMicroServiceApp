# 🚀 Guide de Démarrage Rapide

Ce guide vous permet de lancer l'application en **5 minutes** après avoir cloné le projet.

## 📑 Table des matières

1. [Prérequis](#-prérequis)
2. [Méthode 1 : Développement local (recommandé)](#-méthode-1--développement-local-recommandé)
3. [Méthode 2 : Docker Compose](#-méthode-2--docker-compose)
4. [Méthode 3 : Kubernetes](#-méthode-3--kubernetes)
5. [Problèmes courants](#-problèmes-courants)
6. [Ressources](#-ressources)

---

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- **Node.js 20+** : [Télécharger Node.js](https://nodejs.org/)
- **Python 3.11+** : [Télécharger Python](https://www.python.org/downloads/)
- **Git** : [Télécharger Git](https://git-scm.com/)

Vérifiez vos installations :

```bash
node --version  # Doit afficher v20.x ou supérieur
python3 --version  # Doit afficher 3.11.x ou supérieur
git --version
```

---

## 💻 Méthode 1 : Développement local (recommandé)

<details>
<summary><strong>▶️ Cliquer pour afficher les étapes de déploiement local</strong></summary>

### 🔽 Étape 1 : Cloner le projet

```bash
# Cloner le repo parent
git clone git@gitea.com:PowlAIR/DevOpsMicoServiceApp.git DevOpsMicroServiceApp
cd DevOpsMicroServiceApp

# Initialiser et cloner les submodules (IMPORTANT !)
git submodule update --init --recursive
```

✅ **Vérification** : Vous devriez voir 3 dossiers : `frontend/`, `auth-service/`, `order-service/`

### ⚙️ Étape 2 : Installer les dépendances

Installer les dépendances de chaque service :

```bash
(cd frontend && npm install) # Installer les dépendances de Next.js
(cd auth-service && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt) # Installer les dépendances de FastAPI
(cd order-service && npm install) # Installer les dépendances de NestJS
```

### 🔐 Étape 3 : Configurer les variables d'environnement

#### 3.1 Copier les fichiers `.env.example`

```bash
(cd frontend && cp .env.example .env.local)
(cd auth-service && cp .env.example .env)
(cd order-service && cp .env.example .env)
```

#### 3.2 Configurer les variables

<details>
<summary><strong>▶️ Variables d'environnement de chaque service</strong></summary>

**Frontend (`.env.local`)** :

```env
AUTH_SERVICE_URL=http://localhost:8000
ORDER_SERVICE_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:3001
```

**Auth Service (`.env`)** :

```env
DATABASE_URL=sqlite:///./auth.db
SECRET_KEY=dev-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
HOST=0.0.0.0
PORT=8000
CORS_ORIGINS=http://localhost:3001,http://localhost:3000
```

**Order Service (`.env`)** :

```env
DATABASE_PATH=./orders.db
JWT_SECRET=dev-secret-key-change-in-production
JWT_ALGORITHM=HS256
PORT=3000
HOST=0.0.0.0
CORS_ORIGINS=http://localhost:3001,http://localhost:3000
AUTH_SERVICE_URL=http://localhost:8000
```

⚠️ **Important** : `JWT_SECRET` dans Order Service doit être **identique** à `SECRET_KEY` dans Auth Service.

</details>

### ▶️ Étape 4 : Lancer les services

Ouvrez **3 terminaux séparés** et lancez les services dans cet ordre :

**Terminal 1 - Auth Service (port 8000)** :

```bash
cd DevOpsMicroServiceApp/auth-service
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

✅ Vous devriez voir : `Uvicorn running on http://0.0.0.0:8000`

**Terminal 2 - Order Service (port 3000)** :

```bash
cd DevOpsMicroServiceApp/order-service
npm run start:dev
```

✅ Vous devriez voir : `Nest application successfully started`

**Terminal 3 - Frontend (port 3001)** :

```bash
cd DevOpsMicroServiceApp/frontend
npm run dev
```

✅ Vous devriez voir : `Ready on http://localhost:3001`

### ✅ Étape 5 : Vérifier que tout fonctionne

Une fois les 3 services démarrés, testez les URLs suivantes :

- **Frontend** : [http://localhost:3001](http://localhost:3001)
- **Auth Service** : [http://localhost:8000](http://localhost:8000)
  - Documentation Swagger : [http://localhost:8000/docs](http://localhost:8000/docs)
  - Health Check : [http://localhost:8000/health](http://localhost:8000/health)
- **Order Service** : [http://localhost:3000](http://localhost:3000)
  - Health Check : [http://localhost:3000/health](http://localhost:3000/health)

### 🎯 Test rapide

1. Ouvrez [http://localhost:3001](http://localhost:3001) dans votre navigateur
2. Inscrivez-vous avec un email et un mot de passe
3. Connectez-vous avec vos identifiants
4. Créez une commande

Si tout fonctionne, vous êtes prêt ! 🎉

</details>

---

## 🐳 Méthode 2 : Docker Compose

<details>
<summary><strong>▶️ Cliquer pour afficher les étapes de déploiement avec Docker Compose</strong></summary>

Si vous préférez utiliser Docker plutôt que d'installer les dépendances localement :

### Prérequis Docker

- **Docker** : [Télécharger Docker](https://www.docker.com/get-started)
- **Docker Compose** : Inclus avec Docker Desktop

Vérifiez vos installations :

```bash
docker --version
docker-compose --version
```

### Configuration

1. Créer un fichier `.env` à la racine du projet :

```bash
cd DevOpsMicroServiceApp
echo "JWT_SECRET=dev-secret-key-change-in-production" > .env
```

⚠️ **Important** : Utilisez la même valeur pour `JWT_SECRET` dans le fichier `.env`.

### Lancer avec Docker Compose

```bash
# Depuis la racine du projet
docker-compose up --build
```

✅ **Résultat** : Les 3 services démarrent automatiquement dans des conteneurs Docker.

### Commandes utiles Docker

<details>
<summary><strong>▶️ Commandes Docker utiles</strong></summary>

```bash
# Lancer en arrière-plan
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Voir les logs d'un service spécifique
docker-compose logs -f auth-service

# Arrêter les services
docker-compose down

# Arrêter et supprimer les volumes (⚠️ supprime les bases de données)
docker-compose down -v

# Reconstruire les images
docker-compose build --no-cache

# Vérifier le statut des conteneurs
docker-compose ps
```

</details>

### URLs des services (Docker)

Les URLs sont identiques à la version locale :

- **Frontend** : [http://localhost:3001](http://localhost:3001)
- **Auth Service** : [http://localhost:8000](http://localhost:8000)
- **Order Service** : [http://localhost:3000](http://localhost:3000)

</details>

---

## ☸️ Méthode 3 : Kubernetes

<details>
<summary><strong>▶️ Cliquer pour afficher les étapes de déploiement sur Kubernetes</strong></summary>

Pour déployer l'application sur un cluster Kubernetes local (Minikube ou Orbstack) :

### Prérequis Kubernetes

- **Kubernetes cluster local** : Minikube ou Orbstack
- **kubectl** : [Installer kubectl](https://kubernetes.io/docs/tasks/tools/)
- **Docker** : Pour construire les images

### Option 1 : Minikube

<details>
<summary><strong>▶️ Installation et déploiement avec Minikube</strong></summary>

#### Installation Minikube

```bash
# Installer Minikube (Linux)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Démarrer Minikube
minikube start

# Activer l'Ingress
minikube addons enable ingress

# Configurer Docker pour utiliser le daemon Minikube
eval $(minikube docker-env)
```

#### Déploiement sur Minikube

Une fois Minikube installé et configuré, suivez ces étapes pour déployer l'application :

```bash
# 1. Construire les images Docker (dans le contexte Minikube)
(cd auth-service && docker build -t auth-service:latest .)
(cd order-service && docker build -t order-service:latest .)
(cd frontend && docker build -t frontend:latest .)

# 2. Créer le namespace
kubectl apply -f k8s/namespace.yaml

# 3. Créer les ConfigMaps
kubectl apply -f k8s/configmaps/

# 4. Créer le Secret JWT
kubectl create secret generic jwt-secret \
  --from-literal=SECRET_KEY=dev-secret-key-change-in-production \
  --from-literal=JWT_SECRET=dev-secret-key-change-in-production \
  -n microservices

# 5. Créer les PersistentVolumeClaims
kubectl apply -f k8s/persistent-volumes/

# 6. Créer les Deployments
kubectl apply -f k8s/deployments/

# 7. Créer les Services
kubectl apply -f k8s/services/

# 8. Créer l'Ingress
kubectl apply -f k8s/ingress/
```

</details>

### Option 2 : Orbstack

<details>
<summary><strong>▶️ Installation et déploiement avec Orbstack</strong></summary>

Orbstack est une alternative à Docker Desktop qui inclut Kubernetes.

1. Installer Orbstack : [https://orbstack.dev/](https://orbstack.dev/)
2. Activer Kubernetes dans les paramètres d'Orbstack
3. Suivre les mêmes étapes de déploiement (sans `eval $(minikube docker-env)`)

</details>

### Vérification du déploiement

```bash
# Vérifier les pods
kubectl get pods -n microservices

# Vérifier les services
kubectl get services -n microservices

# Vérifier les PVCs
kubectl get pvc -n microservices
```

Tous les pods doivent être en état `Running`.

### Accès aux services

<details>
<summary><strong>▶️ Méthodes d'accès aux services Kubernetes</strong></summary>

#### Via Port Forward (recommandé pour le développement)

```bash
# Frontend
kubectl port-forward svc/frontend-service 3001:3001 -n microservices

# Auth Service
kubectl port-forward svc/auth-service 8000:8000 -n microservices

# Order Service
kubectl port-forward svc/order-service 3000:3000 -n microservices
```

#### Via Ingress (Minikube)

```bash
# Obtenir l'IP de l'Ingress
kubectl get ingress -n microservices

# Utiliser le tunnel Minikube
minikube tunnel

# Accéder via l'IP de l'Ingress ou microservices.local
```

</details>

### Commandes utiles Kubernetes

<details>
<summary><strong>▶️ Commandes Kubernetes utiles</strong></summary>

```bash
# Voir les logs d'un pod
kubectl logs -f <pod-name> -n microservices

# Voir les logs d'un deployment
kubectl logs -f deployment/auth-deployment -n microservices

# Décrire un pod (debugging)
kubectl describe pod <pod-name> -n microservices

# Redémarrer un deployment
kubectl rollout restart deployment/auth-deployment -n microservices

# Vérifier le statut d'un rollout
kubectl rollout status deployment/auth-deployment -n microservices

# Rollback
kubectl rollout undo deployment/auth-deployment -n microservices

# Voir les événements
kubectl get events -n microservices --sort-by='.lastTimestamp'

# Exécuter une commande dans un pod
kubectl exec -it <pod-name> -n microservices -- /bin/sh
```

</details>

### Nettoyage

```bash
# Supprimer tous les ressources Kubernetes
kubectl delete namespace microservices
```

</details>

---

## 🐛 Problèmes courants

<details>
<summary><strong>▶️ Cliquer pour afficher les solutions aux problèmes courants</strong></summary>

### Problèmes généraux

<details>
<summary><strong>▶️ Problèmes de clonage et dépendances</strong></summary>

#### Les submodules sont vides

```bash
git submodule update --init --recursive
```

#### Port déjà utilisé

- Vérifiez qu'aucun autre service n'utilise les ports 8000, 3000, 3001
- Sur Linux/Mac : `lsof -i :8000` pour voir qui utilise le port
- Sur Windows : `netstat -ano | findstr :8000`

#### Erreur "Module not found" (Python)

```bash
cd auth-service
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### Erreur "Cannot find module" (Node.js)

```bash
cd frontend  # ou order-service
rm -rf node_modules
npm install
```

#### Erreur "venv not found" (Python)

```bash
cd auth-service
python3 -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### Erreur JWT "Invalid token"

- Vérifiez que `SECRET_KEY` (Auth Service) = `JWT_SECRET` (Order Service)
- Redémarrez les deux services après modification

</details>

### Problèmes Docker

<details>
<summary><strong>▶️ Problèmes spécifiques à Docker</strong></summary>

#### Erreur "Cannot connect to Docker daemon"

- Vérifiez que Docker Desktop est démarré
- Sur Linux : `sudo systemctl start docker`

#### Erreur "Port already allocated"

- Arrêtez les services locaux qui utilisent les ports 8000, 3000, 3001
- Ou modifiez les ports dans `docker-compose.yml`

#### Les conteneurs redémarrent en boucle

```bash
# Voir les logs pour identifier le problème
docker-compose logs <service-name>

# Vérifier les healthchecks
docker-compose ps

# Vérifier les événements Docker
docker events
```

</details>

### Problèmes Kubernetes

<details>
<summary><strong>▶️ Problèmes spécifiques à Kubernetes</strong></summary>

#### Les pods restent en état "Pending"

```bash
# Vérifier les événements
kubectl get events -n microservices --sort-by='.lastTimestamp'

# Vérifier les ressources disponibles
kubectl describe node

# Vérifier les quotas de ressources
kubectl describe quota -n microservices
```

#### Erreur "ImagePullBackOff"

- Vérifiez que les images sont construites dans le bon contexte
- Avec Minikube : `eval $(minikube docker-env)` avant de construire
- Vérifiez que `imagePullPolicy: IfNotPresent` est défini
- Vérifiez les logs : `kubectl describe pod <pod-name> -n microservices`

#### Les PVCs restent en état "Pending"

```bash
# Vérifier les storage classes disponibles
kubectl get storageclass

# Vérifier les événements du PVC
kubectl describe pvc <pvc-name> -n microservices

# Modifier le storageClassName dans les PVCs si nécessaire
```

#### Erreur Ingress "no endpoints available"

- Vérifiez que les services sont actifs : `kubectl get svc -n microservices`
- Vérifiez que les pods sont en état Running : `kubectl get pods -n microservices`
- Vérifiez que l'Ingress Controller est actif : `kubectl get pods -n ingress-nginx`
- Vérifiez les sélecteurs des services : `kubectl describe svc <service-name> -n microservices`

#### Les pods crashent en boucle (CrashLoopBackOff)

```bash
# Voir les logs du pod
kubectl logs <pod-name> -n microservices

# Voir les événements précédents
kubectl logs <pod-name> -n microservices --previous

# Décrire le pod pour voir les raisons du crash
kubectl describe pod <pod-name> -n microservices
```

</details>

</details>

---

## 📚 Ressources

### Documentation

- [Documentation complète](../README.md)
- [Liens Notion du projet](./notion-links.md)
- [Analyse TP 06](./tp/tp06-analyse.md)

### Astuces

- Gardez les 3 terminaux ouverts pendant le développement (méthode locale)
- Les services redémarrent automatiquement lors des modifications (hot reload)
- Les bases de données SQLite sont créées automatiquement au premier démarrage
- Consultez les logs dans chaque terminal pour le debugging

### Prochaines étapes

- **Développement** : Consultez le [README.md](../README.md) pour plus de détails
- **Docker** : Utilisez `docker-compose up` pour lancer avec Docker
- **Kubernetes** : Consultez la section Kubernetes du README pour le déploiement avancé

---

**Besoin d'aide ?** Consultez la [documentation complète](../README.md) ou les README de chaque service.
