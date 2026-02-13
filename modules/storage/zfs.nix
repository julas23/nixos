# ZFS Configuration
# ZFS filesystem support

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.storage.zfs;
  hostname = config.system.config.system.hostname;
in

{
  config = lib.mkIf cfg.enable {
    # Enable ZFS
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;
    
    # ZFS host ID (required)
    networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" hostname);

    # ZFS services
    services.zfs.autoScrub.enable = true;
    services.zfs.trim.enable = true;

    # ZFS tools
    environment.systemPackages = with pkgs; [
      zfs
    ];
  };
}
