# Secrets Kubernetes

## JWT Secret

Le secret JWT est utilisé par les services auth-service et order-service pour signer et vérifier les tokens JWT.

### Création du secret

**Important** : Ne jamais commiter les secrets en clair dans Git.

#### Méthode 1 : Via kubectl (recommandé)

```bash
kubectl create secret generic jwt-secret \
  --from-literal=SECRET_KEY=your-super-secret-key-change-in-production \
  --from-literal=JWT_SECRET=your-super-secret-key-change-in-production \
  -n microservices
```

#### Méthode 2 : Via fichier YAML

1. Copier le template :
```bash
cp jwt-secret.yaml.example jwt-secret.yaml
```

2. Modifier les valeurs dans `jwt-secret.yaml` avec vos vraies clés secrètes.

3. Appliquer le secret :
```bash
kubectl apply -f jwt-secret.yaml
```

**Note** : Assurez-vous que `jwt-secret.yaml` est dans `.gitignore` pour ne pas le commiter.

### Vérification

```bash
# Vérifier que le secret existe
kubectl get secret jwt-secret -n microservices

# Voir les clés du secret (sans les valeurs)
kubectl describe secret jwt-secret -n microservices
```

### Mise à jour

```bash
# Supprimer l'ancien secret
kubectl delete secret jwt-secret -n microservices

# Créer le nouveau secret
kubectl create secret generic jwt-secret \
  --from-literal=SECRET_KEY=new-secret-key \
  --from-literal=JWT_SECRET=new-secret-key \
  -n microservices

# Redémarrer les pods pour prendre en compte le nouveau secret
kubectl rollout restart deployment/auth-deployment -n microservices
kubectl rollout restart deployment/order-deployment -n microservices
```

