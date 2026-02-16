# COSMIC Desktop Environment Configuration
# System76's Rust-based desktop environment built on Wayland

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "cosmic";
in

{
  config = lib.mkIf enabled {
    # 1. Display Manager & Desktop Environment
    # Using cosmic-greeter as the display manager
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;

    # Force the default session to be cosmic
    services.displayManager.defaultSession = "cosmic";

    # 2. Session Hand-off & Bootstrapping
    # This tells the Display Manager which session files (.desktop) are available
    services.displayManager.sessionPackages = [ pkgs.cosmic-session ];

    # Ensure D-Bus is enabled for session communication
    services.dbus.enable = true;

    # 3. XDG Portal Configuration
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-cosmic
        xdg-desktop-portal-gtk
      ];
      config.common.default = [ "cosmic" "gtk" ];
      wlr.enable = true;
    };

    # 4. Core System Services
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
    services.accounts-daemon.enable = true;
    services.system76-scheduler.enable = true;

    # 5. Environment & Session Variables
    # Explicitly defining these to ensure they are present
    environment.sessionVariables = {
      COSMIC_DATA_CONTROL_ENABLED = "1";
      NIXOS_OZONE_WL = "1";
      # Standard XDG paths
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";
    };

    # 6. Package Management
    environment.cosmic.excludePackages = with pkgs; [
      cosmic-edit  # Excluded as per user preference
    ];

    environment.systemPackages = with pkgs; [
      # Core COSMIC Components
      cosmic-icons
      cosmic-session
      cosmic-term
      cosmic-store
      cosmic-bg
      cosmic-osd
      cosmic-idle
      cosmic-comp
      cosmic-randr
      cosmic-panel
      cosmic-files
      cosmic-reader
      cosmic-player
      cosmic-ext-ctl
      cosmic-applets
      cosmic-launcher
      cosmic-protocols
      cosmic-wallpapers
      cosmic-screenshot
      cosmic-ext-tweaks
      cosmic-applibrary
      cosmic-notifications
      cosmic-ext-calculator
      cosmic-workspaces-epoch

      # Utilities and Hooks
      libcosmicAppHook
      cosmic-initial-setup
      cosmic-settings
      cosmic-settings-daemon
      xdg-desktop-portal-cosmic

      # Auth and Schemas
      polkit_gnome
      gsettings-desktop-schemas
      
      # Additional utilities
      desktop-file-utils
      xdg-utils
      
      # Fonts
      dejavu_fonts
      liberation_ttf
      fira-code
      fira-code-symbols
    ];

    # 7. D-Bus Service Activation
    services.dbus.packages = [
      pkgs.cosmic-settings-daemon
      pkgs.cosmic-osd
      pkgs.cosmic-notifications
      pkgs.cosmic-session
    ];

    # 8. Security & Polkit
    security.polkit.enable = true;

    # Polkit Agent - tied to the graphical session
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # Polkit rules for COSMIC
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id.indexOf("org.freedesktop.consolekit") == 0 ||
             action.id.indexOf("org.freedesktop.hostname") == 0 ||
             action.id.indexOf("org.freedesktop.login1") == 0 ||
             action.id.indexOf("org.freedesktop.NetworkManager") == 0 ||
             action.id.indexOf("org.freedesktop.upower") == 0 ||
             action.id.indexOf("org.freedesktop.policykit") == 0 ||
             action.id.indexOf("org.freedesktop.packagekit") == 0 ||
             action.id.indexOf("org.freedesktop.accounts") == 0 ||
             action.id.indexOf("com.system76.CosmicSettings") == 0) &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
    
    # Enable dconf for settings
    programs.dconf.enable = true;
  };
}
