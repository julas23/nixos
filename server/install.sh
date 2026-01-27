#!/usr/bin/env bash
# install-nixos-ai-server.sh
# Instalação automatizada do NixOS 25.11 para servidor AI com configuração específica

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configurações do sistema
SYSTEM_DISK="/dev/sda"  # SSD 120GB SATA
MODEL_DISKS=()          # NVMe para modelos
DATA_DISKS=()           # HDDs e outros NVMe para dados
HOSTNAME="thinkstation-ai"
USERNAME="juliano"
INITIAL_PASSWORD="mudar123"
GIT_REPO="https://github.com/julas23/nixos.git"
CONFIG_DIR="/mnt/etc/nixos"

# Funções de log
log() {
    local level=$1
    local color=$2
    shift 2
    echo -e "${color}[${level}]${NC} $*"
}

log_info() { log "INFO" "$BLUE" "$@"; }
log_success() { log "SUCCESS" "$GREEN" "$@"; }
log_warning() { log "WARNING" "$YELLOW" "$@"; }
log_error() { log "ERROR" "$RED" "$@"; }
log_step() { log "STEP" "$CYAN" "$@"; }
log_debug() { log "DEBUG" "$MAGENTA" "$@"; }

# Detectar discos automaticamente
detect_disks() {
    log_step "Detectando discos disponíveis..."
    
    # Listar todos os discos
    echo "Discos disponíveis:"
    lsblk -d -o NAME,SIZE,MODEL,TYPE | grep -v "loop\|rom"
    
    # Sistema: primeiro SSD SATA de ~120GB
    local ssd=$(lsblk -d -o NAME,SIZE,MODEL | grep -i "ssd" | grep "120G" | head -1 | awk '{print "/dev/"$1}')
    if [[ -n "$ssd" ]]; then
        SYSTEM_DISK="$ssd"
        log_info "Detectado SSD do sistema: $SYSTEM_DISK"
    fi
    
    # NVMe para modelos (primeiros NVMe)
    MODEL_DISKS=($(lsblk -d -o NAME | grep "^nvme" | head -2 | sed 's/^/\/dev\//'))
    
    # HDDs para dados
    DATA_DISKS=($(lsblk -d -o NAME,SIZE,MODEL | grep -i "hdd\|8\." | awk '{print "/dev/"$1}'))
    
    # NVMe restantes da placa PCIe
    local pcie_nvmes=($(lsblk -d -o NAME | grep "^nvme" | tail -4 | sed 's/^/\/dev\//'))
    DATA_DISKS+=("${pcie_nvmes[@]}")
    
    log_debug "Discos de modelo: ${MODEL_DISKS[*]}"
    log_debug "Discos de dados: ${DATA_DISKS[*]}"
}

# Verificar se é root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script precisa ser executado como root"
        exit 1
    fi
}

# Confirmar instalação
confirm_installation() {
    clear
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║           INSTALAÇÃO DO NIXOS AI SERVER                  ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║ CONFIGURAÇÃO DETECTADA:                                  ║"
    echo "║                                                          ║"
    echo "║  Sistema:      $SYSTEM_DISK (120GB SSD)                  "
    echo "║  Modelos:      ${#MODEL_DISKS[@]} NVMe(s) de 2TB           "
    echo "║  Dados:        ${#DATA_DISKS[@]} disco(s) (HDD + NVMe)     "
    echo "║  Hostname:     $HOSTNAME                                  "
    echo "║  Usuário:      $USERNAME                                  "
    echo "║  Repositório:  $GIT_REPO                                  "
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    
    read -p "Esta configuração está correta? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
        log_warning "Edite as variáveis no início do script para ajustar"
        exit 0
    fi
    
    log_warning "ATENÇÃO: Todos os dados em $SYSTEM_DISK serão destruídos!"
    read -p "Continuar com a instalação? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
        log_error "Instalação cancelada"
        exit 0
    fi
}

