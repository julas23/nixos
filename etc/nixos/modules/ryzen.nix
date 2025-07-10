{ config, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  networking.hostName = "ryzen";

  hardware.openrazer.enable = true;
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  boot.initrd.kernelModules = [ "nvidia_modeset" "nvidia" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelModules = ["i2c-dev" "ddcci_backlight"];
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="008b", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="007f", MODE="0666"
  '';
 environment.systemPackages = with pkgs; [ gnome-tweaks gnome-console nautilus desktop-file-utils xdotool wmctrl whisper-cpp python3 python3Packages.pip python3Packages.torchWithCuda python3Packages.transformers python3Packages.accelerate python3Packages.datasets openrazer-daemon hidapi libusb1 pipx ];

  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
