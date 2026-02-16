# Lsyncd Service Configuration
# Live Syncing Daemon - Automated file synchronization between volumes

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.services.lsyncd;
  username = config.system.config.user.name;
  
  # Source and target directories for synchronization
  warmDir = "/mnt/WARM/${username}/";
  coldDir = "/mnt/COLD/${username}/";
in

{
  config = lib.mkIf cfg.enable {
    # Lsyncd configuration file
    environment.etc = {
      "lsyncd/lsyncd.conf.lua".text = ''
        settings {
            logfile = "/var/log/lsyncd/lsyncd.log",
            statusFile = "/var/log/lsyncd/lsyncd.status",
            maxProcesses = 4,
            insist = true,
            statusInterval = 60,
            nodaemon = true
        }

        function is_mounted(mountpoint)
            local mount_file = io.open("/proc/mounts", "r")
            if not mount_file then return false end
            for line in mount_file:lines() do
                if line:match(mountpoint) then
                    mount_file:close()
                    return true
                end
            end
            mount_file:close()
            return false
        end

        if is_mounted("/mnt/COLD") then
            sync {
                default.rsync,
                source    = "${warmDir}",
                target    = "${coldDir}",
                excludeFrom = "/etc/lsyncd/lsyncd.exclude",
                rsync     = {
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
        .cache/
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
        .local/cache
      '';
    };

    # Systemd service for lsyncd
    systemd.services.lsyncd = {
      description = "Lsyncd live syncing daemon";
      after = [ "network.target" "local-fs.target" "mnt-COLD.mount" "mnt-WARM.mount" ];
      wantedBy = [ "multi-user.target" ];

      # Critical for lsyncd to find rsync executable in NixOS
      path = [ pkgs.rsync ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.lsyncd}/bin/lsyncd -nodaemon /etc/lsyncd/lsyncd.conf.lua";
        Restart = "on-failure";
        RestartSec = "15s";

        LogsDirectory = "lsyncd";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Install required packages
    environment.systemPackages = with pkgs; [
      lsyncd
      rsync
    ];
  };
}
