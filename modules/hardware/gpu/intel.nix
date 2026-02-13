# Intel GPU Configuration
# Handles Intel integrated graphics drivers

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.hardware.gpu == "intel";
in

{
  config = lib.mkIf enabled {
    # Intel GPU drivers
    services.xserver.videoDrivers = [ "intel" ];

    # OpenGL/Vulkan support
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      
      extraPackages = with pkgs; [
        intel-media-driver  # LIBVA_DRIVER_NAME=iHD
        vaapiIntel          # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
        intel-compute-runtime  # OpenCL
      ];
    };

    # Environment variables for better Intel GPU support
    environment.variables = {
      VDPAU_DRIVER = "va_gl";
    };
  };
}
