#!/usr/bin/env bash

# NixOS Rebuild Script with Placeholder Sync
# This script handles system updates and ensures placeholders like @USERNAME@
# are correctly replaced with the active system values.

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

# --- SYNC PHASE ---
log_info "Syncing placeholders..."

# Detect the real user (even when running with sudo)
REAL_USER=${SUDO_USER:-$(whoami)}
if [ "$REAL_USER" == "root" ]; then
    # If we are still root, try to find the first normal user in /home
    REAL_USER=$(ls /home | head -n 1)
fi

log_info "Active user detected: $REAL_USER"

# Files to sync
FILES_TO_SYNC=(
    "modules/user.nix"
    "modules/base.nix"
    "modules/cosmic.nix"
)

for FILE in "${FILES_TO_SYNC[@]}"; do
    if [ -f "$FILE" ]; then
        if grep -q "@USERNAME@" "$FILE"; then
            log_info "Replacing placeholders in $FILE..."
            sed -i "s/@USERNAME@/$REAL_USER/g" "$FILE"
        fi
    fi
done

# --- REBUILD PHASE ---
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
