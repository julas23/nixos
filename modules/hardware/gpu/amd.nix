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
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      
      extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };

    # ROCm support (for compute)
    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
  };
}
