{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.services;
in
{
  config = lib.mkIf (cfg.claude.enable or false) {
    environment.systemPackages = with pkgs; [
      claude-code
    ];
  };
}
