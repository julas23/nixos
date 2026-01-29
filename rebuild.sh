#!/usr/bin/env bash

# NixOS Rebuild & Configuration Tool
# This script handles system updates and interactive reconfiguration.

set -euo pipefail

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root (sudo ./rebuild.sh)"
    exit 1
fi

# Determine the directory of the script
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

VARS_FILE="$REPO_DIR/modules/vars.nix"
USER_FILE="$REPO_DIR/modules/user.nix"
BASE_FILE="$REPO_DIR/modules/base.nix"

reconfigure_system() {
    echo "=================================================="
    echo "       INTERACTIVE SYSTEM RECONFIGURATION         "
    echo "=================================================="
    
    read -p "USERNAME: " USERNAME
    read -s -p "PASSWORD: " PASSWORD
    echo
    read -s -p "CONFIRM PASSWORD: " PASSWORD_CONFIRM
    echo
    if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then log_error "Passwords do not match."; return 1; fi

    read -p "FULL NAME: " FULLNAME
    read -p "HOSTNAME: " HOSTNAME

    echo -e "\nGPU (Driver):"
    select GPU in "amdgpu" "nvidia" "intel" "vm"; do
        if [ -n "$GPU" ]; then break; fi
    done

    echo -e "\nGUI (Graphics):"
    select GUI in "wayland" "xorg"; do
        if [ -n "$GUI" ]; then break; fi
    done

    echo -e "\nDESKTOP (Interface):"
    select DESKTOP in "cosmic" "xfce" "gnome" "hyprland" "i3" "mate" "awesome"; do
        if [ -n "$DESKTOP" ]; then break; fi
    done

    echo -e "\nAI (Ollama):"
    select AI_OPT in "Yes" "No"; do
        AI_VAL=$([ "$AI_OPT" == "Yes" ] && echo "Y" || echo "N")
        break
    done

    log_info "Applying new configuration to files..."

    # Update vars.nix
    sed -i "/desktop = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$DESKTOP\";/" "$VARS_FILE"
    sed -i "/graphic = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GUI\";/" "$VARS_FILE"
    sed -i "/video = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GPU\";/" "$VARS_FILE"
    sed -i "/ollama = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$AI_VAL\";/" "$VARS_FILE"

    # Update user.nix & base.nix (Placeholders)
    # We replace @USERNAME@ or the previous values if already set
    # Note: This part assumes placeholders might be there or we replace the specific pattern
    sed -i "s/@USERNAME@/$USERNAME/g" "$USER_FILE" "$BASE_FILE"
    sed -i "s/@PASSWORD@/$PASSWORD/g" "$USER_FILE"
    sed -i "s/@FULLNAME@/$FULLNAME/g" "$USER_FILE"

    # Update Hostname in configuration.nix
    sed -i "s/networking.hostName = \".*\";/networking.hostName = \"$HOSTNAME\";/" "$REPO_DIR/configuration.nix"

    log_success "Configuration updated! You can now run 'Switch'."
}

# Menu
while true; do
    echo "=================================================="
    echo "          NIXOS SYSTEM MANAGEMENT                 "
    echo "=================================================="
    echo "1) Switch (Apply changes immediately)"
    echo "2) Reconfigure (Change User, Host, GPU, etc.)"
    echo "3) Boot (Apply changes on next boot)"
    echo "4) Test (Apply changes temporarily)"
    echo "5) Cleanup (Collect garbage and optimize store)"
    echo "6) Exit"
    echo "=================================================="
    read -p "Select an option [1-6]: " OPTION

    case $OPTION in
        1)
            log_info "Applying changes..."
            nixos-rebuild switch -I nixos-config=./configuration.nix
            break
            ;;
        2)
            reconfigure_system
            ;;
        3)
            log_info "Setting changes for next boot..."
            nixos-rebuild boot -I nixos-config=./configuration.nix
            break
            ;;
        4)
            log_info "Testing changes..."
            nixos-rebuild test -I nixos-config=./configuration.nix
            break
            ;;
        5)
            log_info "Cleaning up system..."
            nix-collect-garbage -d
            nix-store --optimise
            log_success "Cleanup complete!"
            ;;
        6)
            exit 0
            ;;
        *)
            log_error "Invalid option."
            ;;
    esac
done

log_success "Operation completed successfully!"
