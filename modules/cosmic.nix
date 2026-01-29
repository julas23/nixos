{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "cosmic")

{
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.dbus.enable = true;
  security.polkit.enable = true;

  environment.sessionVariables = {
    COSMIC_DATA_CONTROL_ENABLED = 1;
    NIXOS_OZONE_WL = "1";
    PYTHONUSERBASE = "$HOME/.local";
    PATH = [
      "$HOME/.local/bin"
      "/data/node/bin"
      "/data/rust/bin"
    ];
  };
  services.system76-scheduler.enable = true;
  services.displayManager.autoLogin = {
    enable = false;
    user = "juliano";
  };

  hardware.graphics.enable =true;
  
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit
  ];

  environment.systemPackages = with pkgs; [
    cosmic-icons
    cosmic-session
    cosmic-term
    cosmic-store
    cosmic-settings-daemon
  ];

  services.dbus.packages = [ pkgs.cosmic-settings-daemon ];

}
