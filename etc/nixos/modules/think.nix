{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.host == "think") {

  networking.hostName = "think";
}
