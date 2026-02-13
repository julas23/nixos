# MATE Desktop Environment Configuration
# Traditional desktop environment forked from GNOME 2
# Lightweight, stable, and user-friendly

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.desktop.environment == "mate";
in

{
  config = lib.mkIf enabled {
    # Enable X11
    services.xserver.enable = true;
    
    # Display Manager - LightDM with GTK greeter
    services.xserver.displayManager.lightdm = {
      enable = true;
      greeters.gtk.enable = true;
    };
    
    # MATE Desktop Manager
    services.xserver.desktopManager.mate.enable = true;
    
    # XDG Desktop Portal for better app integration
    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
    
    # GVFS for virtual file systems (trash, network shares, etc.)
    services.gvfs.enable = true;
    
    # Thumbnail support
    services.tumbler.enable = true;
    
    # MATE Core Applications and Components
    environment.systemPackages = with pkgs; [
      # Core MATE applications
      mate.pluma                    # Text editor
      mate.engrampa                 # Archive manager
      mate.atril                    # Document viewer (PDF, etc.)
      mate.eom                      # Image viewer
      mate.mate-calc                # Calculator
      mate.mate-screenshot          # Screenshot tool
      mate.mate-system-monitor      # System monitor
      mate.mate-power-manager       # Power management
      mate.mate-control-center      # Control center
      mate.mate-terminal            # Terminal emulator
      mate.mate-utils               # Utilities (search, dictionary, etc.)
      mate.mate-applets             # Panel applets
      mate.mate-sensors-applet      # Hardware sensors applet
      mate.mate-netbook             # Netbook mode (optional)
      
      # MATE Menu and Panel
      mate.mozo                     # Menu editor
      mate.mate-panel               # Panel
      mate.mate-menus               # Menu system
      
      # Caja File Manager Extensions
      mate.caja                     # File manager
      mate.caja-extensions          # All caja extensions
      mate.caja-dropbox             # Dropbox integration
      mate.caja-open-terminal       # Open terminal here
      
      # MATE Themes and Appearance
      mate.mate-themes              # Official MATE themes
      mate.mate-backgrounds         # Wallpapers
      mate.mate-icon-theme          # Icon theme
      mate.mate-icon-theme-faenza   # Faenza icon theme
      
      # MATE Session Management
      mate.mate-session-manager     # Session manager
      mate.mate-settings-daemon     # Settings daemon
      mate.mate-desktop             # Desktop library
      
      # MATE Media
      mate.mate-media               # Volume control and sound preferences
      
      # MATE Notification Daemon
      mate.mate-notification-daemon # Notification system
      
      # MATE Polkit
      mate.mate-polkit              # PolicyKit authentication agent
      
      # Additional useful applications
      desktop-file-utils            # Desktop file utilities
      xdotool                       # X11 automation tool
      wmctrl                        # Window manager control
      
      # GTK themes for better appearance
      gnome-themes-extra            # Additional GTK themes
      gtk-engine-murrine            # Murrine GTK engine
      
      # Fonts
      dejavu_fonts
      liberation_ttf
    ];
    
    # Enable sound support
    hardware.pulseaudio.enable = lib.mkDefault true;
    
    # Enable NetworkManager applet
    programs.nm-applet.enable = true;
    
    # Enable dconf for MATE settings
    programs.dconf.enable = true;
  };
}
