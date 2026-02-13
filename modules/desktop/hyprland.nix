# Hyprland Window Manager
# Dynamic tiling Wayland compositor

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "hyprland";
in

{
  config = lib.mkIf enabled {
    # Hyprland
    programs.hyprland.enable = true;

    # Display manager
    services.xserver.displayManager.gdm.enable = true;

    # Essential packages for Hyprland
    environment.systemPackages = with pkgs; [
      waybar
      rofi-wayland
      dunst
      kitty
      swww  # wallpaper
      grim  # screenshot
      slurp  # screen area selection
    ];
  };
}
