{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Configurações básicas
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "thinkstation";
  networking.networkmanager.enable = true;
  
  # Usuário inicial
  users.users.juliano = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "mudar123";
  };
  
  # Habilitar SSH para acesso remoto
  services.openssh.enable = true;
  
  # Sistema pronto
  system.stateVersion = "24.11";
}
