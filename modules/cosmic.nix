{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "cosmic") {
  # Enable COSMIC Desktop and Greeter
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # XDG Portal Configuration for COSMIC
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-cosmic
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "cosmic" ];
    config.cosmic.default = [ "cosmic" "gtk" ];
    config.cosmic-settings.default = [ "cosmic" ];
  };

  # Essential Core Services for COSMIC
  services.dbus.enable = true;
  services.system76-scheduler.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true; # Often required by cosmic-settings

  # Session Variables
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
    cosmic-panel
    cosmic-launcher
    cosmic-notifications
    cosmic-applets
    cosmic-app-library
    cosmic-settings
    cosmic-settings-daemon
    polkit_gnome # Authentication agent for Polkit
  ];

  # Ensure the Polkit agent starts with the session
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

  # D-Bus integration for COSMIC settings
  services.dbus.packages = [ 
    pkgs.cosmic-settings-daemon 
    pkgs.cosmic-osd
    pkgs.cosmic-notifications
  ];

  # Polkit rule to allow cosmic-settings-daemon to perform system actions
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id.indexOf("org.freedesktop.consolekit") == 0 ||
           action.id.indexOf("org.freedesktop.hostname") == 0 ||
           action.id.indexOf("org.freedesktop.login1") == 0 ||
           action.id.indexOf("org.freedesktop.NetworkManager") == 0 ||
           action.id.indexOf("org.freedesktop.upower") == 0 ||
           action.id.indexOf("org.freedesktop.policykit") == 0 ||
           action.id.indexOf("org.freedesktop.packagekit") == 0) &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
}
