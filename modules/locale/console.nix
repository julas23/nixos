# Console Configuration
# Handles virtual console keymap and font

{ config, pkgs, ... }:

let
  cfg = config.system.config.locale.keyboard;
in

{
  # Console keymap
  console = {
    keyMap = cfg.console;
    
    # Optional: Use a better console font
    font = "Lat2-Terminus16";
    packages = with pkgs; [ terminus_font ];
  };
}
