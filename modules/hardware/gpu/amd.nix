# AMD GPU Configuration
# Handles AMD GPU drivers and settings

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.hardware.gpu == "amd";
in

{
  config = lib.mkIf enabled {
    # AMD GPU drivers
    services.xserver.videoDrivers = [ "amdgpu" ];

    # Graphics support
    # RADV (Mesa) is the default Vulkan driver for AMD GPUs
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
