{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.host == "hp") {
  networking.hostName = "hp";
}
