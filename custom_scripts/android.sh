#!/bin/bash
# ~/bin/flutter-dev.sh
# Script workflow complet Flutter + Neovim

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Vérifier les prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter n'est pas installé ou pas dans le PATH"
        exit 1
    fi
    
    # Vérifier les outils Android
    if ! command -v adb &> /dev/null; then
        log_error "Android Debug Bridge (adb) non trouvé"
        exit 1
    fi
    
    # Vérifier l'émulateur
    if ! command -v emulator &> /dev/null; then
        log_error "Émulateur Android non trouvé"
        exit 1
    fi
    
    # Vérifier Neovim
    if ! command -v nvim &> /dev/null; then
        log_error "Neovim n'est pas installé"
        exit 1
    fi
    
    log_success "Tous les prérequis sont satisfaits"
}

# Diagnostic Flutter
flutter_doctor() {
    log_info "Diagnostic Flutter..."
    flutter doctor -v
}

# Créer un nouveau projet Flutter
create_flutter_project() {
    read -p "Nom du projet Flutter : " project_name
    
    if [[ -z "$project_name" ]]; then
        log_error "Le nom du projet ne peut pas être vide"
        return 1
    fi
    
    # Aller dans le dossier de développement
    cd ~/development
    
    log_info "Création du projet '$project_name'..."
    flutter create "$project_name" \
        --org com.example \
        --project-name "$project_name" \
        --platforms android,linux \
        --template app
    
    cd "$project_name"
    
    # Ouvrir avec Neovim
    log_success "Projet '$project_name' créé. Ouverture avec Neovim..."
    nvim lib/main.dart
}

# Gérer les émulateurs
manage_emulators() {
    echo "📱 Gestion des émulateurs Android"
    echo "1) Lister les AVDs disponibles"
    echo "2) Démarrer l'émulateur par défaut"
    echo "3) Créer un nouvel AVD"
    echo "4) Supprimer un AVD"
    echo "5) Retour"
    
    read -p "Votre choix : " emulator_choice
    
    case $emulator_choice in
        1)
            log_info "AVDs disponibles :"
            avdmanager list avd
            ;;
        2)
            # Vérifier si l'AVD existe
            if ! avdmanager list avd | grep -q "MyAndroid34"; then
                log_warning "AVD MyAndroid34 introuvable"
                echo "AVDs disponibles :"
                avdmanager list avd | grep "Name:"
                
                read -p "Créer un nouvel AVD ? (y/N) : " create_avd
                if [[ "$create_avd" = "y" || "$create_avd" = "Y" ]]; then
                    # Créer un AVD simple
                    log_info "Création d'un AVD par défaut..."
                    avdmanager create avd -n "MyAndroid34" -k "system-images;android-34;google_apis;x86_64" --force
                    emulator -avd MyAndroid34 &
                else
                    return
                fi
            else
                emulator -avd MyAndroid34 &
            fi
            log_success "Émulateur démarré en arrière-plan"
            ;;
        3)
            create_new_avd
            ;;
        4)
            delete_avd
            ;;
        5)
            return
            ;;
        *)
            log_error "Choix invalide"
            ;;
    esac
}

# Créer un nouvel AVD
create_new_avd() {
    log_info "Images système disponibles :"
    sdkmanager --list | grep "system-images" | head -10
    
    read -p "Nom de l'AVD : " avd_name
    read -p "Package de l'image système (ex: system-images;android-34;google_apis;x86_64) : " system_image
    
    if [[ -z "$avd_name" || -z "$system_image" ]]; then
        log_error "Nom AVD et image système requis"
        return 1
    fi
    
    # Installer l'image si nécessaire
    log_info "Installation de l'image système..."
    sdkmanager "$system_image"
    
    # Lister les devices disponibles
    log_info "Devices disponibles :"
    avdmanager list device | grep -A 1 "id:" | head -10
    
    read -p "ID du device (ou Entrée pour défaut) : " device_id
    
    # Créer l'AVD avec ou sans device ID
    if [[ -z "$device_id" ]]; then
        log_info "Création de l'AVD sans device spécifique..."
        avdmanager create avd -n "$avd_name" -k "$system_image"
    else
        log_info "Création de l'AVD avec device $device_id..."
        avdmanager create avd -n "$avd_name" -k "$system_image" -d "$device_id"
    fi
    
    if [[ $? -eq 0 ]]; then
        # Optimiser l'AVD créé
        avd_path="$HOME/.android/avd/${avd_name}.avd"
        if [[ -d "$avd_path" ]]; then
            log_info "Optimisation de l'AVD..."
            echo "hw.keyboard=yes" >> "$avd_path/config.ini"
            echo "hw.gpu.enabled=yes" >> "$avd_path/config.ini"
            echo "hw.gpu.mode=host" >> "$avd_path/config.ini"
            echo "hw.ramSize=2048" >> "$avd_path/config.ini"
            echo "disk.dataPartition.size=4096MB" >> "$avd_path/config.ini"
        fi
        
        log_success "AVD '$avd_name' créé et optimisé"
    else
        log_error "Erreur lors de la création de l'AVD"
    fi
}

