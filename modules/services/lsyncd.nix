# Lsyncd Service Configuration
# Live Syncing Daemon - file synchronization

{ config, lib, ... }:

let
  cfg = config.system.config.services.lsyncd;
in

{
  config = lib.mkIf cfg.enable {
    # Lsyncd service
    # TODO: Configure lsyncd settings
    # services.lsyncd.enable = true;
    # services.lsyncd.settings = { ... };
  };
}
