# Volume Management Configuration
# Additional volume mounts and bind mounts for data directories

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.storage;
  username = config.system.config.user.name;
in

{
  # External volume mounts
  # These are mounted by UUID for reliability across reboots
  
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

  # Bind mounts for development environments
  # These allow persistent data storage across NixOS rebuilds
  
  # Docker data directory
  fileSystems."/var/lib/docker" = {
    device = "/data/docker";
    options = [ "bind" ];
    noCheck = true;
  };

  # Node.js global packages
  fileSystems."/usr/local/share/npm" = {
    device = "/data/node/share";
    options = [ "bind" "nofail" ];
  };

  # Python user packages
  fileSystems."/home/${username}/.local/lib/python3.13" = {
    device = "/data/python/lib";
    options = [ "bind" "nofail" ];
  };

  # Rust cargo directory
  fileSystems."/home/${username}/.cargo" = {
    device = "/data/rust";
    options = [ "bind" "nofail" ];
  };

  # System activation script to ensure data directories exist
  # This runs on every boot and nixos-rebuild
  system.activationScripts.createDataDirs = {
    text = ''
      # Ensure /data exists and is owned by the user
      mkdir -p /data/docker /data/python /data/node /data/rust
      chown -R ${username}:users /data || true
      chmod -R 755 /data || true
      
      # Fix home directory and .local ownership to prevent root-lockout
      # This is critical because of the Python/Rust bind-mounts
      if [ -d /home/${username} ]; then
        echo "Ensuring ownership for /home/${username}..."
        mkdir -p /home/${username}/.local/lib/python3.13
        mkdir -p /home/${username}/.cargo
        chown -R ${username}:users /home/${username}
      fi
    '';
  };
}
