# Bluetooth Configuration
# Handles Bluetooth hardware and services

{ config, lib, ... }:

let
  cfg = config.system.config.hardware.bluetooth;
in

{
  config = lib.mkIf cfg.enable {
    # Enable Bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    # Bluetooth manager service
    services.blueman.enable = true;
  };
}
