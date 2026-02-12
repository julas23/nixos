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
# Use wipefs to clean any existing signatures
wipefs -a "$DISK"

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

# Wait for kernel to recognize partitions
sleep 2

log_step "Formatting partitions..."
mkfs.vfat -F 32 -n BOOT "$BOOT_PART"
mkfs.ext4 -L NIXOS "$ROOT_PART"

log_step "Mounting partitions to /mnt..."
# We use /dev/disk/by-label to ensure consistency
mount /dev/disk/by-label/NIXOS /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot

# 3. Repository Cloning
log_step "Cloning NixOS repository..."
mkdir -p /mnt/etc
git clone https://github.com/julas23/nixos.git /mnt/etc/nixos

# 4. Hardware Configuration Generation
log_step "Generating hardware-configuration.nix..."
# nixos-generate-config will detect the mounted partitions and generate the correct UUIDs
nixos-generate-config --root /mnt

# 5. User Information Collection
echo -e "\n${CYAN}=== SYSTEM CONFIGURATION ===${NC}"

# Root Password
echo -e "\n${CYAN}--- ROOT ACCOUNT ---${NC}"
while true; do
    read -s -p "ROOT PASSWORD: " ROOT_PASSWORD
    echo
    read -s -p "CONFIRM ROOT PASSWORD: " ROOT_PASSWORD_CONFIRM
    echo
    if [ "$ROOT_PASSWORD" == "$ROOT_PASSWORD_CONFIRM" ]; then
        break
    else
        log_error "Passwords do not match! Please try again."
    fi
done

# User Account
echo -e "\n${CYAN}--- USER ACCOUNT ---${NC}"
read -p "USERNAME: " USERNAME
while true; do
    read -s -p "USER PASSWORD: " USER_PASSWORD
    echo
    read -s -p "CONFIRM USER PASSWORD: " USER_PASSWORD_CONFIRM
    echo
    if [ "$USER_PASSWORD" == "$USER_PASSWORD_CONFIRM" ]; then
        break
    else
        log_error "Passwords do not match! Please try again."
    fi
done
read -p "FULL NAME: " FULLNAME

# System Identity
echo -e "\n${CYAN}--- SYSTEM IDENTITY ---${NC}"
read -p "HOSTNAME: " HOSTNAME

# Locale and Timezone
echo -e "\n${CYAN}--- LOCALE & TIMEZONE ---${NC}"
echo "Select your TIMEZONE:"
select TIMEZONE in "America/Sao_Paulo" "America/New_York" "America/Chicago" "America/Denver" "America/Los_Angeles" "America/Miami" "Europe/London" "Europe/Paris" "Asia/Tokyo" "Custom"; do
    if [ "$TIMEZONE" == "Custom" ]; then
        read -p "Enter your timezone (e.g., Europe/Berlin): " TIMEZONE
    fi
    if [ -n "$TIMEZONE" ]; then break; fi
done

echo -e "\nSelect your LOCALE:"
select LOCALE_CHOICE in "en_US.UTF-8" "pt_BR.UTF-8" "Custom"; do
    if [ "$LOCALE_CHOICE" == "Custom" ]; then
        read -p "Enter your locale (e.g., de_DE.UTF-8): " LOCALE_CHOICE
    fi
    if [ -n "$LOCALE_CHOICE" ]; then break; fi
done

echo -e "\nSelect your KEYMAP:"
select KEYMAP in "us" "br-abnt2" "uk" "de" "fr" "es" "Custom"; do
    if [ "$KEYMAP" == "Custom" ]; then
        read -p "Enter your keymap (e.g., dvorak): " KEYMAP
    fi
    if [ -n "$KEYMAP" ]; then break; fi
done

echo -e "\nSelect your X11 LAYOUT:"
select X11_LAYOUT in "us" "br" "uk" "de" "fr" "es" "Custom"; do
    if [ "$X11_LAYOUT" == "Custom" ]; then
        read -p "Enter your X11 layout: " X11_LAYOUT
    fi
    if [ -n "$X11_LAYOUT" ]; then break; fi
done

echo -e "\nSelect your X11 VARIANT (or press Enter for none):"
read -p "X11 VARIANT [alt-intl]: " X11_VARIANT
X11_VARIANT=${X11_VARIANT:-alt-intl}

# Hardware Configuration
echo -e "\n${CYAN}--- HARDWARE CONFIGURATION ---${NC}"
echo "GPU (Driver):"
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

