# Docker Service Configuration
# Container runtime

{ config, lib, ... }:

let
  cfg = config.system.config.services.docker;
  username = config.system.config.user.name;
in

{
  config = lib.mkIf cfg.enable {
    # Enable Docker
    virtualisation.docker.enable = true;

    # Add user to docker group
    users.users.${username}.extraGroups = [ "docker" ];

    # Docker daemon configuration
    virtualisation.docker.daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
  };
}
