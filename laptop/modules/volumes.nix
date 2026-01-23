{ config, lib, pkgs, ... }:

let
  enabledMounts = config.install.system.enabledMounts;
in

{
  fileSystems = lib.mkMerge [

    (lib.mkIf (builtins.elem "nfs" enabledMounts) {
      "/mnt/nfs" = {
        device = "192.168.0.3:/mnt/DATA";
        fsType = "nfs";
        neededForBoot = false;
        options = [ "noatime" "nolock" "nofail" ];
      };
    })

    (lib.mkIf (builtins.elem "nvm" enabledMounts) {
      "/mnt/nvm" = {
        device = "/dev/disk/by-uuid/467b51a8-84c3-454b-a7fd-22ca58002640";
        fsType = "ext4";
        neededForBoot = false;
        options = [ "noatime" "nofail" ];
      };
    })

    (lib.mkIf (builtins.elem "usb" enabledMounts) {
      "/mnt/usb" = {
        device = "/dev/disk/by-uuid/4563e7ad-5801-4f98-b795-21f85cb6807c";
        fsType = "ext4";
        neededForBoot = false;
        options = [ "noatime" "nofail" ];
      };
    })

    (lib.mkIf (builtins.elem "ssd" enabledMounts) {
      "/mnt/ssd" = {
        device = "/dev/disk/by-uuid/SEU-UUID-AQUI";
        fsType = "ext4";
        neededForBoot = false;
        options = [ "noatime" "nofail" ];
      };
    })
  ];
}
