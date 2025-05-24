{ config, pkgs, ... }: {
  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    #driSupport = true;
    #driSupport32Bit = true;
  };
}
