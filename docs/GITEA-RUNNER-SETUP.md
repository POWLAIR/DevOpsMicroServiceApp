# 🏃 Guide - Configuration Runner Gitea Actions

Ce guide explique comment installer et configurer un runner Gitea Actions pour automatiser le CI/CD de vos 4 services.

---

## 📋 Prérequis

- ✅ Linux x86_64 (votre système actuel)
- ✅ Docker installé et en cours d'exécution
- ✅ Accès sudo
- ✅ Compte sur Gitea (gitea.com)

---

## 🎯 Architecture

```
┌─────────────────┐
│  Gitea Server   │
│  (gitea.com)    │
└────────┬────────┘
         │ webhook
         │
┌────────▼────────────────────────┐
│   Gitea Actions Runner          │
│   (votre machine locale)        │
│                                 │
│  ┌──────────────────────────┐  │
│  │  Docker Engine           │  │
│  │  (build & push images)   │  │
│  └──────────────────────────┘  │
└─────────────────────────────────┘
```

---

## 🚀 Installation du Runner

### Étape 1 : Télécharger act_runner

```bash
# Télécharger la dernière version stable
cd /home/paul/efrei-project/DevOpsMicroServiceApp
wget https://dl.gitea.com/act_runner/0.2.6/act_runner-0.2.6-linux-amd64

# Vérifier le téléchargement
ls -lh act_runner-0.2.6-linux-amd64
```

### Étape 2 : Installer act_runner

```bash
# Rendre exécutable
chmod +x act_runner-0.2.6-linux-amd64

# Déplacer vers /usr/local/bin (nécessite sudo)
sudo mv act_runner-0.2.6-linux-amd64 /usr/local/bin/act_runner

# Vérifier l'installation
act_runner --version
```

**Résultat attendu** : `act_runner version 0.2.6`

---

## 🔑 Obtenir le Token d'Enregistrement

### Pour chaque repository, vous devez obtenir un token d'enregistrement

#### **Option A : Token au niveau du repository** (recommandé pour le TP)

1. **Auth Service**
   - Aller sur : `https://gitea.com/PowlAIR/Auth-DevOpsMicoServiceApp/settings/actions/runners`
   - Copier le **Registration Token**

2. **Frontend**
   - Aller sur : `https://gitea.com/PowlAIR/Frontend-DevOpsMicoServiceApp/settings/actions/runners`
   - Copier le **Registration Token**

3. **Order Service**
   - Aller sur : `https://gitea.com/PowlAIR/OrderService-DevOpsMicoServiceApp/settings/actions/runners`
   - Copier le **Registration Token**

4. **DevOpsMicroServiceApp** (repo parent)
   - Aller sur : `https://gitea.com/PowlAIR/DevOpsMicoServiceApp/settings/actions/runners`
   - Copier le **Registration Token**

#### **Option B : Token au niveau de l'organisation** (plus simple)

1. Aller sur : `https://gitea.com/org/PowlAIR/settings/actions/runners`
2. Copier le **Registration Token**
3. Ce token fonctionnera pour **tous vos repos**

---

## ⚙️ Configuration du Runner

### Étape 1 : Créer le répertoire de travail

```bash
# Créer un dossier pour le runner
mkdir -p /home/paul/efrei-project/gitea-runner
cd /home/paul/efrei-project/gitea-runner
```

### Étape 2 : Générer le fichier de configuration

```bash
# Générer la configuration par défaut
act_runner generate-config > config.yaml
```

### Étape 3 : Éditer la configuration (optionnel)

```bash
# Ouvrir le fichier de config
nano config.yaml
```

**Configuration recommandée pour le développement local** :

```yaml
log:
  level: info

runner:
  file: .runner
  capacity: 1
  envs: {}
  timeout: 3h
  insecure: false
  fetch_timeout: 5s
  fetch_interval: 2s
  labels: []

cache:
  enabled: true
  dir: ""
  host: ""
  port: 0
  external_server: ""

container:
  network: ""
  privileged: false
  options: ""
  workdir_parent: ""
  valid_volumes: []
  docker_host: ""
  force_pull: false
```

---

## 🔗 Enregistrer le Runner

### Méthode 1 : Token d'organisation (simple, 1 seul runner pour tous les repos)

```bash
cd /home/paul/efrei-project/gitea-runner

# Remplacer <REGISTRATION_TOKEN> par votre token
act_runner register \
  --instance https://gitea.com \
  --token <REGISTRATION_TOKEN> \
  --name "local-runner" \
  --labels "ubuntu-latest:docker://node:20-bookworm"
```

