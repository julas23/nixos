# XFCE Desktop Environment
# Lightweight and traditional desktop with complete application stack

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "xfce";
in

{
  config = lib.mkIf enabled {
    # XFCE desktop
    services.xserver.desktopManager.xfce.enable = true;
    services.xserver.displayManager.lightdm.enable = true;

    # XDG Desktop Portal
    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # GVFS for virtual file systems
    services.gvfs.enable = true;

    # Thumbnail support
    services.tumbler.enable = true;

    # Complete XFCE package stack
    environment.systemPackages = with pkgs; [
      # Core XFCE components
      xfce.xfce4-panel
      xfce.xfce4-session
      xfce.xfce4-settings
      xfce.xfce4-power-manager
      xfce.xfce4-notifyd
      xfce.xfconf
      xfce.xfdesktop
      xfce.xfwm4
      xfce.xfwm4-themes
      
      # File Manager - Thunar with plugins
      xfce.thunar
      xfce.thunar-volman
      xfce.thunar-archive-plugin
      xfce.thunar-media-tags-plugin
      
      # Panel plugins
      xfce.xfce4-whiskermenu-plugin      # Application menu
      xfce.xfce4-pulseaudio-plugin       # Volume control
      xfce.xfce4-clipman-plugin          # Clipboard manager
      xfce.xfce4-weather-plugin          # Weather
      xfce.xfce4-systemload-plugin       # System load monitor
      xfce.xfce4-netload-plugin          # Network monitor
      xfce.xfce4-cpugraph-plugin         # CPU graph
      xfce.xfce4-diskperf-plugin         # Disk performance
      xfce.xfce4-fsguard-plugin          # Filesystem guard
      xfce.xfce4-genmon-plugin           # Generic monitor
      xfce.xfce4-timer-plugin            # Timer
      xfce.xfce4-datetime-plugin         # Date and time
      xfce.xfce4-battery-plugin          # Battery monitor
      xfce.xfce4-sensors-plugin          # Hardware sensors
      xfce.xfce4-eyes-plugin             # Eyes (fun)
      xfce.xfce4-mpc-plugin              # MPD client
      xfce.xfce4-mount-plugin            # Mount devices
      
      # Core applications
      xfce.xfce4-terminal                # Terminal emulator
      xfce.xfce4-appfinder               # Application finder
      xfce.xfce4-screenshooter           # Screenshot tool
      xfce.xfce4-taskmanager             # Task manager
      xfce.xfce4-screensaver             # Screensaver
      
      # Additional utilities
      xfce.ristretto                     # Image viewer
      xfce.mousepad                      # Text editor
      xfce.parole                        # Media player
      xfce.xfburn                        # CD/DVD burning
      xfce.gigolo                        # Remote filesystem manager
      xfce.orage                         # Calendar
      xfce.xfce4-dict                    # Dictionary
      xfce.xfce4-mixer                   # Audio mixer (if needed)
      
      # Archive support
      xarchiver                          # Archive manager
      
      # Themes and icons
      xfce.xfce4-icon-theme
      gnome-themes-extra
      gtk-engine-murrine
      
      # Desktop utilities
      desktop-file-utils
      xdotool
      wmctrl
      
      # Fonts
      dejavu_fonts
      liberation_ttf
    ];

    # Enable sound support
    hardware.pulseaudio.enable = lib.mkDefault true;

    # Enable NetworkManager applet
    programs.nm-applet.enable = true;

    # Enable dconf for settings
    programs.dconf.enable = true;
  };
}
