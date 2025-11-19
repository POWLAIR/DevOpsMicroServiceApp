#!/bin/bash

# 🚀 Script de migration Gitea → GitHub
# Organisation GitHub: POWLAIR (https://github.com/POWLAIR)

set -e

echo "🔄 Migration des microservices vers GitHub (POWLAIR)"
echo "======================================================"
echo ""

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_ORG="POWLAIR"
GITHUB_BASE_URL="git@github.com:${GITHUB_ORG}"

# Liste des services à migrer
SERVICES=(
    "frontend"
    "auth-service"
    "order-service"
    "product-service"
    "notification-service"
    "payment-service"
    "tenant-service"
)

# Fonction pour afficher un message coloré
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction pour vérifier si un repo GitHub existe
check_github_repo() {
    local repo_name=$1
    if gh repo view "${GITHUB_ORG}/${repo_name}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Fonction pour créer un repo GitHub
create_github_repo() {
    local repo_name=$1
    local description=$2
    
    print_status "Création du repo GitHub: ${repo_name}"
    
    if check_github_repo "${repo_name}"; then
        print_warning "Le repo ${repo_name} existe déjà sur GitHub"
        return 0
    fi
    
    gh repo create "${GITHUB_ORG}/${repo_name}" \
        --private \
        --description "${description}" \
        --confirm
    
    print_success "Repo ${repo_name} créé sur GitHub"
}

# Fonction pour migrer un service
migrate_service() {
    local service_dir=$1
    local repo_name="devops-${service_dir}"
    
    echo ""
    print_status "Migration de ${service_dir} → ${repo_name}"
    echo "------------------------------------------------------------"
    
    if [ ! -d "${service_dir}" ]; then
        print_error "Le dossier ${service_dir} n'existe pas"
        return 1
    fi
    
    cd "${service_dir}"
    
    # Vérifier si c'est un repo git
    if [ ! -d ".git" ]; then
        print_warning "${service_dir} n'est pas un repo git, initialisation..."
        git init
        git add .
        git commit -m "REFACTOR-[${service_dir}] : initial commit for GitHub migration"
    fi
    
    # Ajouter le remote GitHub
    print_status "Ajout du remote GitHub..."
    if git remote get-url github &>/dev/null; then
        print_warning "Remote 'github' existe déjà, mise à jour..."
        git remote set-url github "${GITHUB_BASE_URL}/${repo_name}.git"
    else
        git remote add github "${GITHUB_BASE_URL}/${repo_name}.git"
    fi
    
    # Pousser vers GitHub
    print_status "Push vers GitHub..."
    git push -u github main || git push -u github master || {
        print_error "Échec du push vers GitHub pour ${service_dir}"
        cd ..
        return 1
    }
    
    print_success "${service_dir} migré vers GitHub/${GITHUB_ORG}/${repo_name}"
    cd ..
}

# Vérification des prérequis
echo "📋 Vérification des prérequis..."
echo ""

if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) n'est pas installé"
    echo "Installation: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    print_error "GitHub CLI n'est pas authentifié"
    echo "Exécutez: gh auth login"
    exit 1
fi

print_success "Prérequis validés"

# Étape 1: Créer les repos GitHub
echo ""
echo "========================================"
echo "📦 ÉTAPE 1/3 : Création des repos GitHub"
echo "========================================"

for service in "${SERVICES[@]}"; do
    repo_name="devops-${service}"
    description="MicroService ${service} - DevOps Architecture Polyglotte"
    create_github_repo "${repo_name}" "${description}"
done

print_success "Tous les repos GitHub sont prêts"

# Étape 2: Migration des services
echo ""
echo "========================================"
echo "🔄 ÉTAPE 2/3 : Migration des services"
echo "========================================"

for service in "${SERVICES[@]}"; do
    migrate_service "${service}"
done

print_success "Tous les services ont été migrés"

# Étape 3: Mise à jour des submodules
echo ""
echo "========================================"
echo "🔗 ÉTAPE 3/3 : Mise à jour des submodules"
echo "========================================"

print_status "Désynchronisation des anciens submodules Gitea..."
git submodule deinit -f frontend auth-service order-service 2>/dev/null || true

print_status "Suppression du cache des submodules..."
rm -rf .git/modules/frontend .git/modules/auth-service .git/modules/order-service 2>/dev/null || true
rm -rf .git/modules/product-service .git/modules/notification-service .git/modules/payment-service .git/modules/tenant-service 2>/dev/null || true

print_status "Synchronisation des nouveaux submodules GitHub..."
git submodule sync

print_status "Initialisation des submodules..."
git submodule update --init --recursive --remote

print_success "Submodules mis à jour vers GitHub"

# Résumé final
echo ""
echo "========================================"
echo "✅ MIGRATION TERMINÉE"
echo "========================================"
echo ""
echo "📦 Repos GitHub créés (${#SERVICES[@]}):"
for service in "${SERVICES[@]}"; do
    echo "   - https://github.com/${GITHUB_ORG}/devops-${service}"
done
echo ""
echo "🔗 Prochaines étapes:"
echo "   1. Vérifier les repos sur https://github.com/${GITHUB_ORG}"
echo "   2. Commiter le .gitmodules mis à jour:"
echo "      git add .gitmodules"
echo "      git commit -m 'REFACTOR-[repo-parent] : migrate submodules to GitHub'"
echo "      git push"
echo ""
echo "   3. Supprimer les anciens repos Gitea (optionnel)"
echo ""
print_success "Migration réussie ! 🚀"

