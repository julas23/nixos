{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.user == "juliano") {
  users.users.juliano = {
    isSystemUser = true;
    uid = 1000;
    group = "users";
    extraGroups = [ "networkmanager" "wheel" "users" "disk" "adbusers" "docker" "video" "libvirtd" "audio" "input" "plugdev" "lp" "mlocate" "renders" ];
    home = "/home/juliano";
    homeMode = "755";
    useDefaultShell = true;
    initialPassword = "jas2305X";
    description = "Juliano Alves dos Santos";
  };

  security.sudo.wheelNeedsPassword = false;
  users.groups.users = { gid = 100; };

}
