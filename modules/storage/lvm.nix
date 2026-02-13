# LVM Configuration
# Logical Volume Manager support

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.storage.lvm;
in

{
  config = lib.mkIf cfg.enable {
    # Enable LVM in initrd
    boot.initrd.services.lvm.enable = true;

    # LVM tools
    environment.systemPackages = with pkgs; [
      lvm2
    ];
  };
}
