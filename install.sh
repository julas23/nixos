#!/usr/bin/env bash
# install.sh - Provisionador Completo NixOS (Disk -> Clone -> Config -> Install)

set -euo pipefail

# Cores
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
echo "   NIXOS PROVISIONER - INSTALAÇÃO COMPLETA        "
echo "=================================================="

# 0. Verificação de Internet
log_step "Verificando conexão com a internet..."
if ! ping -c 1 google.com &> /dev/null; then
    log_error "Sem conexão com a internet! Conecte-se via nmtui ou nmcli antes de continuar."
    exit 1
fi
log_success "Internet OK!"

# 1. Seleção de Disco
log_step "Detectando discos..."
lsblk -p -d -n -o NAME,SIZE,MODEL
echo ""
read -p "Digite o caminho do disco para instalação (ex: /dev/sda ou /dev/nvme0n1): " DISK

if [ ! -b "$DISK" ]; then
    log_error "Disco não encontrado!"
    exit 1
fi

echo -e "${YELLOW}AVISO: Todos os dados em $DISK serão apagados!${NC}"
read -p "Tem certeza? (y/n): " CONFIRM_DISK
if [[ ! $CONFIRM_DISK =~ ^[Yy]$ ]]; then exit 1; fi

# 2. Particionamento Simples (EFI + Root)
log_step "Particionando disco $DISK..."
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary ext4 512MiB 100%

# Definir nomes das partições (lidando com nvme)
if [[ $DISK == *"nvme"* ]]; then
    BOOT_PART="${DISK}p1"
    ROOT_PART="${DISK}p2"
else
    BOOT_PART="${DISK}1"
    ROOT_PART="${DISK}2"
fi

log_step "Formatando partições..."
mkfs.vfat -F 32 -n BOOT "$BOOT_PART"
mkfs.ext4 -L NIXOS "$ROOT_PART"

log_step "Montando partições em /mnt..."
mount /dev/disk/by-label/NIXOS /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot

# 3. Clonagem do Repositório
log_step "Clonando repositório NixOS..."
mkdir -p /mnt/etc
git clone https://github.com/julas23/nixos.git /mnt/etc/nixos

# 4. Geração do Hardware Configuration
log_step "Gerando hardware-configuration.nix..."
nixos-generate-config --root /mnt --no-filesystems # Não sobrescreve o que já temos, apenas gera o hardware
# Movemos para a raiz do repo conforme sua nova estrutura
mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix.bak || true
nixos-generate-config --root /mnt
# Garantimos que ele fique na raiz para ser lido pelo configuration.nix
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix

# 5. Coleta de Informações do Usuário
echo -e "\n${CYAN}--- CONFIGURAÇÃO DO SISTEMA ---${NC}"
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

# 6. Aplicação das Configurações
REPO_DIR="/mnt/etc/nixos"
VARS_FILE="$REPO_DIR/modules/vars.nix"
USER_FILE="$REPO_DIR/modules/user.nix"
BASE_FILE="$REPO_DIR/modules/base.nix"
CONFIG_FILE="$REPO_DIR/configuration.nix"

log_step "Aplicando configurações nos arquivos Nix..."
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
sed -i "s/networking.hostName = \".*\";/networking.hostName = \"$HOSTNAME\";/" "$CONFIG_FILE" || \
sed -i "/^}/i \  networking.hostName = \"$HOSTNAME\";" "$CONFIG_FILE"

# 7. Instalação
log_step "Iniciando nixos-install..."
nixos-install --root /mnt

log_success "NixOS instalado com sucesso! Você já pode reiniciar."
