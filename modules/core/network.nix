# Network Configuration Module
# Handles NetworkManager and firewall

{ config, lib, ... }:

let
  cfg = config.system.config.network;
  hostname = config.system.config.system.hostname;
in

{
  # Hostname
  networking.hostName = hostname;

  # NetworkManager
  networking.networkmanager.enable = lib.mkIf cfg.networkmanager.enable true;

  # Firewall
  networking.firewall = lib.mkIf cfg.firewall.enable {
    enable = true;
    allowedTCPPorts = cfg.firewall.allowedTCPPorts;
    allowedUDPPorts = cfg.firewall.allowedUDPPorts;
  };

  # Disable wpa_supplicant if NetworkManager is enabled
  networking.wireless.enable = lib.mkIf cfg.networkmanager.enable (lib.mkForce false);

  # Enable DHCP on all interfaces by default
  networking.useDHCP = lib.mkDefault true;
}
