{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.video == "intel") {
  # 1. Drivers de Kernel
  boot.initrd.kernelModules = [ "i915" ];

  # 2. Configuração de Vídeo (X11)
  services.xserver.videoDrivers = [ "modesetting" ];

  # 3. Aceleração de Hardware (VA-API / QuickSync)
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

  # 4. Variáveis de Ambiente
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # 5. Ferramentas de Monitoramento
  environment.systemPackages = with pkgs; [
    intel-gpu-tools
    libva-utils
    clinfo
  ];
}
