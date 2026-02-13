# X11 Keyboard Configuration
# Handles X11 keyboard layout, variant, and options

{ config, lib, ... }:

let
  cfg = config.system.config.locale.keyboard;
  graphicsEnabled = config.system.config.graphics.desktop != "none";
in

{
  # X11 keyboard configuration (only if graphics is enabled)
  services.xserver.xkb = lib.mkIf graphicsEnabled {
    layout = cfg.layout;
    variant = cfg.variant;
    options = cfg.options;
  };
}
