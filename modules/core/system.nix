# System Configuration Module
# Handles system-wide settings like state version

{ config, ... }:

let
  cfg = config.system.config.system;
in

{
  # NixOS state version
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = cfg.stateVersion;
}
