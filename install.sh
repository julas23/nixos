#!/usr/bin/env bash
# install.sh - Full NixOS Provisioner (Disk -> Clone -> Config -> Install)

set -euo pipefail

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

log_step() { echo -e "${CYAN}[STEP]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }

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

# 1. Disk Selection with Interactive Menu
log_step "Detecting available disks..."
echo ""

# Get list of disks (excluding loop and rom devices)
mapfile -t DISK_NAMES < <(lsblk -d -n -o NAME -e 7,11)
mapfile -t DISK_SIZES < <(lsblk -d -n -o SIZE -e 7,11)
mapfile -t DISK_TYPES < <(lsblk -d -n -o TYPE -e 7,11)
mapfile -t DISK_MODELS < <(lsblk -d -n -o MODEL -e 7,11)

if [ ${#DISK_NAMES[@]} -eq 0 ]; then
    log_error "No disks found!"
    exit 1
fi

# Display disk information in a table
echo -e "${BOLD}Available Disks:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-4s %-15s %-10s %-8s %-30s\n" "No." "Device" "Size" "Type" "Model"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for i in "${!DISK_NAMES[@]}"; do
    DISK_PATH="/dev/${DISK_NAMES[$i]}"
    DISK_SIZE="${DISK_SIZES[$i]}"
    DISK_TYPE="${DISK_TYPES[$i]}"
    DISK_MODEL="${DISK_MODELS[$i]:-N/A}"
    
    printf "%-4s %-15s %-10s %-8s %-30s\n" "$((i+1))" "$DISK_PATH" "$DISK_SIZE" "$DISK_TYPE" "$DISK_MODEL"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Interactive disk selection
while true; do
    read -p "Select disk number for installation (1-${#DISK_NAMES[@]}): " DISK_NUM
    
    # Validate input
    if [[ "$DISK_NUM" =~ ^[0-9]+$ ]] && [ "$DISK_NUM" -ge 1 ] && [ "$DISK_NUM" -le "${#DISK_NAMES[@]}" ]; then
        DISK_INDEX=$((DISK_NUM - 1))
        DISK="/dev/${DISK_NAMES[$DISK_INDEX]}"
        DISK_SIZE="${DISK_SIZES[$DISK_INDEX]}"
        DISK_MODEL="${DISK_MODELS[$DISK_INDEX]:-N/A}"
        break
    else
        log_error "Invalid selection! Please enter a number between 1 and ${#DISK_NAMES[@]}."
    fi
done

# Confirm disk selection
echo ""
echo -e "${BOLD}Selected Disk:${NC}"
echo "  Device: ${CYAN}$DISK${NC}"
echo "  Size:   ${CYAN}$DISK_SIZE${NC}"
echo "  Model:  ${CYAN}$DISK_MODEL${NC}"
echo ""
log_warning "ALL DATA ON THIS DISK WILL BE PERMANENTLY ERASED!"
echo ""

while true; do
    read -p "Are you absolutely sure you want to continue? (yes/no): " CONFIRM_DISK
    case "$CONFIRM_DISK" in
        yes|YES)
            break
            ;;
        no|NO)
            log_error "Installation cancelled by user."
            exit 1
            ;;
        *)
            log_error "Please type 'yes' or 'no'."
            ;;
    esac
done

# 2. Simple Partitioning (EFI + Root)
log_step "Partitioning disk $DISK..."
# Use wipefs to clean any existing signatures
wipefs -a "$DISK"

parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary ext4 512MiB 100%

# Define partition names (handling nvme)
if [[ $DISK == *"nvme"* ]] || [[ $DISK == *"mmcblk"* ]]; then
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

# Determine legacy locale value for module compatibility
if [[ "$LOCALE_CHOICE" == "pt_BR.UTF-8" ]]; then
    LOCALE_LEGACY="br"
else
    LOCALE_LEGACY="us"
fi

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

# Update install.system block in base.nix with all configuration values
sed -i "s/hostname = \".*\";/hostname = \"$HOSTNAME\";/" "$BASE_FILE"
sed -i "s/username = \".*\";/username = \"$USERNAME\";/" "$BASE_FILE"
sed -i "s/video = \".*\";/video = \"$GPU\";/" "$BASE_FILE"
sed -i "s/graphic = \".*\";/graphic = \"$GUI\";/" "$BASE_FILE"
sed -i "s/desktop = \".*\";/desktop = \"$DESKTOP\";/" "$BASE_FILE"
sed -i "s/locale = \".*\";/locale = \"$LOCALE_LEGACY\";/" "$BASE_FILE"
sed -i "s/localeCode = \".*\";/localeCode = \"$LOCALE_CHOICE\";/" "$BASE_FILE"
sed -i "s|timezone = \".*\";|timezone = \"$TIMEZONE\";|" "$BASE_FILE"
sed -i "s/keymap = \".*\";/keymap = \"$KEYMAP\";/" "$BASE_FILE"
sed -i "s/xkbLayout = \".*\";/xkbLayout = \"$X11_LAYOUT\";/" "$BASE_FILE"
sed -i "s/xkbVariant = \".*\";/xkbVariant = \"$X11_VARIANT\";/" "$BASE_FILE"
sed -i "s/ollama = \".*\";/ollama = \"$AI_VAL\";/" "$BASE_FILE"
sed -i "s/docker = \".*\";/docker = \"$DOCKER_VAL\";/" "$BASE_FILE"

# Update user.nix with username replacement (keeping @USERNAME@ for other references)
sed -i "s/@USERNAME@/$USERNAME/g" "$USER_FILE"
sed -i "s/@PASSWORD@/$USER_PASSWORD/g" "$USER_FILE"
sed -i "s/@FULLNAME@/$FULLNAME/g" "$USER_FILE"

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
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          SYSTEM CONFIGURATION SUMMARY          ║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC} Disk:        ${CYAN}$DISK ($DISK_SIZE)${NC}"
echo -e "${GREEN}║${NC} Hostname:    ${CYAN}$HOSTNAME${NC}"
echo -e "${GREEN}║${NC} Username:    ${CYAN}$USERNAME${NC}"
echo -e "${GREEN}║${NC} Timezone:    ${CYAN}$TIMEZONE${NC}"
echo -e "${GREEN}║${NC} Locale:      ${CYAN}$LOCALE_CHOICE${NC}"
echo -e "${GREEN}║${NC} Keymap:      ${CYAN}$KEYMAP${NC}"
echo -e "${GREEN}║${NC} X11 Layout:  ${CYAN}$X11_LAYOUT ($X11_VARIANT)${NC}"
echo -e "${GREEN}║${NC} GPU:         ${CYAN}$GPU${NC}"
echo -e "${GREEN}║${NC} Graphics:    ${CYAN}$GUI${NC}"
echo -e "${GREEN}║${NC} Desktop:     ${CYAN}$DESKTOP${NC}"
echo -e "${GREEN}║${NC} Docker:      ${CYAN}$DOCKER_OPT${NC}"
echo -e "${GREEN}║${NC} Ollama:      ${CYAN}$AI_OPT${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
read -p "Press Enter to reboot or Ctrl+C to stay in live environment..."
reboot