# Instalar pré-requisitos no live environment
install_prerequisites() {
    log_step "Instalando pré-requisitos..."
    
    # Configurar canais NixOS 25.11
    nix-channel --add https://nixos.org/channels/nixos-25.11 nixos
    nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
    nix-channel --update
    
    # Instalar ferramentas essenciais
    nix-env -iA nixos.git nixos.curl nixos.parted nixos.gptfdisk \
        nixos.btrfs-progs nixos.lvm2 nixos.mdadm nixos.util-linux
}

# Particionar disco do sistema
partition_system_disk() {
    local disk=$SYSTEM_DISK
    
    log_step "Particionando disco do sistema ($disk)..."
    
    # Limpar partições existentes
    wipefs -a "$disk"
    
    # Criar tabela GPT
    parted -s "$disk" mklabel gpt
    
    # 1. EFI System Partition (512MB)
    parted -s "$disk" mkpart primary fat32 1MiB 513MiB
    parted -s "$disk" set 1 esp on
    
    # 2. Boot Partition (1GB)
    parted -s "$disk" mkpart primary ext4 513MiB 1.5GiB
    parted -s "$disk" set 2 boot on
    
    # 3. Root Partition (30GB)
    parted -s "$disk" mkpart primary ext4 1.5GiB 31.5GiB
    
    # 4. Swap (8GB)
    parted -s "$disk" mkpart primary linux-swap 31.5GiB 39.5GiB
    
    # 5. Nix Store (restante ~80GB)
    parted -s "$disk" mkpart primary ext4 39.5GiB 100%
    
    sync
    sleep 2
    
    log_info "Partições do sistema criadas:"
    parted -s "$disk" print
}

# Formatar partições do sistema
format_system_partitions() {
    log_step "Formatando partições do sistema..."
    
    # EFI (FAT32)
    mkfs.fat -F 32 -n EFI "${SYSTEM_DISK}p1"
    
    # Boot (ext4)
    mkfs.ext4 -L BOOT "${SYSTEM_DISK}p2"
    
    # Root (ext4)
    mkfs.ext4 -L ROOT "${SYSTEM_DISK}p3"
    
    # Swap
    mkswap -L SWAP "${SYSTEM_DISK}p4"
    swapon "${SYSTEM_DISK}p4"
    
    # Nix Store (ext4)
    mkfs.ext4 -L NIXSTORE "${SYSTEM_DISK}p5"
    
    log_success "Partições do sistema formatadas"
}

