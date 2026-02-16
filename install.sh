#!/usr/bin/env bash

# NixOS Automated Installer
# Bootstrap script that sets up the environment and runs the interactive configurator
# Usage: curl -L https://raw.githubusercontent.com/julas23/nixos/refactor/modular-architecture/install.sh | bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Banner
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║           NixOS Automated Installer                       ║"
    echo "║           Modular Architecture Edition                    ║"
    echo "║                                                            ║"
    echo "║           https://github.com/julas23/nixos                ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        log_info "Please run: sudo $0"
        exit 1
    fi
}

# Check internet connectivity
check_internet() {
    log_info "Checking internet connectivity..."
    
    if ping -c 1 8.8.8.8 &> /dev/null; then
        log_success "Internet connection detected"
        return 0
    else
        log_error "No internet connection detected"
        log_warning "Please configure network connection first"
        log_info "You can use: sudo systemctl start wpa_supplicant"
        log_info "Or configure manually with nmtui"
        exit 1
    fi
}

# Disk selection and partitioning
select_disk() {
    log_info "Detecting available disks..."
    echo ""
    
    # List available disks
    mapfile -t DISKS < <(lsblk -d -n -o NAME,SIZE,TYPE,MODEL -e 7,11 | awk '$3=="disk" {print "/dev/"$1, $2, $4}')
    
    if [ ${#DISKS[@]} -eq 0 ]; then
        log_error "No disks found!"
        exit 1
    fi
    
    echo "Available Disks:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "No.  Device          Size       Model"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    for i in "${!DISKS[@]}"; do
        DISK_INFO=(${DISKS[$i]})
        DEVICE="${DISK_INFO[0]}"
        SIZE="${DISK_INFO[1]}"
        MODEL="${DISK_INFO[2]:-Unknown}"
        printf "%-4s %-15s %-10s %s\n" "$((i+1))" "$DEVICE" "$SIZE" "$MODEL"
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Select disk
    while true; do
        read -p "Select disk number for installation (1-${#DISKS[@]}): " DISK_NUM
        
        if [[ "$DISK_NUM" =~ ^[0-9]+$ ]] && [ "$DISK_NUM" -ge 1 ] && [ "$DISK_NUM" -le "${#DISKS[@]}" ]; then
            SELECTED_DISK_INFO=(${DISKS[$((DISK_NUM-1))]})
            DISK="${SELECTED_DISK_INFO[0]}"
            DISK_SIZE="${SELECTED_DISK_INFO[1]}"
            DISK_MODEL="${SELECTED_DISK_INFO[2]:-Unknown}"
            break
        else
            log_error "Invalid selection. Please enter a number between 1 and ${#DISKS[@]}"
        fi
    done
    
    echo ""
    log_info "Selected Disk:"
    echo "  Device: $DISK"
    echo "  Size:   $DISK_SIZE"
    echo "  Model:  $DISK_MODEL"
    echo ""
    
    log_warning "ALL DATA ON THIS DISK WILL BE PERMANENTLY ERASED!"
    echo ""
    read -p "Are you absolutely sure you want to continue? (yes/no): " CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        log_info "Installation cancelled by user"
        exit 0
    fi
    
    log_success "Disk selected: $DISK"
}

# Partition disk
partition_disk() {
    log_info "Partitioning disk $DISK..."
    
    # Unmount if mounted
    umount -R /mnt 2>/dev/null || true
    
    # Wipe disk
    log_info "Wiping disk..."
    wipefs -af "$DISK" || true
    sgdisk --zap-all "$DISK" || true
    
    # Create partitions
    log_info "Creating partitions..."
    
    # Determine partition naming
    if [[ "$DISK" =~ "nvme" ]] || [[ "$DISK" =~ "mmcblk" ]]; then
        PART_PREFIX="${DISK}p"
    else
        PART_PREFIX="${DISK}"
    fi
    
    # Create GPT partition table
    parted "$DISK" --script mklabel gpt
    
    # Create EFI partition (512MB)
    parted "$DISK" --script mkpart ESP fat32 1MiB 513MiB
    parted "$DISK" --script set 1 esp on
    
    # Create root partition (rest of disk)
    parted "$DISK" --script mkpart primary ext4 513MiB 100%
    
    # Wait for partitions to be recognized
    sleep 2
    partprobe "$DISK"
    sleep 2
    
    BOOT_PART="${PART_PREFIX}1"
    ROOT_PART="${PART_PREFIX}2"
    
    log_success "Partitions created:"
    log_info "  Boot: $BOOT_PART (512MB, FAT32)"
    log_info "  Root: $ROOT_PART (remaining, ext4)"
}

# Format partitions
format_partitions() {
    log_info "Formatting partitions..."
    
    # Format boot partition
    log_info "Formatting boot partition ($BOOT_PART) as FAT32..."
    mkfs.fat -F 32 -n BOOT "$BOOT_PART"
    
    # Format root partition
    log_info "Formatting root partition ($ROOT_PART) as ext4..."
    mkfs.ext4 -F -L nixos "$ROOT_PART"
    
    log_success "Partitions formatted successfully"
}

# Mount partitions
mount_partitions() {
    log_info "Mounting partitions..."
    
    # Mount root
    mount "$ROOT_PART" /mnt
    
    # Create boot directory and mount
    mkdir -p /mnt/boot
    mount "$BOOT_PART" /mnt/boot
    
    log_success "Partitions mounted:"
    log_info "  Root: $ROOT_PART -> /mnt"
    log_info "  Boot: $BOOT_PART -> /mnt/boot"
}

# Clone repository
clone_repository() {
    log_info "Cloning NixOS configuration repository..."
    
    # Remove old config if exists
    rm -rf /mnt/etc/nixos
    
    # Clone repository
    git clone -b refactor/modular-architecture https://github.com/julas23/nixos.git /mnt/etc/nixos
    
    log_success "Repository cloned to /mnt/etc/nixos"
}

# Generate hardware configuration
generate_hardware_config() {
    log_info "Generating hardware configuration..."
    
    nixos-generate-config --root /mnt
    
    # Move generated hardware-configuration.nix to the right place
    if [ -f /mnt/etc/nixos/hardware-configuration.nix ]; then
        log_success "Hardware configuration generated"
    else
        log_error "Failed to generate hardware configuration"
        exit 1
    fi
}

# Run interactive configurator
run_configurator() {
    log_info "Starting interactive configuration wizard..."
    echo ""
    log_info "The wizard will guide you through system configuration"
    echo ""
    sleep 2
    
    # Enter nix-shell with python3 and run configurator
    cd /mnt/etc/nixos
    
    nix-shell -p python3 --run "python3 /mnt/etc/nixos/install/configurator.py"
    
    if [ $? -ne 0 ]; then
        log_error "Configuration wizard failed or was cancelled"
        exit 1
    fi
    
    log_success "Configuration completed"
}

# Install NixOS
install_nixos() {
    log_info "Installing NixOS..."
    echo ""
    log_warning "This may take a while depending on your internet connection..."
    echo ""
    
    nixos-install --no-root-passwd
    
    if [ $? -eq 0 ]; then
        log_success "NixOS installed successfully!"
    else
        log_error "NixOS installation failed"
        exit 1
    fi
}

# Set root password
set_root_password() {
    log_info "Setting root password..."
    
    while true; do
        echo ""
        read -sp "Enter root password: " ROOT_PASS
        echo ""
        read -sp "Confirm root password: " ROOT_PASS_CONFIRM
        echo ""
        
        if [ "$ROOT_PASS" == "$ROOT_PASS_CONFIRM" ]; then
            echo "$ROOT_PASS" | nixos-enter --root /mnt -c "passwd root" 2>/dev/null
            log_success "Root password set"
            break
        else
            log_error "Passwords do not match. Please try again."
        fi
    done
}

# Set user password
set_user_password() {
    # Get username from config.nix
    USERNAME=$(awk '/user = \{/,/\}/ {if (/name =/) print}' /mnt/etc/nixos/modules/config.nix | sed 's/.*"\(.*\)".*/\1/')
    
    if [ -z "$USERNAME" ]; then
        log_warning "No username found in configuration, skipping user password setup"
        return
    fi
    
    log_info "Setting password for user: $USERNAME"
    
    while true; do
        echo ""
        read -sp "Enter password for $USERNAME: " USER_PASS
        echo ""
        read -sp "Confirm password for $USERNAME: " USER_PASS_CONFIRM
        echo ""
        
        if [ "$USER_PASS" == "$USER_PASS_CONFIRM" ]; then
            echo "$USER_PASS" | nixos-enter --root /mnt -c "passwd $USERNAME" 2>/dev/null
            log_success "Password set for user $USERNAME"
            break
        else
            log_error "Passwords do not match. Please try again."
        fi
    done
}

# Show completion message
show_completion() {
    echo ""
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║           Installation Complete!                          ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    log_success "NixOS has been successfully installed!"
    echo ""
    log_info "Installation Summary:"
    echo "  • Disk: $DISK"
    echo "  • Boot: $BOOT_PART (mounted at /boot)"
    echo "  • Root: $ROOT_PART (mounted at /)"
    echo "  • Configuration: /mnt/etc/nixos/"
    echo ""
    log_info "Next steps:"
    echo "  1. Review your configuration in /mnt/etc/nixos/modules/config.nix"
    echo "  2. Reboot: reboot"
    echo "  3. Remove installation media"
    echo "  4. Enjoy your new NixOS system!"
    echo ""
    
    read -p "Press Enter to reboot or Ctrl+C to stay in live environment..."
    reboot
}

# Main installation flow
main() {
    show_banner
    
    check_root
    check_internet
    
    log_info "Starting NixOS installation process..."
    echo ""
    
    # Disk operations
    select_disk
    partition_disk
    format_partitions
    mount_partitions
    
    # Configuration
    clone_repository
    generate_hardware_config
    run_configurator
    
    # Installation
    install_nixos
    set_root_password
    set_user_password
    
    # Complete
    show_completion
}

# Run main function
main "$@"