### Méthode 2 : Token par repository (4 runners distincts)

**Pour Auth Service** :

```bash
mkdir -p /home/paul/efrei-project/gitea-runner/auth
cd /home/paul/efrei-project/gitea-runner/auth

act_runner register \
  --instance https://gitea.com \
  --token <AUTH_REGISTRATION_TOKEN> \
  --name "auth-runner" \
  --labels "ubuntu-latest:docker://node:20-bookworm"
```

**Pour Frontend** :

```bash
mkdir -p /home/paul/efrei-project/gitea-runner/frontend
cd /home/paul/efrei-project/gitea-runner/frontend

act_runner register \
  --instance https://gitea.com \
  --token <FRONTEND_REGISTRATION_TOKEN> \
  --name "frontend-runner" \
  --labels "ubuntu-latest:docker://node:20-bookworm"
```

**Pour Order Service** :

```bash
mkdir -p /home/paul/efrei-project/gitea-runner/order
cd /home/paul/efrei-project/gitea-runner/order

act_runner register \
  --instance https://gitea.com \
  --token <ORDER_REGISTRATION_TOKEN> \
  --name "order-runner" \
  --labels "ubuntu-latest:docker://node:20-bookworm"
```

**Pour DevOpsMicroServiceApp** :

```bash
mkdir -p /home/paul/efrei-project/gitea-runner/parent
cd /home/paul/efrei-project/gitea-runner/parent

act_runner register \
  --instance https://gitea.com \
  --token <PARENT_REGISTRATION_TOKEN> \
  --name "parent-runner" \
  --labels "ubuntu-latest:docker://node:20-bookworm"
```

**Résultat attendu** : `Runner registered successfully`

---

## 🏃 Démarrer le Runner

### Option A : Runner d'organisation (1 seul runner)

```bash
cd /home/paul/efrei-project/gitea-runner
act_runner daemon
```

### Option B : Runners multiples (4 runners, 4 terminaux)

**Terminal 1 - Auth Runner** :

```bash
cd /home/paul/efrei-project/gitea-runner/auth
act_runner daemon
```

**Terminal 2 - Frontend Runner** :

```bash
cd /home/paul/efrei-project/gitea-runner/frontend
act_runner daemon
```

**Terminal 3 - Order Runner** :

```bash
cd /home/paul/efrei-project/gitea-runner/order
act_runner daemon
```

**Terminal 4 - Parent Runner** :

```bash
cd /home/paul/efrei-project/gitea-runner/parent
act_runner daemon
```

**Résultat attendu** :

```
INFO[0000] Starting runner daemon
INFO[0000] Runner registered
INFO[0000] Listening for jobs...
```

⚠️ **Important** : Le runner doit rester actif dans le terminal. Ne pas fermer le terminal.

---

## 🔄 Exécuter en arrière-plan (Service Systemd)

Pour que le runner démarre automatiquement et tourne en arrière-plan :

### Étape 1 : Créer le service systemd

```bash
sudo nano /etc/systemd/system/gitea-runner.service
```

**Contenu du fichier** :

```ini
[Unit]
Description=Gitea Actions Runner
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=paul
WorkingDirectory=/home/paul/efrei-project/gitea-runner
ExecStart=/usr/local/bin/act_runner daemon
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Étape 2 : Activer et démarrer le service

```bash
# Recharger systemd
sudo systemctl daemon-reload

# Activer le service (démarre au boot)
sudo systemctl enable gitea-runner

# Démarrer le service
sudo systemctl start gitea-runner

# Vérifier le statut
sudo systemctl status gitea-runner

# Voir les logs
sudo journalctl -u gitea-runner -f
```

---

## ✅ Vérifier que le Runner fonctionne

### 1. Vérifier sur Gitea

Aller sur :

- `https://gitea.com/PowlAIR/Auth-DevOpsMicoServiceApp/settings/actions/runners`
- Vous devriez voir votre runner avec un **statut vert (actif)**

### 2. Tester le workflow

#### Option 1 : Déclencher manuellement

1. Aller sur : `https://gitea.com/PowlAIR/Auth-DevOpsMicoServiceApp/actions`
2. Cliquer sur le workflow **Build and Push Auth Service Docker Image**
3. Cliquer sur **Run workflow**
4. Sélectionner la branche `main`
5. Cliquer sur **Run workflow**

