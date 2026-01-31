{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.video == "amdgpu") {

  boot.kernelParams = [ "iommu=pt" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.enable = true;
  hardware.amdgpu.opencl.enable = true;
  hardware.enableRedistributableFirmware = true;

#  hardware.rocm = {
#    enable = true;
#    package = pkgs.rocmPackages.clr;
#  };

  hardware.graphics.extraPackages = with pkgs; [
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
  ];

  environment.systemPackages = with pkgs; [
    #rocm-smi
    radeontop
    clinfo
    libva-utils
  ];
}
