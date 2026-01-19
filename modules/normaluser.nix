{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.user == "normaluser") {

  users.users.normaluser = {
    isSystemUser = true;
    uid = 1000;
    group = "users";
    extraGroups = [ "networkmanager" "wheel" "users" "video" "input" "plugdev" "lp" "scanner" "openrazer" "mlocate" "renders" ];
    home = "/home/normaluser";
    homeMode = "755";
    useDefaultShell = true;
    initialPassword = "nixos-pass";
    description = "Normal user";
  };
  security.sudo.wheelNeedsPassword = false;
  users.groups.normaluser = {
    gid = 1000;
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
}
