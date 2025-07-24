{ config, lib, pkgs, ... }:

let
  options.steam.enable = lib.mkEnableOption "Enable Steam";
in

{

  imports = [
    ./packages.nix
    ./fonts.nix
    ./vars.nix
    ./ollama.nix

    ./amdgpu.nix
    ./nvidia.nix

    ./wayland.nix
    ./xorg.nix

    ./gnome.nix
    ./hyprland.nix
    ./i3.nix
    ./mate.nix
    ./xfce.nix

    ./hp.nix
    ./ryzen.nix
    ./think.nix

    ./juliano.nix
    ./normaluser.nix

    ./locale-br.nix
    ./locale-pt.nix
    ./locale-us.nix 
  ];

  install.system = {
    video = "nvidia";
    host = "ryzen";
    graphic = "xorg";
    desktop = "i3";
    user = "juliano";
    locale = "us";
    mount = "S";
    ollama = "S";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "hid-corsair-void" ];
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.steam-hardware.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8"];
  networking.search = [ "home.local" ];
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 11434  8080  22 ];
  };

  security.rtkit.enable = true;
  services.flatpak.enable = true;
  services.libinput.enable = true;
  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.cron.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.blueman.enable = true;
  services.journald.extraConfig = '' Storage=persistent '';
  services.xserver.desktopManager.plasma5.enable = false;

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  hardware.sane = {
    enable = true;
    brscan5 = { enable = true; };
  };

  services.printing.drivers = with pkgs; [
    brlaser
    mfcl3770cdwlpr
    mfcl3770cdwcupswrapper
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.printing.enable = true;

  fileSystems."/mnt/nfs" = {
    device = "192.168.0.3:/mnt/dt";
    fsType = "nfs";
    options = [ "noatime" "nolock" "_netdev" ];
    neededForBoot = false;
  };

#  fileSystems."/mnt/usb" = {
#    device = "/dev/sda1";
#    fsType = "nfs";
#    options = [ "noatime" "nolock" "_netdev" ];
#    neededForBoot = false;
#  };

  system.stateVersion = "25.05";

}
