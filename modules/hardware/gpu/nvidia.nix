# NVIDIA GPU Configuration
# Handles NVIDIA proprietary drivers and settings

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.hardware.gpu == "nvidia";
in

{
  config = lib.mkIf enabled {
    # NVIDIA drivers
    services.xserver.videoDrivers = [ "nvidia" ];

    # NVIDIA hardware configuration
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;  # Use proprietary driver
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Graphics support
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
