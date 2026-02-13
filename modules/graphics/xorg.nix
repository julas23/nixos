# X11 (Xorg) Display Server Configuration
# Enables X11 support

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.server == "xorg";
in

{
  config = lib.mkIf enabled {
    # Enable X11
    services.xserver.enable = true;

    # X11 utilities
    environment.systemPackages = with pkgs; [
      xorg.xrandr
      xorg.xdpyinfo
      xorg.xev
      xclip
      xsel
    ];
  };
}