# Optional Services
echo -e "\n${CYAN}--- OPTIONAL SERVICES ---${NC}"
echo "Enable Docker?"
select DOCKER_OPT in "Yes" "No"; do
    DOCKER_VAL=$([ "$DOCKER_OPT" == "Yes" ] && echo "Y" || echo "N")
    break
done

echo -e "\nEnable Ollama (AI)?"
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

# Update vars.nix
sed -i "/desktop = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$DESKTOP\";/" "$VARS_FILE"
sed -i "/graphic = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GUI\";/" "$VARS_FILE"
sed -i "/video = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GPU\";/" "$VARS_FILE"
sed -i "/ollama = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$AI_VAL\";/" "$VARS_FILE"

# Update base.nix - system settings
sed -i "s/video = \".*\";/video = \"$GPU\";/" "$BASE_FILE"
sed -i "s/graphic = \".*\";/graphic = \"$GUI\";/" "$BASE_FILE"
sed -i "s/desktop = \".*\";/desktop = \"$DESKTOP\";/" "$BASE_FILE"
sed -i "s/ollama = \".*\";/ollama = \"$AI_VAL\";/" "$BASE_FILE"
sed -i "s/@USERNAME@/$USERNAME/g" "$BASE_FILE"

# Update base.nix - locale settings
sed -i "s|time.timeZone = \".*\";|time.timeZone = \"$TIMEZONE\";|" "$BASE_FILE"
sed -i "s|i18n.defaultLocale = \".*\";|i18n.defaultLocale = \"$LOCALE_CHOICE\";|" "$BASE_FILE"
sed -i "s|console.keyMap = \".*\";|console.keyMap = \"$KEYMAP\";|" "$BASE_FILE"
sed -i "s|layout = \".*\";|layout = \"$X11_LAYOUT\";|" "$BASE_FILE"
sed -i "s|variant = \".*\";|variant = \"$X11_VARIANT\";|" "$BASE_FILE"

# Update base.nix - Docker conditional
if [ "$DOCKER_VAL" == "N" ]; then
    # Comment out Docker-related configurations
    sed -i 's/^  virtualisation.docker.enable = true;/  # virtualisation.docker.enable = true;/' "$BASE_FILE"
    sed -i 's/^  virtualisation.docker.daemon.settings/  # virtualisation.docker.daemon.settings/' "$BASE_FILE"
    sed -i 's/^    data-root = "\/data\/docker";/    # data-root = "\/data\/docker";/' "$BASE_FILE"
    sed -i 's/^  };/  # };/' "$BASE_FILE"
    sed -i '/fileSystems."\/var\/lib\/docker"/,/};/s/^/  # /' "$BASE_FILE"
fi

# Update user.nix
sed -i "s/@USERNAME@/$USERNAME/g" "$USER_FILE"
sed -i "s/@PASSWORD@/$USER_PASSWORD/g" "$USER_FILE"
sed -i "s/@FULLNAME@/$FULLNAME/g" "$USER_FILE"

# Update configuration.nix - hostname
if grep -q "networking.hostName" "$CONFIG_FILE"; then
    sed -i "s/networking.hostName = \".*\";/networking.hostName = \"$HOSTNAME\";/" "$CONFIG_FILE"
else
    # Insert before the last closing brace if not found
    sed -i "/^}/i \  networking.hostName = \"$HOSTNAME\";" "$CONFIG_FILE"
fi

# 7. Create root password configuration script
log_step "Configuring root password..."
cat > /mnt/root-password-setup.sh << EOF
#!/usr/bin/env bash
echo "root:$ROOT_PASSWORD" | chpasswd
EOF
chmod +x /mnt/root-password-setup.sh

# 8. Installation
log_step "Starting nixos-install..."
nixos-install --root /mnt

# 9. Set root password in the new system
log_step "Setting root password..."
nixos-enter --root /mnt -c "/root-password-setup.sh"
rm /mnt/root-password-setup.sh

log_success "NixOS installed successfully! You can now reboot."
echo ""
echo -e "${GREEN}System Summary:${NC}"
echo "  Hostname: $HOSTNAME"
echo "  User: $USERNAME"
echo "  Timezone: $TIMEZONE"
echo "  Locale: $LOCALE_CHOICE"
echo "  Keymap: $KEYMAP"
echo "  GPU: $GPU"
echo "  Desktop: $DESKTOP"
echo "  Docker: $DOCKER_OPT"
echo "  Ollama: $AI_OPT"
echo ""
read -p "Press Enter to reboot or Ctrl+C to stay in live environment..."
reboot
