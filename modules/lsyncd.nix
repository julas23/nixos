{ config, pkgs, ... }:

{
  # 1. Definição dos Arquivos de Configuração no /etc/lsyncd/
  environment.etc = {
    "lsyncd/lsyncd.conf.lua".text = ''
      settings {
          logfile = "/var/log/lsyncd/lsyncd.log",
          statusFile = "/var/log/lsyncd/lsyncd.status",
          maxProcesses = 4,
          insist = true,
          statusInterval = 60,
          nodaemon = true  -- Ajustado para true para funcionar melhor com o systemd
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
              source    = "/mnt/WARM/",
              target    = "/mnt/COLD/",
              excludeFrom = "/etc/lsyncd/lsyncd.exclude",
              rsync     = {
                  archive  = true,
                  compress = false,
                  update   = true,
                  verbose  = true,
                  bwlimit  = 10000,
                  _extra   = {
                      "--include-from=/etc/lsyncd/lsyncd.include",
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
      /.cache/
      /.local/share/Steam/steamapps
      /.local/state
      /.local/lib
      /.local/cache
    '';

    "lsyncd/lsyncd.include".text = ''
      /.aliasrc
      /.bashrc
      /.zshrc
      /.gitconfig
    '';
  };

  # 2. Configuração do Serviço Systemd
  systemd.services.lsyncd = {
    description = "Lsyncd live syncing daemon";
    after = [ "network.target" "local-fs.target" "mnt-COLD.mount" "mnt-WARM.mount" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.lsyncd}/bin/lsyncd -nodaemon /etc/lsyncd/lsyncd.conf.lua";
      Restart = "on-failure";
      RestartSec = "15s";
      
      # Garante que os logs possam ser escritos
      LogsDirectory = "lsyncd";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  environment.systemPackages = [ pkgs.lsyncd ];
}
