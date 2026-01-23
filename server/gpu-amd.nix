cat > ~/nixos-config/modules/gpu-amd.nix << 'EOF'
{ config, pkgs, ... }:

{
  # Drivers AMD
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amdvlk
      rocmPackages.llvm
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
  
  # ROCm para computação
  hardware.rocm = {
    enable = true;
    package = pkgs.rocmPackages.clr;
  };
  
  # Vulkan
  hardware.graphics.extraPackages = with pkgs; [
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
  ];
  
  # Monitoramento GPU
  environment.systemPackages = with pkgs; [
    rocm-smi
    radeontop
    clinfo
  ];
}
EOF
