# modules/services/claude.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.services.claude or {};
in
{
  config = lib.mkMerge [

    # Claude Code via nixpkgs (estável)
    (lib.mkIf (cfg.code.enable or false) {
      environment.systemPackages = [ pkgs.claude-code ];
    })

  ];
}