# Supprimer un AVD
delete_avd() {
    log_info "AVDs existants :"
    avdmanager list avd | grep "Name:"
    
    read -p "Nom de l'AVD à supprimer : " avd_name
    
    if [[ -z "$avd_name" ]]; then
        log_error "Nom de l'AVD requis"
        return 1
    fi
    
    avdmanager delete avd -n "$avd_name"
    log_success "AVD '$avd_name' supprimé"
}

# Gérer les projets Flutter
manage_projects() {
    if [[ ! -d ~/development ]]; then
        mkdir -p ~/development
    fi
    
    cd ~/development
    
    echo "📂 Gestion des projets Flutter"
    
    # Lister les projets existants
    log_info "Projets Flutter existants :"
    find . -maxdepth 2 -name "pubspec.yaml" -exec dirname {} \; | sort
    
    echo ""
    echo "1) Créer un nouveau projet"
    echo "2) Ouvrir un projet existant"
    echo "3) Supprimer un projet"
    echo "4) Retour"
    
    read -p "Votre choix : " project_choice
    
    case $project_choice in
        1)
            create_flutter_project
            ;;
        2)
            open_existing_project
            ;;
        3)
            delete_project
            ;;
        4)
            return
            ;;
        *)
            log_error "Choix invalide"
            ;;
    esac
}

