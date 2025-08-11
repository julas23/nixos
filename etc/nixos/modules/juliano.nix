{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.user == "juliano") {
  users.users.juliano = {
    isSystemUser = true;
    uid = 369;
    group = "juliano";
    extraGroups = [ "networkmanager" "wheel" "users" "video" "input" "plugdev" "lp" "scanner" "openrazer" "mlocate" "renders" "vboxusers" ];
    home = "/home/juliano";
    homeMode = "755";
    useDefaultShell = true;
    initialPassword = "jas2305X";
    description = "Juliano Alves dos Santos";
  };

  security.sudo.wheelNeedsPassword = false;
  users.groups.juliano = {
    gid = 369;
  };

  systemd.user.services.cava = {
    description = "Cava Audio Visualizer Service";
    serviceConfig = {
      ExecStart = "${pkgs.cava}/bin/cava -p %h/.config/cava/cavaconfig";
      Restart = "always";
      RestartSec = "1s";
    };
    wantedBy = [ "default.target" ];
  };

  services.getty.autologinUser = "juliano";

}
