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
    initialPassword = "P@$$W0RD_H3R3";
    description = "Juliano Alves dos Santos";
  };

  security.sudo.wheelNeedsPassword = false;
  #users.groups.juliano = { gid = 1000; };
  users.groups.users = { gid = 100; };

  #systemd.user.services.cava = {
    #description = "Cava Audio Visualizer Service";
    #serviceConfig = {
      #ExecStart = "${pkgs.cava}/bin/cava -p %h/.config/cava/cavaconfig";
      #Restart = "always";
      #RestartSec = "1s";
    #};
    #wantedBy = [ "default.target" ];
  #};

  #services.getty.autologinUser = "juliano";

}