# Configurar discos de modelo (RAID 0 para performance)
setup_model_disks() {
    if [[ ${#MODEL_DISKS[@]} -eq 0 ]]; then
        log_warning "Nenhum disco de modelo detectado"
        return
    fi
    
    log_step "Configurando discos de modelo..."
    
    # Para múltiplos NVMe: RAID 0 para máxima performance
    if [[ ${#MODEL_DISKS[@]} -gt 1 ]]; then
        log_info "Criando RAID 0 para modelos com ${#MODEL_DISKS[@]} NVMe"
        
        # Limpar possíveis configurações RAID antigas
        mdadm --zero-superblock "${MODEL_DISKS[@]}" 2>/dev/null || true
        
        # Criar RAID 0
        mdadm --create /dev/md0 --level=0 --raid-devices=${#MODEL_DISKS[@]} "${MODEL_DISKS[@]}" \
            --force
        
        # Formatar como BTRFS com compressão
        mkfs.btrfs -f -L MODELS /dev/md0
        
        # Montar
        mkdir -p /mnt/models
        mount -o compress=zstd:3,noatime,autodefrag,space_cache=v2 /dev/md0 /mnt/models
        
        # Criar entrada no fstab temporário
        echo "/dev/md0 /models btrfs compress=zstd:3,noatime,autodefrag 0 0" >> /tmp/fstab-models
        
    else
        # Apenas um NVMe
        log_info "Configurando único NVMe para modelos"
        
        parted -s "${MODEL_DISKS[0]}" mklabel gpt
        parted -s "${MODEL_DISKS[0]}" mkpart primary 0% 100%
        
        mkfs.btrfs -f -L MODELS "${MODEL_DISKS[0]}p1"
        
        mkdir -p /mnt/models
        mount -o compress=zstd:3,noatime "${MODEL_DISKS[0]}p1" /mnt/models
        
        echo "LABEL=MODELS /models btrfs compress=zstd:3,noatime 0 0" >> /tmp/fstab-models
    fi
    
    # Criar estrutura de diretórios
    mkdir -p /mnt/models/{stable-diffusion,llm,ollama,cache}
    
    log_success "Discos de modelo configurados em /mnt/models"
}

# Configurar discos de dados (RAID 10 para balance performance/redundancy)
setup_data_disks() {
    if [[ ${#DATA_DISKS[@]} -eq 0 ]]; then
        log_warning "Nenhum disco de dados detectado"
        return
    fi
    
    log_step "Configurando discos de dados..."
    
    # Se tivermos pelo menos 4 discos, usar RAID 10
    if [[ ${#DATA_DISKS[@]} -ge 4 ]]; then
        log_info "Criando RAID 10 para dados com ${#DATA_DISKS[@]} discos"
        
        # Usar os primeiros 4 discos para RAID 10
        local raid_disks=("${DATA_DISKS[@]:0:4}")
        
        # Limpar
        mdadm --zero-superblock "${raid_disks[@]}" 2>/dev/null || true
        
        # Criar RAID 10
        mdadm --create /dev/md1 --level=10 --raid-devices=4 "${raid_disks[@]}" \
            --force
        
        # Formatar como BTRFS
        mkfs.btrfs -f -L DATA /dev/md1
        
        mkdir -p /mnt/data
        mount -o compress=zstd:1,noatime,autodefrag /dev/md1 /mnt/data
        
        echo "/dev/md1 /data btrfs compress=zstd:1,noatime,autodefrag 0 0" >> /tmp/fstab-data
        
        # Configurar discos restantes individualmente
        for i in "${!DATA_DISKS[@]}"; do
            if [[ $i -ge 4 ]]; then
                local disk="${DATA_DISKS[$i]}"
                local mount_point="/data/disk$((i-3))"
                
                parted -s "$disk" mklabel gpt
                parted -s "$disk" mkpart primary 0% 100%
                
                mkfs.ext4 -L "DATA$((i-3))" "${disk}p1"
                
                mkdir -p "/mnt$mount_point"
                mount "${disk}p1" "/mnt$mount_point"
                
                echo "LABEL=DATA$((i-3)) $mount_point ext4 defaults,noatime 0 0" >> /tmp/fstab-data
            fi
        done
        
    else
        # Para menos discos, montar individualmente
        for i in "${!DATA_DISKS[@]}"; do
            local disk="${DATA_DISKS[$i]}"
            
            parted -s "$disk" mklabel gpt
            parted -s "$disk" mkpart primary 0% 100%
            
            mkfs.ext4 -L "DATA$((i+1))" "${disk}p1"
            
            local mount_point="/data/disk$((i+1))"
            mkdir -p "/mnt$mount_point"
            mount "${disk}p1" "/mnt$mount_point"
            
            echo "LABEL=DATA$((i+1)) $mount_point ext4 defaults,noatime 0 0" >> /tmp/fstab-data
        done
    fi
    
    # Criar estrutura de diretórios principal
    mkdir -p /mnt/data/{docker,casaos,jellyfin,nextcloud,stable-diffusion-output,backup,media}
    
    log_success "Discos de dados configurados"
}

# Montar sistema de arquivos
mount_filesystems() {
    log_step "Montando sistema de arquivos..."
    
    # Montar partições do sistema
    mount "${SYSTEM_DISK}p3" /mnt
    mkdir -p /mnt/boot /mnt/boot/efi /mnt/nix /mnt/var/lib/swap
    
    mount "${SYSTEM_DISK}p2" /mnt/boot
    mount "${SYSTEM_DISK}p1" /mnt/boot/efi
    mount "${SYSTEM_DISK}p5" /mnt/nix
    
    # Configurar swap
    swapon "${SYSTEM_DISK}p4"
    
    log_success "Sistema de arquivos montado"
}

# Clonar e configurar repositório
setup_configuration() {
    log_step "Configurando NixOS..."
    
    # Gerar configuração de hardware básica
    nixos-generate-config --root /mnt
    
    # Clonar repositório de configuração
    if [[ ! -d "/tmp/nixos-config" ]]; then
        git clone "$GIT_REPO" /tmp/nixos-config
    fi
    
    # Verificar estrutura do repositório
    if [[ -d "/tmp/nixos-config/server" ]]; then
        log_info "Usando configurações do diretório server/"
        
        # Copiar toda a estrutura
        cp -r /tmp/nixos-config/server/* "$CONFIG_DIR/"
        
        # Garantir que os diretórios existam
        mkdir -p "$CONFIG_DIR/hardware" "$CONFIG_DIR/modules"
        
    else
        log_warning "Diretório server/ não encontrado no repositório"
        log_info "Criando configuração básica..."
        
        # Criar módulos básicos com base nos seus arquivos originais
        create_basic_configuration
    fi
    
    # Atualizar configuration.nix para incluir módulos necessários
    update_main_configuration
    
    # Adicionar configurações de discos ao hardware-configuration.nix
    update_hardware_configuration
    
    log_success "Configuração do sistema preparada"
}

# Criar configuração básica se o repositório não tiver
create_basic_configuration() {
    log_info "Criando configuração básica..."
    
    mkdir -p "$CONFIG_DIR/modules"
    
    # Criar módulos com base nos seus arquivos originais
    for module in ai-server.nix docker.nix gpu-amd.nix media-server.nix; do
        if [[ -f "/tmp/nixos-config/$module" ]]; then
            cp "/tmp/nixos-config/$module" "$CONFIG_DIR/modules/"
        fi
    done
}

# Atualizar configuration.nix principal
update_main_configuration() {
    local config_file="$CONFIG_DIR/configuration.nix"
    
    log_info "Atualizando configuração principal..."
    
    cat > "$config_file" << 'EOF'
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/gpu-amd.nix
    ./modules/ai-server.nix
    ./modules/docker.nix
  ];

  # Configurações básicas do sistema
  boot.loader = {
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 10;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  networking.hostName = "thinkstation-ai";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false; # Para desenvolvimento

  # Fuso horário e localização
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  # Usuário principal
  users.users.juliano = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "render" ];
    initialPassword = "mudar123";
    shell = pkgs.bash;
  };

  # Sudo sem senha
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Serviços essenciais
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };

  # Nix settings
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://ai.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      ];
      trusted-users = [ "root" "juliano" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    extraOptions = ''
      min-free = ${toString (10 * 1024 * 1024 * 1024)}
      max-free = ${toString (20 * 1024 * 1024 * 1024)}
    '';
  };

  # Otimizações de sistema
  boot.kernelParams = [
    "mitigations=off"
    "processor.max_cstate=1"
    "intel_idle.max_cstate=0"
    "amd_iommu=on"
    "iommu=pt"
    "transparent_hugepage=always"
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
  };

  # Pacotes do sistema
  environment.systemPackages = with pkgs; [
    # Essentials
    vim wget curl git htop btop tmux screen
    # Monitoring
    nvtop radeontop rocm-smi lm_sensors pciutils usbutils
    # Network
    nmap iperf3 netcat-openbsd socat
    # Storage
    btrfs-progs lvm2 mdadm smartmontools ncdu
    # Development
    man-pages man-db cmake gcc gnumake python3
    # AI/ML tools
    ollama python311Packages.torchWithRocm
  ];

  # Variáveis de ambiente
  environment.variables = {
    OLLAMA_MODELS = "/models/ollama";
    TRANSFORMERS_CACHE = "/models/huggingface";
    HF_HOME = "/models/huggingface";
    TORCH_HOME = "/models/torch";
  };

  system.stateVersion = "25.11";
}
EOF
}

# Atualizar hardware-configuration.nix com discos adicionais
update_hardware_configuration() {
    local hw_config="$CONFIG_DIR/hardware-configuration.nix"
    
    log_info "Atualizando configuração de hardware..."
    
    # Adicionar configurações de swap ao arquivo existente
    if grep -q "swapDevices" "$hw_config"; then
        # Substituir seção swapDevices
        sed -i '/swapDevices =/,/];/c\  swapDevices = [ { device = "/dev/disk/by-label/SWAP"; } ];' "$hw_config"
    else
        # Adicionar no final
        echo '  swapDevices = [ { device = "/dev/disk/by-label/SWAP"; } ];' >> "$hw_config"
    fi
    
    # Adicionar file systems para modelos e dados se não existirem
    if ! grep -q "/models" "$hw_config"; then
        cat >> "$hw_config" << 'EOF'

  # Model storage
  fileSystems."/models" = {
    device = "/dev/disk/by-label/MODELS";
    fsType = "btrfs";
    options = [ "compress=zstd:3" "noatime" "autodefrag" "space_cache=v2" ];
  };

  # Data storage
  fileSystems."/data" = {
    device = "/dev/disk/by-label/DATA";
    fsType = "btrfs";
    options = [ "compress=zstd:1" "noatime" "autodefrag" ];
  };
EOF
    fi
}

# Instalar o sistema
install_nixos() {
    log_step "Instalando NixOS..."
    
    # Instalar sistema
    nixos-install --no-root-passwd --show-trace
    
    if [[ $? -eq 0 ]]; then
        log_success "NixOS instalado com sucesso!"
    else
        log_error "Falha na instalação do NixOS"
        exit 1
    fi
}

# Configurar pós-instalação
setup_post_installation() {
    log_step "Configurando pós-instalação..."
    
    # Entrar no chroot para configurações finais
    arch-chroot /mnt /bin/bash << 'CHROOT_EOF'
#!/bin/bash

# Configurar locale
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

# Criar diretórios e permissões
mkdir -p /models/{stable-diffusion,ollama,huggingface,torch,cache}
mkdir -p /data/{docker,casaos,jellyfin,nextcloud,stable-diffusion-output,media,backup}

chown -R juliano:users /data
chown -R juliano:users /models

# Configurar Docker storage
mkdir -p /data/docker
ln -sf /data/docker /var/lib/docker

# Habilitar serviços
systemctl enable docker
systemctl enable ollama
systemctl enable postgresql
systemctl enable sshd

# Adicionar usuário ao grupo docker
usermod -aG docker juliano

# Criar script de inicialização de modelos
cat > /usr/local/bin/init-ai-models << 'SCRIPT_EOF'
#!/bin/bash
# Script para inicializar modelos AI

echo "Iniciando download de modelos AI..."

# Aguardar Ollama iniciar
sleep 10

# Modelos leves para teste
curl -X POST http://localhost:11434/api/pull -d '{"name": "llama3.2:3b"}'
curl -X POST http://localhost:11434/api/pull -d '{"name": "mistral:7b"}'

# Modelos maiores em background
nohup curl -X POST http://localhost:11434/api/pull -d '{"name": "llama3.2:70b"}' &
nohup curl -X POST http://localhost:11434/api/pull -d '{"name": "codellama:34b"}' &

echo "Downloads iniciados em background. Verifique logs em /var/log/ollama-pull*.log"
SCRIPT_EOF

chmod +x /usr/local/bin/init-ai-models

# Criar serviço para inicializar modelos após boot
cat > /etc/systemd/system/init-ai-models.service << 'SERVICE_EOF'
[Unit]
Description=Initialize AI Models
After=network.target ollama.service
Wants=ollama.service
ConditionPathExists=/usr/local/bin/init-ai-models

[Service]
Type=oneshot
ExecStart=/usr/local/bin/init-ai-models
User=juliano
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl enable init-ai-models

echo "Pós-instalação configurada com sucesso!"
CHROOT_EOF
    
    log_success "Pós-instalação configurada"
}

# Finalizar instalação
finalize_installation() {
    log_step "Finalizando instalação..."
    
    # Criar README para o usuário
    cat > /mnt/root/README.txt << 'README_EOF'
╔══════════════════════════════════════════════════════════╗
║                NIXOS AI SERVER INSTALADO                 ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  Credenciais:                                            ║
║    • Usuário: juliano                                    ║
║    • Senha: mudar123 (ALTERE IMEDIATAMENTE!)             ║
║                                                          ║
║  Acesso:                                                 ║
║    • SSH: ssh juliano@thinkstation-ai.local              ║
║    • WebUI Stable Diffusion: http://localhost:7860       ║
║    • Ollama API: http://localhost:11434                  ║
║    • CasaOS: http://localhost:80                         ║
║    • Jellyfin: http://localhost:8096                     ║
║                                                          ║
║  Diretórios:                                             ║
║    • Modelos: /models                                    ║
║    • Dados: /data                                        ║
║    • Configurações: /etc/nixos                           ║
║                                                          ║
║  Comandos úteis:                                         ║
║    • Mudar senha: passwd                                 ║
║    • Reiniciar serviços: sudo systemctl restart ollama   ║
║    • Ver logs: journalctl -u ollama -f                   ║
║    • Atualizar sistema: sudo nixos-rebuild switch        ║
║    • Iniciar modelos: init-ai-models                     ║
║                                                          ║
║  PRÓXIMOS PASSOS:                                        ║
║    1. Reinicie o sistema                                 ║
║    2. Altere a senha do usuário juliano                  ║
║    3. Execute: sudo init-ai-models                       ║
║    4. Configure os serviços web conforme necessário      ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
README_EOF
    
    # Desmontar tudo
    umount -R /mnt 2>/dev/null || true
    
    log_success "=================================================="
    log_success "INSTALAÇÃO COMPLETA!"
    log_success "=================================================="
    log_info "1. Remova a mídia de instalação"
    log_info "2. Reinicie o sistema"
    log_info "3. Siga as instruções em /root/README.txt"
    log_info "4. Acesse via SSH: ssh juliano@thinkstation-ai"
    log_success "=================================================="
}

# Função principal
main() {
    clear
    
    # Verificar root
    check_root
    
    # Detectar discos
    detect_disks
    
    # Confirmar instalação
    confirm_installation
    
    # Instalar pré-requisitos
    install_prerequisites
    
    # Limpar montagens existentes
    umount -R /mnt 2>/dev/null || true
    
    # Particionar disco do sistema
    partition_system_disk
    
    # Formatar partições do sistema
    format_system_partitions
    
    # Montar sistema de arquivos
    mount_filesystems
    
    # Configurar discos de modelo
    setup_model_disks
    
    # Configurar discos de dados
    setup_data_disks
    
    # Configurar sistema
    setup_configuration
    
    # Instalar NixOS
    install_nixos
    
    # Configurar pós-instalação
    setup_post_installation
    
    # Finalizar
    finalize_installation
}

# Tratamento de erros
trap 'log_error "Script interrompido! Estado atual: $BASH_COMMAND"; exit 1' INT TERM
trap 'log_error "Erro na linha $LINENO: $BASH_COMMAND"; exit 1' ERR

# Executar
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi