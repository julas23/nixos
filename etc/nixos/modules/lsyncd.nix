{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.lsyncd ];

  systemd.tmpfiles.rules = [ "d /var/log/lsyncd 0777 juliano juliano - -" ];
  systemd.services.lsyncd.path = [ pkgs.rsync ];


  systemd.services.lsyncd = {
    enable = true;
    description = "Live Syncing Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "remote-fs.target" ];
    requires = [ "remote-fs.target" ];
    serviceConfig = {
      ReadWritePaths = "/var/log/lsyncd";
      LogsDirectory = "lsyncd";
      ExecStart = "${pkgs.lsyncd}/bin/lsyncd -nodaemon /etc/lsyncd/lsyncd-config.lua";
      Restart = "on-failure";
      RestartSec = "5s";
      User = "juliano";
      Group = "juliano";
      
      PrivateTmp = true;
      ProtectSystem = "full";
      NoNewPrivileges = true;
    };
  };
}
