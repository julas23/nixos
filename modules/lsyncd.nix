{ config, pkgs, ... }:

let
  warmDir = "/mnt/WARM/juliano/";
  coldDir = "/mnt/COLD/juliano/";
  
in
{
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

  systemd.services.lsyncd = {
    description = "Lsyncd live syncing daemon";
    after = [ "network.target" "local-fs.target" "mnt-COLD.mount" "mnt-WARM.mount" ];
    wantedBy = [ "multi-user.target" ];

    # Crucial para o lsyncd encontrar o executável do rsync no NixOS
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

  environment.systemPackages = [ pkgs.lsyncd pkgs.rsync ];
}
