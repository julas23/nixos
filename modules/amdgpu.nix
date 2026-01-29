{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.video == "amdgpu") {

  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics.enable = true;
  hardware.amdgpu.opencl.enable = true;

  hardware.opengl = {
    enable = true;
    #driSupport = true;
    #driSupport32Bit = true;
    #extraPackages = with pkgs; [
      #rocmPackages.clr.icd
      #amdvlk
      #rocmPackages.llvm
    #];
    #extraPackages32 = with pkgs; [
    #  driversi686Linux.amdvlk
    #];
  };
  
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
  ];
}
