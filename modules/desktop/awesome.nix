# Awesome Window Manager
# Highly configurable, dynamic window manager for X11

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "awesome";
in

{
  config = lib.mkIf enabled {
    # Awesome window manager
    services.xserver.windowManager.awesome.enable = true;

    # Display manager
    services.xserver.displayManager.lightdm.enable = true;

    # Essential packages for Awesome
    environment.systemPackages = with pkgs; [
      rofi
      feh  # wallpaper
      picom  # compositor
      dunst  # notifications
      alacritty
      scrot  # screenshot
    ];
  };
}
