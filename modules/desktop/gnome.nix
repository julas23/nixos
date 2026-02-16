# GNOME Desktop Environment
# Modern and user-friendly desktop with complete application stack

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "gnome";
in

{
  config = lib.mkIf enabled {
    # GNOME desktop
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    # XDG Desktop Portal
    xdg.portal = {
      enable = true;
      config.common.default = "gnome";
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

    # Exclude some default GNOME applications (user can install if needed)
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany        # web browser (use Firefox/Chrome instead)
      geary           # email client (use Thunderbird instead)
    ];

    # Complete GNOME package stack
    environment.systemPackages = with pkgs; [
      # GNOME Core Applications
      gnome.nautilus                    # File manager
      gnome.gnome-terminal              # Terminal
      gnome.gnome-system-monitor        # System monitor
      gnome.gnome-calculator            # Calculator
      gnome.gnome-calendar              # Calendar
      gnome.gnome-contacts              # Contacts
      gnome.gnome-weather               # Weather
      gnome.gnome-clocks                # Clocks
      gnome.gnome-maps                  # Maps
      gnome.gnome-music                 # Music player
      gnome.gnome-photos                # Photo manager
      
      # GNOME Utilities
      gnome.gnome-tweaks                # Tweaks tool
      gnome.gnome-screenshot            # Screenshot tool
      gnome.gnome-disk-utility          # Disk utility
      gnome.gnome-font-viewer           # Font viewer
      gnome.gnome-characters            # Character map
      gnome.gnome-logs                  # System logs viewer
      gnome.gnome-power-manager         # Power manager
      gnome.gnome-software              # Software center
      gnome.gnome-settings-daemon       # Settings daemon
      
      # File Manager Extensions
      gnome.nautilus-python
      gnome.sushi                       # File previewer
      
      # Text Editors
      gnome.gedit                       # Text editor
      gnome-text-editor                 # New GNOME text editor
      
      # Document Viewers
      gnome.evince                      # Document viewer
      gnome.eog                         # Image viewer
      gnome.totem                       # Video player
      
      # Archive Manager
      gnome.file-roller                 # Archive manager
      
      # GNOME Extensions
      gnomeExtensions.appindicator
      gnomeExtensions.dash-to-dock
      gnomeExtensions.dash-to-panel
      gnomeExtensions.user-themes
      gnomeExtensions.vitals
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.blur-my-shell
      gnome-extension-manager           # Extension manager GUI
      
      # GTK Themes and Icons
      gnome-themes-extra
      adwaita-icon-theme
      
      # Additional utilities
      dconf-editor                      # Advanced settings editor
      desktop-file-utils
      
      # Fonts
      dejavu_fonts
      liberation_ttf
      cantarell-fonts
    ];

    # Enable GNOME services
    services.gnome = {
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
      tracker-miners.enable = true;
      tracker.enable = true;
    };

    # Enable dconf
    programs.dconf.enable = true;
  };
}
