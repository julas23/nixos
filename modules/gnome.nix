{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "gnome") {
  # XDG Portal Configuration for GNOME
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "gnome" "gtk" ];
  };

  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.enable = true;
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    desktop-file-utils 
    xdotool 
    wmctrl 
    whisper-cpp 
    hidapi 
    libusb1 
    open-webui
    gnome-tweaks 
    gnome-console 
    nautilus
  ];
}
