# COSMIC Desktop Environment
# System76's new Rust-based desktop with complete application stack

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "cosmic";
in

{
  config = lib.mkIf enabled {
    # COSMIC desktop
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    # XDG Desktop Portal
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
    };

    # Complete COSMIC application stack
    environment.systemPackages = with pkgs; [
      # Core COSMIC applications
      cosmic-edit                       # Text editor
      cosmic-files                      # File manager
      cosmic-term                       # Terminal emulator
      cosmic-store                      # App store
      cosmic-settings                   # Settings application
      cosmic-screenshot                 # Screenshot tool
      cosmic-panel                      # Panel
      cosmic-app-list                   # Application list
      cosmic-launcher                   # Application launcher
      cosmic-workspaces                 # Workspace manager
      cosmic-notifications              # Notification daemon
      cosmic-osd                        # On-screen display
      cosmic-bg                         # Background/wallpaper
      cosmic-greeter                    # Display manager greeter
      cosmic-applets                    # System applets
      cosmic-comp                       # Compositor
      cosmic-session                    # Session manager
      
      # Additional utilities
      desktop-file-utils
      xdg-utils
      
      # Fonts
      dejavu_fonts
      liberation_ttf
      fira-code
      fira-code-symbols
    ];

    # Enable dconf for settings
    programs.dconf.enable = true;
  };
}
