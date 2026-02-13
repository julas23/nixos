# COSMIC Desktop Environment
# System76's new Rust-based desktop

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "cosmic";
in

{
  config = lib.mkIf enabled {
    # COSMIC desktop
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    # Essential packages
    environment.systemPackages = with pkgs; [
      cosmic-edit
      cosmic-files
      cosmic-term
    ];
  };
}
