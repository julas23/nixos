{ config, pkgs, ... }:

{
  fileSystems."/mnt/DOCK" = {
    device = "/dev/disk/by-uuid/20dcbd68-1c83-4788-aea5-496b78549f29";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  fileSystems."/mnt/NVME" = {
    device = "/dev/disk/by-uuid/49459c35-5985-4f4c-af5b-5eb6221df481";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
}
