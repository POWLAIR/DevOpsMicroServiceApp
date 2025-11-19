#!/bin/bash

# 🔄 Script de continuation de migration (submodules existants)
# Ce script traite les submodules qui pointent encore vers Gitea

set -e

echo "🔄 Continuation de la migration Gitea → GitHub"
echo "==============================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

GITHUB_ORG="POWLAIR"

# Fonction pour migrer un submodule existant
migrate_existing_submodule() {
    local service_dir=$1
    local repo_name="devops-${service_dir}"
    
    echo ""
    print_status "Migration de ${service_dir} → ${repo_name}"
    echo "------------------------------------------------------------"
    
    cd "${service_dir}"
    
    # Vérifier si le remote github existe déjà
    if git remote get-url github &>/dev/null; then
        print_warning "Remote 'github' existe déjà, mise à jour..."
        git remote set-url github "git@github.com:${GITHUB_ORG}/${repo_name}.git"
    else
        print_status "Ajout du remote GitHub..."
        git remote add github "git@github.com:${GITHUB_ORG}/${repo_name}.git"
    fi
    
    # Pousser vers GitHub
    print_status "Push vers GitHub..."
    git push github main || git push github master || {
        print_warning "Tentative avec -u..."
        git push -u github main || git push -u github master
    }
    
    print_success "${service_dir} migré vers GitHub/${GITHUB_ORG}/${repo_name}"
    cd ..
}

# Migrer auth-service
migrate_existing_submodule "auth-service"

# Migrer order-service
migrate_existing_submodule "order-service"

# Migrer les autres services (s'ils existent et ne sont pas des submodules)
for service in "product-service" "notification-service" "payment-service" "tenant-service"; do
    if [ -d "${service}" ]; then
        if [ ! -d "${service}/.git" ]; then
            echo ""
            print_status "Initialisation de ${service}"
            cd "${service}"
            git init
            git add .
            git commit -m "REFACTOR-[${service}] : initial commit for GitHub migration"
            repo_name="devops-${service}"
            git remote add github "git@github.com:${GITHUB_ORG}/${repo_name}.git"
            git branch -M main
            git push -u github main
            print_success "${service} initialisé et migré"
            cd ..
        else
            migrate_existing_submodule "${service}"
        fi
    fi
done

echo ""
print_success "Migration des services terminée !"

# Mise à jour des submodules
echo ""
print_status "Synchronisation des submodules..."
cd ..
git submodule sync
git submodule set-url frontend git@github.com:${GITHUB_ORG}/devops-frontend.git
git submodule set-url auth-service git@github.com:${GITHUB_ORG}/devops-auth-service.git
git submodule set-url order-service git@github.com:${GITHUB_ORG}/devops-order-service.git

print_success "Submodules synchronisés !"

echo ""
echo "========================================"
echo "✅ MIGRATION TERMINÉE"
echo "========================================"
echo ""
echo "🔗 Prochaines étapes:"
echo "   1. Vérifier les repos sur https://github.com/${GITHUB_ORG}"
echo "   2. Commiter le .gitmodules mis à jour:"
echo "      git add .gitmodules"
echo "      git commit -m 'REFACTOR-[repo-parent] : migrate submodules to GitHub'"
echo ""
print_success "Migration réussie ! 🚀"

