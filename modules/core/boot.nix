# Boot Configuration Module
# Handles bootloader and kernel configuration

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.boot;
in

{
  boot = {
    # Bootloader configuration
    loader = lib.mkMerge [
      (lib.mkIf (cfg.loader == "systemd-boot") {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
        efi.canTouchEfiVariables = true;
        timeout = cfg.timeout;
      })
      
      (lib.mkIf (cfg.loader == "grub") {
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          useOSProber = true;
        };
        efi.canTouchEfiVariables = true;
        timeout = cfg.timeout;
      })
    ];

    # Quiet boot
    kernelParams = lib.optional cfg.quietBoot "quiet";

    # Latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Kernel modules
    initrd.availableKernelModules = [ 
      "xhci_pci" 
      "ahci" 
      "nvme" 
      "usbhid" 
      "usb_storage" 
      "sd_mod" 
    ];
    
    kernelModules = [ "kvm-amd" "kvm-intel" ];
  };
}
