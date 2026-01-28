#!/usr/bin/env bash
# install.sh - Full NixOS Provisioner (Disk -> Clone -> Config -> Install)

set -euo pipefail

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_step() { echo -e "${CYAN}[STEP]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

clear
echo "=================================================="
echo "   NIXOS PROVISIONER - FULL INSTALLATION          "
echo "=================================================="

# 0. Internet Verification
log_step "Checking internet connection..."
if ! ping -c 1 google.com &> /dev/null; then
    log_error "No internet connection! Please connect via nmtui or nmcli before continuing."
    exit 1
fi
log_success "Internet OK!"

# 1. Disk Selection
log_step "Detecting disks..."
lsblk -p -d -n -o NAME,SIZE,MODEL
echo ""
read -p "Enter the disk path for installation (e.g., /dev/sda or /dev/nvme0n1): " DISK

if [ ! -b "$DISK" ]; then
    log_error "Disk not found!"
    exit 1
fi

echo -e "${YELLOW}WARNING: All data on $DISK will be erased!${NC}"
read -p "Are you sure? (y/n): " CONFIRM_DISK
if [[ ! $CONFIRM_DISK =~ ^[Yy]$ ]]; then exit 1; fi

# 2. Simple Partitioning (EFI + Root)
log_step "Partitioning disk $DISK..."
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary ext4 512MiB 100%

# Define partition names (handling nvme)
if [[ $DISK == *"nvme"* ]]; then
    BOOT_PART="${DISK}p1"
    ROOT_PART="${DISK}p2"
else
    BOOT_PART="${DISK}1"
    ROOT_PART="${DISK}2"
fi

log_step "Formatting partitions..."
mkfs.vfat -F 32 -n BOOT "$BOOT_PART"
mkfs.ext4 -L NIXOS "$ROOT_PART"

log_step "Mounting partitions to /mnt..."
mount /dev/disk/by-label/NIXOS /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot

# 3. Repository Cloning
log_step "Cloning NixOS repository..."
mkdir -p /mnt/etc
git clone https://github.com/julas23/nixos.git /mnt/etc/nixos

# 4. Hardware Configuration Generation
log_step "Generating hardware-configuration.nix..."
nixos-generate-config --root /mnt

# 5. User Information Collection
echo -e "\n${CYAN}--- SYSTEM CONFIGURATION ---${NC}"
read -p "USERNAME: " USERNAME
read -s -p "PASSWORD: " PASSWORD
echo
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

# 6. Applying Configurations
REPO_DIR="/mnt/etc/nixos"
VARS_FILE="$REPO_DIR/modules/vars.nix"
USER_FILE="$REPO_DIR/modules/user.nix"
BASE_FILE="$REPO_DIR/modules/base.nix"
CONFIG_FILE="$REPO_DIR/configuration.nix"

log_step "Applying settings to Nix files..."
# Vars
sed -i "/desktop = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$DESKTOP\";/" "$VARS_FILE"
sed -i "/graphic = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GUI\";/" "$VARS_FILE"
sed -i "/video = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GPU\";/" "$VARS_FILE"
sed -i "/ollama = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$AI_VAL\";/" "$VARS_FILE"

# Base
sed -i "s/video = \".*\";/video = \"$GPU\";/" "$BASE_FILE"
sed -i "s/graphic = \".*\";/graphic = \"$GUI\";/" "$BASE_FILE"
sed -i "s/desktop = \".*\";/desktop = \"$DESKTOP\";/" "$BASE_FILE"
sed -i "s/ollama = \".*\";/ollama = \"$AI_VAL\";/" "$BASE_FILE"
sed -i "s/@USERNAME@/$USERNAME/g" "$BASE_FILE"

# User
sed -i "s/@USERNAME@/$USERNAME/g" "$USER_FILE"
sed -i "s/@PASSWORD@/$PASSWORD/g" "$USER_FILE"
sed -i "s/@FULLNAME@/$FULLNAME/g" "$USER_FILE"

# Hostname
if grep -q "networking.hostName" "$CONFIG_FILE"; then
    sed -i "s/networking.hostName = \".*\";/networking.hostName = \"$HOSTNAME\";/" "$CONFIG_FILE"
else
    sed -i "/^}/i \  networking.hostName = \"$HOSTNAME\";" "$CONFIG_FILE"
fi

# 7. Installation
log_step "Starting nixos-install..."
nixos-install --root /mnt

log_success "NixOS installed successfully! You can now reboot."
