{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "cosmic")

{
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  environment.sessionVariables = {
    COSMIC_DATA_CONTROL_ENABLED = 1;
    NIXOS_OZONE_WL = "0";
    PYTHONUSERBASE = "$HOME/.local";
    PATH = [
      "$HOME/.local/bin"
      "/data/node/bin"
      "/data/rust/bin"
    ];
  };
  services.system76-scheduler.enable = true;

  xdg.portal.config.common.default = lib.mkForce "gtk;cosmic";

  hardware.graphics.enable =true;
  
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit
  ];

  environment.systemPackages = with pkgs; [
    cosmic-term
    cosmic-store
  ];
}
