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

# 2. Caminhos
REPO_DIR="/mnt/etc/nixos"
VARS_FILE="$REPO_DIR/modules/vars.nix"
USER_FILE="$REPO_DIR/modules/user.nix"
BASE_FILE="$REPO_DIR/modules/base.nix"
CONFIG_FILE="$REPO_DIR/configuration.nix"

echo -e "\n${YELLOW}RESUMO:${NC}"
echo "User: $USERNAME ($FULLNAME)"
echo "Host: $HOSTNAME"
echo "Graphics: $GPU / $GUI / $DESKTOP"
echo "AI: $AI_VAL"

read -p "Confirmar? (s/n): " CONFIRM
if [[ ! $CONFIRM =~ ^[Ss]$ ]]; then exit 1; fi

# 3. Atualização do vars.nix
log_step "Atualizando $VARS_FILE..."
sed -i "/desktop = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$DESKTOP\";/" "$VARS_FILE"
sed -i "/graphic = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GUI\";/" "$VARS_FILE"
sed -i "/video = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GPU\";/" "$VARS_FILE"
sed -i "/ollama = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$AI_VAL\";/" "$VARS_FILE"

# 4. Atualização do base.nix (Configurações fixas e placeholders)
log_step "Atualizando $BASE_FILE..."
# Atualiza os valores fixos no bloco install.system do base.nix
sed -i "s/video = \".*\";/video = \"$GPU\";/" "$BASE_FILE"
sed -i "s/graphic = \".*\";/graphic = \"$GUI\";/" "$BASE_FILE"
sed -i "s/desktop = \".*\";/desktop = \"$DESKTOP\";/" "$BASE_FILE"
sed -i "s/ollama = \".*\";/ollama = \"$AI_VAL\";/" "$BASE_FILE"
# Substitui os placeholders de usuário
sed -i "s/@USERNAME@/$USERNAME/g" "$BASE_FILE"

# 5. Atualização do user.nix (Placeholders)
log_step "Atualizando $USER_FILE..."
sed -i "s/@USERNAME@/$USERNAME/g" "$USER_FILE"
sed -i "s/@PASSWORD@/$PASSWORD/g" "$USER_FILE"
sed -i "s/@FULLNAME@/$FULLNAME/g" "$USER_FILE"

# 6. Atualização do Hostname no configuration.nix
log_step "Atualizando Hostname em $CONFIG_FILE..."
# Se não existir networking.hostName, adiciona. Se existir, substitui.
if grep -q "networking.hostName" "$CONFIG_FILE"; then
    sed -i "s/networking.hostName = \".*\";/networking.hostName = \"$HOSTNAME\";/" "$CONFIG_FILE"
else
    # Adiciona antes da última chave de fechamento
    sed -i "/^}/i \  networking.hostName = \"$HOSTNAME\";" "$CONFIG_FILE"
fi

# 7. Instalação
log_step "Iniciando nixos-install..."
nixos-install --root /mnt

log_success "Instalação finalizada com sucesso!"
