{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.graphic == "wayland") {

  services.displayManager = {
    sddm ={
      enable = true;
      wayland.enable = true;
      settings = {
        Users.MinimumUid = 369;
        Users.MaximumUid = 369;
        XDisplay = { DisplayCommand = "/etc/nixos/modules/Xsetup"; };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    wlogout swaybg wofi
  ];

  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

}
