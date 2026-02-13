# Nix Configuration Module
# Handles Nix daemon settings, flakes, and garbage collection

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.nix;
in

{
  nix = {
    # Enable flakes and nix command
    settings = {
      experimental-features = lib.mkIf cfg.flakes [ "nix-command" "flakes" ];
      auto-optimise-store = cfg.autoOptimiseStore;
    };

    # Garbage collection
    gc = lib.mkIf cfg.gc.enable {
      automatic = true;
      dates = cfg.gc.dates;
      options = cfg.gc.options;
    };

    # Package
    package = pkgs.nixVersions.stable;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