# Ouvrir un projet existant
open_existing_project() {
    cd ~/development
    projects=($(find . -maxdepth 2 -name "pubspec.yaml" -exec dirname {} \; | sort))
    
    if [[ ${#projects[@]} -eq 0 ]]; then
        log_warning "Aucun projet Flutter trouvé"
        return
    fi
    
    echo "Projets disponibles :"
    for i in "${!projects[@]}"; do
        echo "$((i+1))) ${projects[i]}"
    done
    
    read -p "Choisissez un projet (numéro) : " project_num
    
    if [[ "$project_num" -gt 0 && "$project_num" -le ${#projects[@]} ]]; then
        selected_project=${projects[$((project_num-1))]}
        cd "$selected_project"
        log_success "Ouverture du projet $selected_project"
        nvim lib/main.dart
    else
        log_error "Numéro de projet invalide"
    fi
}

# Supprimer un projet
delete_project() {
    cd ~/development
    projects=($(find . -maxdepth 2 -name "pubspec.yaml" -exec dirname {} \; | sort))
    
    if [[ ${#projects[@]} -eq 0 ]]; then
        log_warning "Aucun projet Flutter trouvé"
        return
    fi
    
    echo "Projets à supprimer :"
    for i in "${!projects[@]}"; do
        echo "$((i+1))) ${projects[i]}"
    done
    
    read -p "Choisissez un projet à supprimer (numéro) : " project_num
    
    if [[ "$project_num" -gt 0 && "$project_num" -le ${#projects[@]} ]]; then
        selected_project=${projects[$((project_num-1))]}
        read -p "Êtes-vous sûr de vouloir supprimer '$selected_project' ? (y/N) : " confirm
        
        if [[ "$confirm" = "y" || "$confirm" = "Y" ]]; then
            rm -rf "$selected_project"
            log_success "Projet $selected_project supprimé"
        else
            log_info "Suppression annulée"
        fi
    else
        log_error "Numéro de projet invalide"
    fi
}

# Configuration smartphone physique
setup_physical_device() {
    echo ""
    log_info "📱 Configuration d'un smartphone physique"
    echo ""
    echo "Étapes à suivre sur votre smartphone :"
    echo "1. Paramètres → À propos du téléphone"
    echo "2. Taper 7x sur 'Numéro de build'"
    echo "3. Paramètres → Options développeur → Activer 'Débogage USB'"
    echo "4. Connecter le câble USB"
    echo "5. Autoriser le débogage sur l'écran du téléphone"
    echo ""
    
    read -p "Appuyez sur Entrée quand c'est fait..."
    
    log_info "Test de connexion..."
    
    # Attendre la détection
    timeout=30
    while [[ $timeout -gt 0 ]]; do
        if adb devices | grep -q "device"; then
            log_success "Smartphone détecté !"
            adb devices
            
            # Obtenir les infos du téléphone
            phone_model=$(adb shell getprop ro.product.model 2>/dev/null || echo "Unknown")
            android_version=$(adb shell getprop ro.build.version.release 2>/dev/null || echo "Unknown")
            
            echo ""
            log_success "Téléphone connecté :"
            echo "  Modèle: $phone_model"
            echo "  Android: $android_version"
            
            return 0
        fi
        
        echo -n "."
        sleep 1
        ((timeout--))
    done
    
    log_error "Impossible de détecter le smartphone"
    echo ""
    echo "Problèmes possibles :"
    echo "- Câble USB défectueux"
    echo "- Débogage USB non activé"
    echo "- Autorisation refusée sur le téléphone"
    echo "- Pilotes USB manquants"
    
    return 1
}

# Workflow de développement rapide
quick_dev_workflow() {
    log_info "🚀 Workflow de développement rapide"
    
    # Vérifier si on est dans un projet Flutter
    if [[ ! -f "pubspec.yaml" ]]; then
        log_error "Pas dans un projet Flutter"
        read -p "Voulez-vous créer un nouveau projet ? (y/N) : " create_new
        if [[ "$create_new" = "y" || "$create_new" = "Y" ]]; then
            create_flutter_project
            return
        else
            return 1
        fi
    fi
    
    # Détecter les appareils disponibles
    log_info "Détection des appareils..."
    devices=$(adb devices | grep -v "List of devices" | grep -E "device|emulator" | wc -l)
    
    if [[ $devices -eq 0 ]]; then
        log_warning "Aucun appareil détecté"
        echo "Options disponibles :"
        echo "1) Connecter un smartphone physique"
        echo "2) Démarrer l'émulateur"
        echo "3) Annuler"
        
        read -p "Votre choix : " device_choice
        case $device_choice in
            1)
                setup_physical_device
                ;;
            2)
                log_info "Démarrage de l'émulateur..."
                if avdmanager list avd | grep -q "MyAndroid34"; then
                    emulator -avd MyAndroid34 > /dev/null 2>&1 &
                else
                    log_info "Création d'un AVD par défaut..."
                    avdmanager create avd -n "MyAndroid34" -k "system-images;android-34;google_apis;x86_64" --force
                    emulator -avd MyAndroid34 > /dev/null 2>&1 &
                fi
                ;;
            3)
                return
                ;;
        esac
    else
        log_success "$devices appareil(s) détecté(s)"
        adb devices
    fi
    
    # Menu de workflow rapide
    echo ""
    echo "⚡ Workflow rapide :"
    echo "1) Run + Hot Reload (recommandé)"
    echo "2) Build APK Debug"
    echo "3) Build APK Release et installer"
    echo "4) Analyser le code"
    echo "5) Tests"
    echo "6) Ouvrir avec Neovim"
    echo "7) Retour"
    
    read -p "Votre choix : " workflow_choice
    
    case $workflow_choice in
        1)
            log_info "Lancement de l'application avec Hot Reload..."
            flutter run
            ;;
        2)
            log_info "Build APK Debug..."
            flutter build apk --debug
            log_success "APK Debug créé dans build/app/outputs/flutter-apk/"
            ;;
        3)
            log_info "Build APK Release..."
            flutter build apk --release
            
            if [[ $? -eq 0 ]]; then
                log_success "APK Release créé"
                
                # Vérifier si un appareil est connecté
                if adb devices | grep -q "device"; then
                    read -p "Installer sur l'appareil connecté ? (Y/n) : " install_choice
                    if [[ "$install_choice" != "n" && "$install_choice" != "N" ]]; then
                        log_info "Installation de l'APK..."
                        adb install build/app/outputs/flutter-apk/app-release.apk
                        if [[ $? -eq 0 ]]; then
                            log_success "APK installé avec succès"
                        else
                            log_error "Erreur lors de l'installation"
                        fi
                    fi
                else
                    log_warning "Aucun appareil connecté pour l'installation"
                fi
                
                log_info "APK disponible dans : build/app/outputs/flutter-apk/"
            else
                log_error "Erreur lors du build"
            fi
            ;;
        4)
            log_info "Analyse du code..."
            flutter analyze
            ;;
        5)
            log_info "Lancement des tests..."
            flutter test
            ;;
        6)
            log_info "Ouverture avec Neovim..."
            nvim lib/main.dart
            ;;
        7)
            return
            ;;
        *)
            log_error "Choix invalide"
            ;;
    esac
}

# Outils de développement
dev_tools() {
    echo "🛠️  Outils de développement"
    echo "1) Nettoyer les caches Flutter"
    echo "2) Mettre à jour Flutter"
    echo "3) Lister les appareils connectés"
    echo "4) Installer des packages utiles"
    echo "5) Retour"
    
    read -p "Votre choix : " tools_choice
    
    case $tools_choice in
        1)
            log_info "Nettoyage des caches..."
            flutter clean
            flutter pub get
            log_success "Caches nettoyés"
            ;;
        2)
            log_info "Mise à jour de Flutter..."
            flutter upgrade
            ;;
        3)
            log_info "Appareils disponibles :"
            flutter devices
            ;;
        4)
            install_useful_packages
            ;;
        5)
            return
            ;;
        *)
            log_error "Choix invalide"
            ;;
    esac
}

