{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "cosmic") {
  # Enable COSMIC Desktop and Greeter
  # Using the official service enable should handle most daemons automatically
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # XDG Portal Configuration for COSMIC
  # Simplified to let the service handle defaults while ensuring GTK fallback
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-cosmic
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "cosmic" "gtk" ];
  };

  # Essential Core Services for COSMIC
  services.dbus.enable = true;
  services.system76-scheduler.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.accounts-daemon.enable = true;

  # Session Variables - Aligned with working reference
  environment.sessionVariables = {
    COSMIC_DATA_CONTROL_ENABLED = "1";
    NIXOS_OZONE_WL = "1";
    PYTHONUSERBASE = "$HOME/.local";
  };

  # Path Adjustments
  environment.variables = {
    PATH = [
      "$HOME/.local/bin"
      "/data/node/bin"
      "/data/rust/bin"
    ];
  };

  # AutoLogin
  services.displayManager.autoLogin = {
    enable = false;
    user = "@USERNAME@";
  };

  # Graphics support
  hardware.graphics.enable = true;

  # COSMIC Packages
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit
  ];

  environment.systemPackages = with pkgs; [
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
    cosmic-ext-applet-minimon
    cosmic-ext-applet-caffeine
    cosmic-ext-applet-privacy-indicator
    cosmic-ext-applet-external-monitor-brightness
    polkit_gnome
    gsettings-desktop-schemas
    
    libcosmicAppHook
    cosmic-initial-setup
    cosmic-settings
    cosmic-settings-daemon
    xdg-desktop-portal-cosmic
  ];

  # D-Bus integration
  services.dbus.packages = [
    pkgs.cosmic-settings-daemon
    pkgs.cosmic-osd
    pkgs.cosmic-notifications
    pkgs.cosmic-session
  ];

  # Fix for Polkit Agent
  security.polkit.enable = true;
  
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
}
