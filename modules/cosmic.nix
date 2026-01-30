{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "cosmic") {
  # 1. Core Desktop and Session Management
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # Ensure D-Bus is set up for user sessions
  services.dbus.enable = true;
  
  # 2. XDG Portal & Environment Providers
  # This is critical for bootstrapping the environment variables into the session
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-cosmic
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "cosmic" "gtk" ];
    wlr.enable = true;
  };

  # 3. Essential Core Services
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.accounts-daemon.enable = true;
  services.system76-scheduler.enable = true;

  # 4. Global Environment Setup
  # These help bootstrap the session if the initial login is weak
  environment.sessionVariables = {
    COSMIC_DATA_CONTROL_ENABLED = "1";
    NIXOS_OZONE_WL = "1";
    # Standard XDG paths to ensure consistency
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
  };

  # 5. System Packages
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit
  ];

  environment.systemPackages = with pkgs; [
    # Core Components
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
    dbus-test-runner # Useful for debugging D-Bus
  ];

  # 6. D-Bus & Systemd User Integration
  # Register packages that provide D-Bus services
  services.dbus.packages = [
    pkgs.cosmic-settings-daemon
    pkgs.cosmic-osd
    pkgs.cosmic-notifications
    pkgs.cosmic-session
  ];

  # 7. Security & Polkit
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

  # Broad Polkit rules for COSMIC administration
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

  # 8. Session Bootstrapping Fix
  # Ensure the systemd user manager is aware of the graphical session
  services.xserver.displayManager.sessionPackages = [ pkgs.cosmic-session ];
  
  # 9. User Login Configuration
  services.displayManager.autoLogin = {
    enable = false;
    user = "@USERNAME@";
  };
}
