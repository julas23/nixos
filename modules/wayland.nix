{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.graphic == "wayland") {

  environment.systemPackages = with pkgs; [
    wlogout swaybg wofi grimblast wlr-randr
  ];

  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

}
