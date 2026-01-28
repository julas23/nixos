{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "gnome") {
  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.enable = true;
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    desktop-file-utils xdotool wmctrl whisper-cpp hidapi libusb1 open-webui
    gnome-tweaks gnome-console nautilus
  ];
}
