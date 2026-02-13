# LVM Configuration
# Logical Volume Manager support

{ config, lib, ... }:

let
  cfg = config.system.config.storage.lvm;
in

{
  config = lib.mkIf cfg.enable {
    # Enable LVM
    boot.initrd.lvm.enable = true;

    # LVM tools
    environment.systemPackages = with pkgs; [
      lvm2
    ];
  };
}