# Installer des packages Flutter utiles
install_useful_packages() {
    if [[ ! -f "pubspec.yaml" ]]; then
        log_error "Pas dans un projet Flutter (pubspec.yaml introuvable)"
        return 1
    fi
    
    log_info "Installation des packages Flutter populaires..."
    
    # Packages de développement essentiels
    flutter pub add http
    flutter pub add shared_preferences
    flutter pub add provider
    flutter pub add sqflite
    flutter pub add path_provider
    flutter pub add image_picker
    flutter pub add url_launcher
    flutter pub add connectivity_plus
    
    # Packages de développement (dev dependencies)
    flutter pub add --dev flutter_lints
    flutter pub add --dev build_runner
    flutter pub add --dev json_annotation
    flutter pub add --dev json_serializable
    
    log_success "Packages installés avec succès"
    log_info "N'oubliez pas de redémarrer votre application"
}

# Fonction principale - Menu principal
main_menu() {
    clear
    echo "🎯 Flutter Development Workflow"
    echo "==============================="
    echo ""
    echo "1) 🚀 Workflow rapide (développement)"
    echo "2) 📂 Gérer les projets"
    echo "3) 📱 Gérer les émulateurs"
    echo "4) 📱 Configurer smartphone physique"
    echo "5) 🛠️  Outils de développement"
    echo "6) 🩺 Diagnostic Flutter (flutter doctor)"
    echo "7) ❌ Quitter"
    echo ""
    
    read -p "Votre choix (1-7) : " main_choice
    
    case $main_choice in
        1)
            quick_dev_workflow
            ;;
        2)
            manage_projects
            ;;
        3)
            manage_emulators
            ;;
        4)
            setup_physical_device
            ;;
        5)
            dev_tools
            ;;
        6)
            flutter_doctor
            ;;
        7)
            log_success "Au revoir ! 👋"
            exit 0
            ;;
        *)
            log_error "Choix invalide"
            ;;
    esac
    
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
    main_menu
}

# Script principal
main() {
    # Vérifier les prérequis
    check_prerequisites
    
    # Lancer le menu principal
    main_menu
}

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
