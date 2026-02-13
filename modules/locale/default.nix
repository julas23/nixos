# Locale Module - Main Entry Point
# Imports all locale-related configuration

{ ... }:

{
  imports = [
    ./timezone.nix
    ./i18n.nix
    ./console.nix
    ./xkb.nix
  ];
}
