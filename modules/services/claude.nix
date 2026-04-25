# modules/services/claude.nix
#
# Claude AI tools — três componentes independentes:
#   claude.code.enable    → Claude Code via nixpkgs stable
#   claude.terminal.enable → Claude Code via flake (updates hourly)
#   claude.desktop.enable  → Claude Desktop via flake da comunidade
#
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.system.config.services.claude or {};
in
{
  config = lib.mkMerge [

    # ── Claude Code (nixpkgs stable) ──────────────────────────────────────
    (lib.mkIf (cfg.code.enable or false) {
      environment.systemPackages = [ pkgs.claude-code ];
    })

    # ── Claude Code (flake — atualizações a cada hora) ────────────────────
    (lib.mkIf (cfg.terminal.enable or false) {
      environment.systemPackages = [
        inputs.claude-code-nix.packages.${pkgs.system}.claude-code
      ];
      # Cache binário para evitar compilação local
      nix.settings = {
        substituters         = lib.mkAfter [ "https://claude-code.cachix.org" ];
        trusted-public-keys  = lib.mkAfter [
          "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
        ];
      };
    })

    # ── Claude Desktop (comunidade — não oficial) ─────────────────────────
    (lib.mkIf (cfg.desktop.enable or false) {
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [ "claude-desktop" ];

      environment.systemPackages = [
        inputs.claude-desktop.packages.${pkgs.system}.claude-desktop
      ];
    })

  ];
}
