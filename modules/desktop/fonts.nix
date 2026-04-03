# Fonts Configuration
# Centralized font management for all desktop environments
# nerdfonts was renamed to nerd-fonts in NixOS 25.11

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.graphics;
  hasDesktop = cfg.desktop != "none";
in

{
  config = lib.mkIf hasDesktop {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        # Base fonts
        dejavu_fonts
        liberation_ttf

        # Unicode and emoji
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji

        # Icon fonts (used by status bars, launchers, etc.)
        font-awesome

        # Nerd Fonts (renamed from 'nerdfonts' in NixOS 25.11)
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.hack
        nerd-fonts.noto
        nerd-fonts.ubuntu
        nerd-fonts.ubuntu-mono
      ];

      fontconfig = {
        defaultFonts = {
          serif     = [ "DejaVu Serif" ];
          sansSerif = [ "DejaVu Sans" ];
          monospace = [ "JetBrainsMono Nerd Font" ];
          emoji     = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
