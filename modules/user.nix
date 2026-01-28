{ config, lib, pkgs, ... }:
lib.mkIf (config.install.system.user == "user") {
  users.users."@USERNAME@" = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    extraGroups = [ "networkmanager" "wheel" "users" "disk" "adbusers" "docker" "video" "libvirtd" "audio" "input" "plugdev" "lp" "scanner" "mlocate" "renders" ];
    home = "/home/@USERNAME@";
    homeMode = "755";
    useDefaultShell = true;
    initialPassword = "@PASSWORD@";
    description = "@FULLNAME@";
  };
  
  security.sudo.wheelNeedsPassword = false;
  users.groups.users = { gid = 100; };
}