#!/usr/bin/env bash

# NixOS Rebuild Script
# This script handles system updates for the current configuration.

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

# Menu
echo "=================================================="
echo "          NIXOS SYSTEM MANAGEMENT                 "
echo "=================================================="
echo "1) Switch (Apply changes immediately)"
echo "2) Boot (Apply changes on next boot)"
echo "3) Test (Apply changes temporarily)"
echo "4) Cleanup (Collect garbage and optimize store)"
echo "5) Exit"
echo "=================================================="
read -p "Select an option [1-5]: " OPTION

case $OPTION in
    1)
        log_info "Applying changes..."
        nixos-rebuild switch -I nixos-config=./configuration.nix
        ;;
    2)
        log_info "Setting changes for next boot..."
        nixos-rebuild boot -I nixos-config=./configuration.nix
        ;;
    3)
        log_info "Testing changes..."
        nixos-rebuild test -I nixos-config=./configuration.nix
        ;;
    4)
        log_info "Cleaning up system..."
        nix-collect-garbage -d
        nix-store --optimise
        log_success "Cleanup complete!"
        exit 0
        ;;
    5)
        exit 0
        ;;
    *)
        log_error "Invalid option."
        exit 1
        ;;
esac

log_success "Operation completed successfully!"
