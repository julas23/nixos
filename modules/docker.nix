{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableNvidia = false;
    daemon.settings = {
      data-root = "/data/docker";
      storage-driver = "btrfs";
      log-driver = "json-file";
      log-opts = {
        max-size = "100m";
        max-file = "3";
      };
    };
  };
}
