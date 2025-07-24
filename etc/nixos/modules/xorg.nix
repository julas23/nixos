{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.graphic == "xorg") {

  services.displayManager = {
    sddm ={
      enable = true;
      wayland.enable = false;
      settings = {
        Users.MinimumUid = 369;
        Users.MaximumUid = 369;
        XDisplay = { DisplayCommand = "/etc/nixos/modules/Xsetup"; };
      };
    };
  };
}
