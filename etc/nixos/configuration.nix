{ config, lib, pkgs, ... }:

let
  PackageList = import ./packages.nix pkgs;
  InsTarget = "--";
  TargetModule = import ./${InsTarget}.nix;
  options.steam.enable = lib.mkEnableOption "Enable Steam";
in
{
  imports = [ ./hardware-configuration.nix TargetModule ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "hid-corsair-void" ];
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8"];
  networking.search = [ "home.local" ];

  fileSystems."/mnt/nfs" = {
    device = "192.168.0.3:/mnt/dt";
    fsType = "nfs";
    options = [ "noatime" "nolock" "_netdev" "nofail" ];
    neededForBoot = false;
  };

  time.timeZone = "Europe/Lisbon";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [ linux-firmware ];

  hardware.sane = {
    enable = true;
    brscan5 = {
      enable = true;
    };
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

  security.rtkit.enable = true;
  services.libinput.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.pulseaudio.enable = false;
  services.printing.enable = true;
  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.cron.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.journald.extraConfig = '' Storage=persistent '';
  services.xserver.desktopManager.plasma5.enable = false;

  services.xserver.xkb = {
      layout = "us";
      variant = "alt-intl";
    };
  console.keyMap = "us";

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.juliano = {
    isSystemUser = true;
    uid = 369;
    group = "juliano";
    extraGroups = [ "networkmanager" "wheel" "users" "video" "input" "plugdev" "lp" "scanner" "openrazer" ];
    home = "/home/juliano";
    homeMode = "755";
    useDefaultShell = true;
    initialPassword = "jas2305X";
    description = "Juliano Alves dos Santos";
  };
  security.sudo.wheelNeedsPassword = false;
  users.groups.juliano = {
    gid = 369;
  };

  fonts.packages = with pkgs; [ font-awesome 
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];

  environment.systemPackages = PackageList;
  system.stateVersion = "25.05";
}
