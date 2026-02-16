# Wayland Display Server Configuration
# Enables Wayland support and common utilities

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.server == "wayland";
in

{
  config = lib.mkIf enabled {
    # Enable Wayland support in X server (for compatibility)
    services.xserver.enable = true;
    services.displayManager.gdm.wayland = true;

    # Wayland-specific packages
    environment.systemPackages = with pkgs; [
      wayland
      wayland-protocols
      wayland-utils
      wl-clipboard
      wlr-randr
    ];

    # XWayland support
    programs.xwayland.enable = true;

    # Environment variables for Wayland
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";  # Hint Electron apps to use Wayland
      MOZ_ENABLE_WAYLAND = "1";  # Firefox Wayland
    };
  };
}
