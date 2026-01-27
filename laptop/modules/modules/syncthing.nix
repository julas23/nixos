{ config, lib, pkgs, ... }:

{
  config = {
    services.syncthing = {
      enable = true;
      user = "juliano";
      dataDir = "/home/juliano/";
      configDir = "/home/juliano/.config/syncthing";
      guiAddress = "192.168.0.18:8384";
      openDefaultPorts = true;    
    };

    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 21027 ];

    systemd.services.syncthing-juliano.wantedBy = [ "multi-user.target" ];
  };
}