#### Option 2 : Push un commit

```bash
cd /home/paul/efrei-project/DevOpsMicroServiceApp/auth-service

# Faire un changement mineur
echo "# Test CI/CD" >> README.md

# Commit et push
git add README.md
git commit -m "test: trigger CI/CD workflow"
git push origin main
```

**Résultat attendu** :

- Le workflow se déclenche automatiquement
- Le runner exécute le job
- L'image est buildée et pushée sur Docker Hub

### 3. Vérifier les logs du runner

```bash
# Si lancé en mode daemon dans un terminal
# Les logs s'affichent directement

# Si lancé en service systemd
sudo journalctl -u gitea-runner -f
```

Vous devriez voir :

```
INFO[0000] Listening for jobs...
INFO[0010] Job received: Build and Push Auth Service Docker Image
INFO[0010] Job started
INFO[0120] Job completed successfully
```

---

## 🔐 Configurer les Secrets Docker Hub

Maintenant que le runner fonctionne, configurez les secrets dans **chaque repo Gitea** :

### Pour chaque repository

1. **Auth Service** : `https://gitea.com/PowlAIR/Auth-DevOpsMicoServiceApp/settings/secrets`
2. **Frontend** : `https://gitea.com/PowlAIR/Frontend-DevOpsMicoServiceApp/settings/secrets`
3. **Order Service** : `https://gitea.com/PowlAIR/OrderService-DevOpsMicoServiceApp/settings/secrets`
4. **Parent** : `https://gitea.com/PowlAIR/DevOpsMicoServiceApp/settings/secrets`

**Ajouter ces 2 secrets** :

| Nom | Valeur |
|-----|--------|
| `DOCKERHUB_USERNAME` | `powlker` |
| `DOCKERHUB_TOKEN` | `dckr_pat_xxx...` (token Docker Hub) |

---

## 🐛 Dépannage

### Erreur "connection refused"

```bash
# Vérifier que Docker est actif
sudo systemctl status docker

# Démarrer Docker si nécessaire
sudo systemctl start docker
```

### Erreur "permission denied /var/run/docker.sock"

```bash
# Ajouter votre user au groupe docker
sudo usermod -aG docker paul

# Redémarrer le runner
sudo systemctl restart gitea-runner
```

### Runner ne reçoit pas de jobs

- Vérifier que le runner est actif sur Gitea (statut vert)
- Vérifier que les labels correspondent : `ubuntu-latest`
- Vérifier que le workflow est bien déclenché (onglet Actions sur Gitea)

### Build échoue avec "out of memory"

Augmenter la capacité du runner dans `config.yaml` :

```yaml
runner:
  capacity: 1  # Nombre de jobs en parallèle
```

---

## 📊 Architecture finale

Une fois configuré, voici le flow automatique :

```
1. Push code vers Gitea
   ↓
2. Webhook déclenche le workflow
   ↓
3. Runner reçoit le job
   ↓
4. Build Docker image
   ↓
5. Push vers Docker Hub
   ↓
6. Notification de succès
```

---

## 🎯 Commandes Résumées

```bash
# Installation
wget https://dl.gitea.com/act_runner/0.2.6/act_runner-0.2.6-linux-amd64
chmod +x act_runner-0.2.6-linux-amd64
sudo mv act_runner-0.2.6-linux-amd64 /usr/local/bin/act_runner

# Configuration
mkdir -p /home/paul/efrei-project/gitea-runner
cd /home/paul/efrei-project/gitea-runner
act_runner generate-config > config.yaml

# Enregistrement (remplacer <TOKEN>)
act_runner register \
  --instance https://gitea.com \
  --token <REGISTRATION_TOKEN> \
  --name "local-runner" \
  --labels "ubuntu-latest:docker://node:20-bookworm"

# Démarrage
act_runner daemon

# Ou en service systemd
sudo systemctl enable gitea-runner
sudo systemctl start gitea-runner
sudo systemctl status gitea-runner
```

---

## 📚 Ressources

- [Documentation officielle Gitea Actions](https://docs.gitea.com/usage/actions/overview)
- [Repository act_runner](https://gitea.com/gitea/act_runner)
- [Configuration avancée](https://docs.gitea.com/usage/actions/act-runner)

---

**Prochaines étapes** :

1. Installer act_runner
2. Enregistrer le runner avec Gitea
3. Démarrer le runner
4. Configurer les secrets Docker Hub
5. Tester le workflow !
