# Déploiement Kubernetes

Ce répertoire contient tous les manifests Kubernetes pour déployer l'application microservices.

## Structure

```
k8s/
├── namespace.yaml              # Namespace microservices
├── configmaps/                 # ConfigMaps pour la configuration
├── secrets/                    # Secrets (ne pas commiter les valeurs réelles)
├── persistent-volumes/         # PersistentVolumeClaims
├── statefulsets/              # StatefulSets (PostgreSQL)
├── deployments/               # Deployments des services
├── services/                  # Services Kubernetes
└── ingress/                   # Configuration Ingress
```

## Prérequis

1. Un cluster Kubernetes fonctionnel (minikube, kind, ou cloud)
2. `kubectl` installé et configuré
3. Ingress Controller NGINX installé (pour l'ingress)
4. Les images Docker doivent être disponibles (ou utiliser un registry)

### Installation de l'Ingress Controller NGINX

```bash
# Pour minikube
minikube addons enable ingress

# Pour un cluster Kubernetes standard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

## Déploiement

### Déploiement complet

Pour déployer toute l'infrastructure avec un seul appareil :

```bash
kubectl apply -f k8s/
```

Cette commande appliquera récursivement tous les manifests YAML dans le répertoire `k8s/`.

### Ordre de déploiement recommandé

Si vous préférez déployer dans un ordre spécifique :

```bash
# 1. Namespace
kubectl apply -f k8s/namespace.yaml

# 2. Secrets (à personnaliser avant)
kubectl apply -f k8s/secrets/

# 3. ConfigMaps
kubectl apply -f k8s/configmaps/

# 4. Persistent Volumes
kubectl apply -f k8s/persistent-volumes/

# 5. StatefulSets (PostgreSQL)
kubectl apply -f k8s/statefulsets/

# 6. Deployments (Redis et services applicatifs)
kubectl apply -f k8s/deployments/

# 7. Services
kubectl apply -f k8s/services/

# 8. Ingress
kubectl apply -f k8s/ingress/
```

## Configuration des Secrets

**IMPORTANT** : Les fichiers de secrets dans ce répertoire contiennent des valeurs par défaut pour le développement.
En production, vous devez :

1. Créer vos propres secrets via `kubectl` :

```bash
kubectl create secret generic db-secret \
  --from-literal=POSTGRES_PASSWORD=your-secure-password \
  -n microservices
```

1. Ou utiliser un gestionnaire de secrets externe (Vault, Sealed Secrets, etc.)

## Services déployés

- **PostgreSQL** : Base de données principale (StatefulSet)
- **Redis** : Cache et sessions (Deployment)
- **auth-service** : Service d'authentification (port 8000)
- **order-service** : Service de commandes (port 3000)
- **product-service** : Service de produits (port 4000)
- **payment-service** : Service de paiement (port 5000)
- **notification-service** : Service de notifications (port 6000)
- **notification-worker** : Worker Celery pour les notifications
- **tenant-service** : Service de gestion des tenants (port 7000)
- **frontend** : Application Next.js (port 3001)

## Accès aux services

### Via Ingress (recommandé)

Ajouter dans `/etc/hosts` (ou `C:\Windows\System32\drivers\etc\hosts` sur Windows) :

```
<INGRESS_IP> microservices.local
```

Récupérer l'IP de l'ingress :

```bash
kubectl get ingress -n microservices
```

Accéder à l'application :

- Frontend : <http://microservices.local>
- Auth API : <http://microservices.local/api/auth>
- Orders API : <http://microservices.local/api/orders>
- Products API : <http://microservices.local/api/products>
- Payments API : <http://microservices.local/api/payments>
- Notifications API : <http://microservices.local/api/notifications>
- Tenants API : <http://microservices.local/api/tenants>

### Via Port Forward (développement)

```bash
# Frontend
kubectl port-forward -n microservices svc/frontend-service 3001:3001

# Auth Service
kubectl port-forward -n microservices svc/auth-service 8000:8000

# etc.
```

## Vérification du déploiement

```bash
# Vérifier les pods
kubectl get pods -n microservices

# Vérifier les services
kubectl get svc -n microservices

# Vérifier les ingresses
kubectl get ingress -n microservices

# Logs d'un service
kubectl logs -n microservices deployment/auth-deployment

# Décrire un pod pour debug
kubectl describe pod -n microservices <pod-name>
```

## Coexistence Docker et Kubernetes

L'infrastructure est conçue pour coexister avec Docker Compose :

- Les mêmes images Docker peuvent être utilisées
- Les mêmes variables d'environnement sont supportées
- La base de données PostgreSQL est partagée conceptuellement (mais séparée en pratique)
- Vous pouvez déployer avec Docker Compose pour le développement local et Kubernetes pour la production

## Notes importantes

1. **StorageClass** : Assurez-vous que votre cluster a un StorageClass `standard` configuré, ou modifiez les PVCs pour utiliser celui disponible
2. **Images** : Les images référencées doivent être disponibles dans votre registry Docker
3. **Ressources** : Ajustez les limites de ressources selon votre infrastructure
4. **Scaling** : Les deployments peuvent être mis à l'échelle avec `kubectl scale`

## Dépannage

```bash
# Voir les événements
kubectl get events -n microservices --sort-by='.lastTimestamp'

# Redémarrer un deployment
kubectl rollout restart deployment/<deployment-name> -n microservices

# Voir les logs d'un container spécifique
kubectl logs -n microservices <pod-name> -c <container-name>
```
