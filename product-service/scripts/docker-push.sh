#!/bin/bash

# Script pour build et push l'image product-service sur Docker Hub
# Usage: ./scripts/docker-push.sh [version]
# Example: ./scripts/docker-push.sh v1.0.0

set -e

DOCKER_USERNAME="powlker"
IMAGE_NAME="product-service"
VERSION="${1:-latest}"

echo "================================================"
echo "Building and pushing $IMAGE_NAME to Docker Hub"
echo "================================================"

# Build l'image
echo "1. Building Docker image..."
docker build -t $IMAGE_NAME:latest .

# Tag l'image
echo "2. Tagging images..."
docker tag $IMAGE_NAME:latest $DOCKER_USERNAME/$IMAGE_NAME:latest

if [ "$VERSION" != "latest" ]; then
  docker tag $IMAGE_NAME:latest $DOCKER_USERNAME/$IMAGE_NAME:$VERSION
  echo "   Tagged: $DOCKER_USERNAME/$IMAGE_NAME:$VERSION"
fi

echo "   Tagged: $DOCKER_USERNAME/$IMAGE_NAME:latest"

# Login Docker Hub (si nécessaire)
echo "3. Checking Docker Hub login..."
if ! docker info | grep -q "Username: $DOCKER_USERNAME"; then
  echo "   Please login to Docker Hub:"
  docker login
fi

# Push l'image
echo "4. Pushing images to Docker Hub..."
docker push $DOCKER_USERNAME/$IMAGE_NAME:latest

if [ "$VERSION" != "latest" ]; then
  docker push $DOCKER_USERNAME/$IMAGE_NAME:$VERSION
  echo "   Pushed: $DOCKER_USERNAME/$IMAGE_NAME:$VERSION"
fi

echo "   Pushed: $DOCKER_USERNAME/$IMAGE_NAME:latest"

echo ""
echo "================================================"
echo "✅ Successfully pushed to Docker Hub!"
echo "================================================"
echo ""
echo "Images available:"
echo "  - $DOCKER_USERNAME/$IMAGE_NAME:latest"
if [ "$VERSION" != "latest" ]; then
  echo "  - $DOCKER_USERNAME/$IMAGE_NAME:$VERSION"
fi
echo ""
echo "To deploy on Kubernetes, update k8s/deployments/product-deployment.yaml:"
echo "  image: $DOCKER_USERNAME/$IMAGE_NAME:latest"
echo ""

