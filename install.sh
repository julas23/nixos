#!/usr/bin/env bash

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_step() { echo -e "${CYAN}[STEP]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }

clear
echo "=================================================="
echo "   NIXOS INSTALLER - VARS SETUP         "
echo "=================================================="

read -p "USERNAME: " USERNAME
read -s -p "PASSWORD: " PASSWORD
echo
read -s -p "CONFIRM PASSWORD: " PASSWORD_CONFIRM
echo
if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then echo "Error: Password do not match."; exit 1; fi

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

REPO_DIR="/mnt/etc/nixos"
VARS_FILE="$REPO_DIR/modules/common/vars.nix"
USER_FILE="$REPO_DIR/modules/common/user.nix"
BASE_FILE="$REPO_DIR/modules/common/base.nix"

echo -e "\n${YELLOW}RESUMO:${NC}"
echo "User: $USERNAME ($FULLNAME)"
echo "Host: $HOSTNAME ($TARGET)"
echo "Graphics: $GPU / $GUI / $DESKTOP"
echo "AI: $AI_VAL"

read -p "Confirmar? (s/n): " CONFIRM
if [[ ! $CONFIRM =~ ^[Ss]$ ]]; then exit 1; fi

log_step "Atualizando $BASE_FILE..."
sed -i "/host = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$TARGET\";/" "$BASE_FILE"
sed -i "/desktop = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$DESKTOP\";/" "$BASE_FILE"
sed -i "/graphic = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GUI\";/" "$BASE_FILE"
sed -i "/video = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$GPU\";/" "$BASE_FILE"
sed -i "/ollama = lib.mkOption/,/default =/ s/default = \".*\";/default = \"$AI_VAL\";/" "$BASE_FILE"

log_step "Atualizando $USER_FILE..."
sed -i "s/@USERNAME@/$USERNAME/g" "$USER_FILE"
sed -i "s/@PASSWORD@/$PASSWORD/g" "$USER_FILE"
sed -i "s/@FULLNAME@/$FULLNAME/g" "$USER_FILE"

log_step "Atualizando Hostname..."
HOST_FOLDER=$([ "$TARGET" == "server" ] && echo "server" || echo "laptop")
sed -i "s/networking.hostName = \".*\";/networking.hostName = \"$HOSTNAME\";/" "$REPO_DIR/hosts/$HOST_FOLDER/configuration.nix"

log_success "All set!"

log_step "Starting nixos-install..."
nixos-install --flake "$REPO_DIR#$HOST_FOLDER"

log_success "All done!"