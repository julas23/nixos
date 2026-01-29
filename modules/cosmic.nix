{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "cosmic") {
  # Enable COSMIC Desktop and Greeter
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # Essential Core Services for COSMIC
  services.dbus.enable = true;
  security.polkit.enable = true;
  services.system76-scheduler.enable = true;

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

  # AutoLogin (Disabled by default, but configured)
  services.displayManager.autoLogin = {
    enable = false;
    user = "@USERNAME@"; # Updated to use the installer placeholder
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
    cosmic-settings-daemon # Ensure the daemon is available
  ];

  # D-Bus integration for COSMIC settings
  services.dbus.packages = [ pkgs.cosmic-settings-daemon ];

  # Polkit rule to allow cosmic-settings-daemon to perform system actions
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id.indexOf("org.freedesktop.consolekit") == 0 ||
           action.id.indexOf("org.freedesktop.hostname") == 0 ||
           action.id.indexOf("org.freedesktop.login1") == 0 ||
           action.id.indexOf("org.freedesktop.NetworkManager") == 0 ||
           action.id.indexOf("org.freedesktop.upower") == 0) &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
}
