#!/bin/bash

# Script pour pusher les nouveaux workflows GitHub Actions vers les repos des services
# Auteur : DevOps Team
# Date : 21/11/2024

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction pour pusher un workflow
push_workflow() {
    local service=$1
    local service_path="/home/paul/efrei-project/DevOpsMicroServiceApp/$service"
    
    log_info "Processing $service..."
    
    # Vérifier si le service existe
    if [ ! -d "$service_path" ]; then
        log_error "Service directory not found: $service_path"
        return 1
    fi
    
    # Vérifier si le workflow existe
    if [ ! -f "$service_path/.github/workflows/docker-push.yml" ]; then
        log_warning "Workflow not found for $service, skipping..."
        return 0
    fi
    
    # Entrer dans le dossier du service
    cd "$service_path"
    
    # Vérifier si c'est un repo Git
    if [ ! -d ".git" ]; then
        log_error "$service is not a Git repository"
        return 1
    fi
    
    # Vérifier le statut Git
    if ! git diff --quiet .github/workflows/docker-push.yml 2>/dev/null; then
        log_info "Changes detected in workflow for $service"
        
        # Ajouter le fichier
        git add .github/workflows/docker-push.yml
        
        # Commit
        git commit -m "FIX-[$service] : add GitHub Actions workflow for Docker push"
        
        # Push (demander confirmation)
        read -p "$(echo -e ${YELLOW}Push to GitHub for $service? [y/N]:${NC} )" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin main
            log_success "Workflow pushed for $service"
        else
            log_warning "Push cancelled for $service"
        fi
    else
        log_info "No changes detected for $service"
    fi
    
    cd - > /dev/null
}

# Banner
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   GitHub Actions Workflows Push Script        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Services à traiter (nouveaux workflows créés)
SERVICES=(
    "product-service"
    "payment-service"
    "notification-service"
    "tenant-service"
)

# Mode interactif ou automatique
if [ "$1" == "--auto" ]; then
    log_warning "Mode automatique activé (pas de confirmation)"
    AUTO_MODE=true
else
    AUTO_MODE=false
fi

# Traiter chaque service
for service in "${SERVICES[@]}"; do
    echo ""
    push_workflow "$service"
done

echo ""
log_success "All workflows processed!"

# Récapitulatif
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Summary                                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "1. Verify the workflows on GitHub (Actions tab)"
echo "2. Configure Docker Hub secrets if not already done:"
echo "   - DOCKERHUB_USERNAME"
echo "   - DOCKERHUB_TOKEN"
echo "3. Test the workflows manually via GitHub UI"
echo ""

log_info "Check the audit report: docs/WORKFLOW-AUDIT.md"

