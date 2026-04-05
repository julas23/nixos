# Lsyncd Service Configuration
# Live Syncing Daemon - Automated file synchronization between volumes
#
# This module is self-contained: simply uncomment it in configuration.nix
# to enable the full lsyncd service. No other flags required.
#
# To enable:   uncomment ./modules/services/lsyncd.nix in configuration.nix
# To disable:  comment it out again and run nixos-rebuild switch

{ config, lib, pkgs, ... }:
let
  username = config.system.config.user.name;

  # Source and target directories for synchronization
  sourceDir = "/home/${username}/";
  targetDir = "/mnt/DOCK/${username}/";
in
{
  # Lsyncd configuration file
  environment.etc = {
    "lsyncd/lsyncd.conf.lua".text = ''
      settings {
          logfile        = "/var/log/lsyncd/lsyncd.log",
          statusFile     = "/var/log/lsyncd/lsyncd.status",
          maxProcesses   = 4,
          insist         = true,
          statusInterval = 60,
          nodaemon       = true
      }

      -- Only sync if the target volume is mounted
      local function is_mounted(mountpoint)
          local f = io.open("/proc/mounts", "r")
          if not f then return false end
          for line in f:lines() do
              if line:match(mountpoint) then
                  f:close()
                  return true
              end
          end
          f:close()
          return false
      end

      if is_mounted("/mnt/DOCK") then
          sync {
              default.rsync,
              source      = "${sourceDir}",
              target      = "${targetDir}",
              excludeFrom = "/etc/lsyncd/lsyncd.exclude",
              rsync = {
                  archive  = true,
                  update   = true,
                  verbose  = true,
                  _extra   = {
                      "--partial",
                      "--inplace",
                      "--delete",
                      "--chmod=D755,F644"
                  }
              }
          }
      end
    '';

    # Exclude patterns for sync
    "lsyncd/lsyncd.exclude".text = ''
      *.tmp
      *.swp
      *.part
      *.crdownload
      *.lock
      .zcompdump*
      .android/
      .cargo/
      .pki/
      .vscode/
      .local/share/Steam/steamapps/common/
      .local/share/Steam/steamapps/downloading/
      .local/share/Steam/steamapps/temp/
      .local/share/Steam/steamapps/workshop/
      .local/share/Steam/compatibilitytools.d/
      .local/state
      .local/lib
    '';
  };

  # Systemd service
  systemd.services.lsyncd = {
    description = "Lsyncd live syncing daemon";
    after       = [ "network.target" "local-fs.target" "mnt-DOCK.mount" ];
    wantedBy    = [ "multi-user.target" ];

    # rsync must be in PATH for lsyncd to call it
    path = [ pkgs.rsync ];

    serviceConfig = {
      Type           = "simple";
      ExecStart      = "${pkgs.lsyncd}/bin/lsyncd -nodaemon /etc/lsyncd/lsyncd.conf.lua";
      Restart        = "on-failure";
      RestartSec     = "15s";
      LogsDirectory  = "lsyncd";
      StandardOutput = "journal";
      StandardError  = "journal";
    };
  };

  # Required packages
  environment.systemPackages = with pkgs; [
    lsyncd
    rsync
  ];
}
