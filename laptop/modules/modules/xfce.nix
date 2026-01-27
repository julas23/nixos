{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "xfce") {

  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.enable = true;
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    desktop-file-utils xdotool wmctrl whisper-cpp hidapi libusb1 open-webui
    xfce.mousepad
    xfce.ristretto
    xfce.xfce4-terminal
    xfce.xfce4-taskmanager
    xfce.xfce4-screenshooter
    xfce.parole
    xfce.xfce4-whiskermenu-plugin
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-weather-plugin
    xfce.xfce4-cpugraph-plugin
    xfce.thunar-archive-plugin
    xfce.thunar-media-tags-plugin
  ];
}
