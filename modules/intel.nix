{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.video == "intel") {

  boot.initrd.kernelModules = [ "i915" ];
  boot.initrd.kernelModules = [ "xe" ]; 


  services.xserver.videoDrivers = [ "modesetting" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      intel-compute-runtime
      vulkan-loader
      vulkan-intel
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
      vulkan-intel
    ];
  };


  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };


  environment.systemPackages = with pkgs; [
    intel-gpu-tools
    libva-utils
    clinfo
  ];
}
