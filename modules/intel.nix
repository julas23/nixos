{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.video == "intel") {
  # 1. Kernel Drivers
  boot.initrd.kernelModules = [ "i915" ];

  # 2. Video Configuration (X11)
  services.xserver.videoDrivers = [ "modesetting" ];

  # 3. Hardware Acceleration (VA-API / QuickSync)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      intel-compute-runtime
      vulkan-loader
      vulkan-intel
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
      vulkan-intel
    ];
  };

  # 4. Environment Variables
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # 5. Monitoring Tools
  environment.systemPackages = with pkgs; [
    intel-gpu-tools
    libva-utils
    clinfo
  ];
}
