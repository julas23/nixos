# XFCE Desktop Environment
# Lightweight and traditional desktop

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "xfce";
in

{
  config = lib.mkIf enabled {
    # XFCE desktop
    services.xserver.desktopManager.xfce.enable = true;
    services.xserver.displayManager.lightdm.enable = true;

    # Essential XFCE packages
    environment.systemPackages = with pkgs; [
      xfce.xfce4-whiskermenu-plugin
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-clipman-plugin
    ];
  };
}
