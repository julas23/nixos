{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.video == "vm") {

  boot.initrd.kernelModules = [ "vm" ];
  services.xserver.videoDrivers = [ "vm" ];
  hardware.graphics = { enable = true; };
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.amdgpu.amdgpu_vaapi.enable = true;
  hardware.amdgpu.opencl.enable = true;
  hardware.amdgpu.rocm.enable = true;
  boot.initrd.kernelModules = [ "vm" ];

}
