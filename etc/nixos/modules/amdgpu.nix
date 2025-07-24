{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.video == "amdgpu") {
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = { enable = true; };
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  #hardware.amdgpu.amdgpu_vaapi.enable = true;
  hardware.amdgpu.opencl.enable = true;
  #hardware.amdgpu.rocm.enable = true;
}
