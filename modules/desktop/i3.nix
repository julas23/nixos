# i3 Window Manager
# Tiling window manager for X11

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "i3";
in

{
  config = lib.mkIf enabled {
    # i3 window manager
    services.xserver.windowManager.i3.enable = true;

    # Display manager
    services.xserver.displayManager.lightdm.enable = true;

    # Essential packages for i3
    environment.systemPackages = with pkgs; [
      i3status
      i3lock
      i3blocks
      dmenu
      rofi
      feh  # wallpaper
      picom  # compositor
      dunst  # notifications
      alacritty
      scrot  # screenshot
    ];
  };
}
