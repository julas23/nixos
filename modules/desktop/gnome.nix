# GNOME Desktop Environment
# Modern and user-friendly desktop

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "gnome";
in

{
  config = lib.mkIf enabled {
    # GNOME desktop
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    # Exclude some default GNOME applications
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany  # web browser
      geary     # email client
    ];

    # Essential GNOME packages
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      gnomeExtensions.appindicator
    ];
  };
}
