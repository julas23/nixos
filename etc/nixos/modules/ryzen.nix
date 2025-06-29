{ config, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  networking.hostName = "ryzen";

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  boot.initrd.kernelModules = [ "nvidia_modeset" "nvidia" "nvidia_uvm" "nvidia_drm" ];

 environment.systemPackages = with pkgs; [ gnome-tweaks gnome-console nautilus desktop-file-utils xdotool wmctrl whisper-cpp python3 python3Packages.pip python3Packages.torchWithCuda python3Packages.transformers python3Packages.accelerate python3Packages.datasets ];

  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
