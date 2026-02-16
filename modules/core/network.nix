# Network Configuration Module
# Handles NetworkManager, firewall, DNS, and network services

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.network;
  hostname = config.system.config.system.hostname;
in

{
  # Hostname
  networking.hostName = hostname;

  # NetworkManager
  networking.networkmanager = lib.mkIf cfg.networkmanager.enable {
    enable = true;
    # Disable WiFi power saving for better performance
    wifi.powersave = false;
  };

  # DNS Configuration
  # Use Cloudflare and Google DNS for reliability
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  
  # Search domain for local network
  networking.search = [ "home.local" ];

  # Firewall Configuration
  networking.firewall = lib.mkIf cfg.firewall.enable {
    enable = true;
    allowedTCPPorts = cfg.firewall.allowedTCPPorts ++ [
      22    # SSH
      8080  # HTTP alternative
      11434 # Ollama
    ];
    allowedUDPPorts = cfg.firewall.allowedUDPPorts ++ [
      53    # DNS
      67    # DHCP server
      68    # DHCP client
    ];
    # Allow ping for network diagnostics
    allowPing = true;
  };

  # Disable wpa_supplicant if NetworkManager is enabled
  networking.wireless.enable = lib.mkIf cfg.networkmanager.enable (lib.mkForce false);

  # Enable DHCP on all interfaces by default
  networking.useDHCP = lib.mkDefault true;

  # Avahi/mDNS for local network service discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # Security and permissions
  security.rtkit.enable = true;
  security.polkit.enable = true;

  # System services
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault true;
    };
  };

  # GVFS for virtual filesystems (trash, network shares, etc.)
  services.gvfs.enable = true;

  # UDisks2 for automatic disk mounting
  services.udisks2.enable = true;

  # Upower for power management (required for COSMIC and other DEs)
  services.upower.enable = true;

  # Persistent journal storage
  services.journald.extraConfig = ''
    Storage=persistent
  '';

  # Enable fstrim for SSD optimization
  services.fstrim.enable = true;

  # Enable cron for scheduled tasks
  services.cron.enable = true;

  # Systemd user service for Android reverse tethering (gnirehtet)
  systemd.user.services.pixel-bridge = {
    description = "Reverse Tethering for Android (Gnirehtet)";
    serviceConfig = {
      ExecStart = "${pkgs.gnirehtet}/bin/gnirehtet run";
      Restart = "always";
      RestartSec = "5s";
    };
    wantedBy = [ "default.target" ];
  };
}
