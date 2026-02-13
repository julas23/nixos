# Printing Configuration
# Handles CUPS printing system

{ config, lib, ... }:

let
  cfg = config.system.config.hardware.printing;
in

{
  config = lib.mkIf cfg.enable {
    # Enable CUPS
    services.printing.enable = true;

    # Printer discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
