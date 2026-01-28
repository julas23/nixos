#!/usr/bin/env bash
# install.sh - Script de Instalação Interativo NixOS

set -euo pipefail

# Cores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_step() { echo -e "${CYAN}[STEP]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }

clear
echo "=================================================="
echo "   NIXOS INSTALLER - CONFIGURAÇÃO FINAL           "
echo "=================================================="

# 1. Coleta de Informações
read -p "USERNAME: " USERNAME
read -s -p "PASSWORD: " PASSWORD
echo
read -s -p "CONFIRM PASSWORD: " PASSWORD_CONFIRM
echo
if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then echo "Error: Passwords do not match."; exit 1; fi

read -p "FULL NAME: " FULLNAME
read -p "HOSTNAME: " HOSTNAME

echo -e "\nTARGET (Hardware):"
select TARGET in "hp" "think" "ryzen" "server"; do
    if [ -n "$TARGET" ]; then break; fi
done

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
    AI_VAL=$([ "$AI_OPT" == "Yes" ] && echo "S" || echo "N")
    break
done

# 2. Caminhos
REPO_DIR="/mnt/etc/nixos"
VARS_FILE="$REPO_DIR/modules/vars.nix"
USER_FILE="$REPO_DIR/modules/user.nix"
BASE_FILE="$REPO_DIR/modules/base.nix"

echo -e "\n${YELLOW}RESUMO:${NC}"
echo "User: $USERNAME ($FULLNAME)"
echo "Host: $HOSTNAME ($TARGET)"
echo "Graphics: $GPU / $GUI / $DESKTOP"
echo "AI: $AI_VAL"

read -p "Confirmar? (s/n): " CONFIRM
if [[ ! $CONFIRM =~ ^[Ss]$ ]]; then exit 1; fi

# 3. Atualização do vars.nix
log_step "Atualizando $VARS_FILE..."
sed -i "/host = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$TARGET\";/" "$VARS_FILE"
sed -i "/desktop = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$DESKTOP\";/" "$VARS_FILE"
sed -i "/graphic = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GUI\";/" "$VARS_FILE"
sed -i "/video = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GPU\";/" "$VARS_FILE"
sed -i "/ollama = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$AI_VAL\";/" "$VARS_FILE"

# 4. Atualização do user.nix e base.nix (Placeholders)
log_step "Atualizando placeholders em $USER_FILE e $BASE_FILE..."
sed -i "s/@USERNAME@/$USERNAME/g" "$USER_FILE"
sed -i "s/@PASSWORD@/$PASSWORD/g" "$USER_FILE"
sed -i "s/@FULLNAME@/$FULLNAME/g" "$USER_FILE"
sed -i "s/@USERNAME@/$USERNAME/g" "$BASE_FILE"

# 5. Instalação
log_step "Iniciando nixos-install..."
nixos-install --flake "$REPO_DIR#default"

log_success "Instalação finalizada com sucesso!"
