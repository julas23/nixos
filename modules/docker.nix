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
  
  # Containers essenciais
  virtualisation.oci-containers.backend = "docker";
  
  virtualisation.oci-containers.containers = {
    casaos = {
      image = "casaos/casaos:latest";
      ports = ["80:80"];
      volumes = [
        "/data/casaos:/app/data"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      extraOptions = ["--network=host"];
    };
    
    jellyfin = {
      image = "jellyfin/jellyfin:latest";
      ports = ["8096:8096" "8920:8920"];
      volumes = [
        "/data/jellyfin/config:/config"
        "/data/jellyfin/cache:/cache"
        "/media:/media:ro"
      ];
      extraOptions = [
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
        "--device=/dev/dri/card0:/dev/dri/card0"
      ];
    };
    
    nextcloud = {
      image = "nextcloud:latest";
      ports = ["8080:80"];
      volumes = [
        "/data/nextcloud:/var/www/html"
        "/data/nextcloud-data:/data"
      ];
      environment = {
        POSTGRES_HOST = "localhost";
        POSTGRES_DB = "nextcloud";
        POSTGRES_USER = "nextcloud";
        POSTGRES_PASSWORD = "nextcloud123";
      };
    };
  };
}