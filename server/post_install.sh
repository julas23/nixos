# Criar configuration.nix principal
cat > ~/nixos-config/configuration.nix << 'EOF'
{ config, pkgs, ... }:

{
  imports = [
    ./hardware/thinkstation.nix
    ./modules/ai-server.nix
    ./modules/gpu-amd.nix
    ./modules/docker.nix
    ./modules/media-server.nix
  ];

  networking.hostName = "thinkstation-ai";

  system.stateVersion = "24.11";
}
EOF

# Criar módulo hardware específico
mkdir -p ~/nixos-config/hardware
cat > ~/nixos-config/hardware/thinkstation.nix << 'EOF'
{ config, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Otimizações de performance
  boot.kernelParams = [
    "mitigations=off"
    "processor.max_cstate=1"
    "intel_idle.max_cstate=0"
    "amd_iommu=on"
    "iommu=pt"
  ];

  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIXSTORE";
    fsType = "ext4";
  };

  fileSystems."/models" = {
    device = "/dev/disk/by-label/MODELS";
    fsType = "btrfs";
    options = [ "compress=zstd:3" "noatime" ];
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-label/DATA";
    fsType = "btrfs";
    options = [ "compress=zstd:1" "noatime" ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
EOF
