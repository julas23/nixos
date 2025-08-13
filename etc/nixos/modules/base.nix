{ config, lib, pkgs, ... }:

let
  options.steam.enable = lib.mkEnableOption "Enable Steam";
in

{
  imports = [
    ./packages.nix
    ./fonts.nix
    ./vars.nix
    ./volumes.nix

    ./amdgpu.nix
    ./nvidia.nix
    ./hp.nix
    ./ryzen.nix
    ./think.nix
    ./wayland.nix
    ./xorg.nix
    ./gnome.nix
    ./hyprland.nix
    ./i3.nix
    ./mate.nix
    ./xfce.nix
    ./juliano.nix
    ./normaluser.nix
    ./locale-br.nix
    ./locale-pt.nix
    ./locale-us.nix
    ./ollama.nix

    #(lib.mkIf (config.install.system.video == "amdgpu") ./amdgpu.nix)
    #(lib.mkIf (config.install.system.video == "nvidia") ./nvidia.nix)
    #(lib.mkIf (config.install.system.host == "hp") ./hp.nix)
    #(lib.mkIf (config.install.system.host == "ryzen") ./ryzen.nix)
    #(lib.mkIf (config.install.system.host == "thinkpad") ./think.nix)
    #(lib.mkIf (config.install.system.graphic == "wayland") ./wayland.nix)
    #(lib.mkIf (config.install.system.graphic == "xorg") ./xorg.nix)
    #(lib.mkIf (config.install.system.desktop == "gnome") ./gnome.nix)
    #(lib.mkIf (config.install.system.desktop == "hyprland") ./hyprland.nix)
    #(lib.mkIf (config.install.system.desktop == "i3") ./i3.nix)
    #(lib.mkIf (config.install.system.desktop == "mate") ./mate.nix)
    #(lib.mkIf (config.install.system.desktop == "xfce") ./xfce.nix)
    #(lib.mkIf (config.install.system.user == "juliano") ./juliano.nix)
    #(lib.mkIf (config.install.system.user == "normaluser") ./normaluser.nix)
    #(lib.mkIf (config.install.system.locale == "br") ./locale-br.nix)
    #(lib.mkIf (config.install.system.locale == "pt") ./locale-pt.nix)
    #(lib.mkIf (config.install.system.locale == "us") ./locale-us.nix)
    #(lib.mkIf (config.install.system.ollama == "S") ./ollama.nix)
    #(lib.mkIf (config.install.system.lsyncd == "S") ./lsyncd.nix)

  ];

  install.system = {
    video = "nvidia";
    host = "ryzen";
    graphic = "xorg";
    desktop = "i3";
    user = "juliano";
    locale = "us";
    ollama = "S";
    enabledMounts = [ "nfs" "nvm" "usb" ];
  };

  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" "wavebox-10.137.11-2" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "hid-corsair-void" ];
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.dragAndDrop = true;
  users.extraGroups.vboxusers.members = [ "juliano" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;

  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.steam-hardware.enable = true;

  nixpkgs.config.allowUnfree = true;
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

  system.stateVersion = "25.05";

}
