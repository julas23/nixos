# SSH Service Configuration
# OpenSSH server

{ config, lib, ... }:

let
  cfg = config.system.config.services.ssh;
in

{
  config = lib.mkIf cfg.enable {
    # Enable OpenSSH
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = if cfg.permitRootLogin then "yes" else "no";
        PasswordAuthentication = true;
      };
    };

    # Open SSH port in firewall
    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
