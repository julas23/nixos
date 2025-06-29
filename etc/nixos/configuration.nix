{ config, lib, pkgs, ... }:

let
  PackageList = import ./modules/packages.nix pkgs;
  InsTarget = "ryzen";
  TargetModule = import ./modules/${InsTarget}.nix;
  options.steam.enable = lib.mkEnableOption "Enable Steam";
in
{
  imports = [
    ./hardware-configuration.nix
    TargetModule
  ];

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
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 11434  8080  22 ];
  };

  fileSystems."/mnt/nfs" = {
    device = "192.168.0.3:/mnt/dt";
    fsType = "nfs";
    options = [ "noatime" "nolock" "_netdev" ];
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

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  security.rtkit.enable = true;
  services.flatpak.enable = true;
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

  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
  };

  services.open-webui = {
    package = pkgs.open-webui; 
    enable = true;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://192.168.0.18:11434/api";
      OLLAMA_BASE_URL = "http://192.168.0.18:11434";
    };
  };
  systemd.services.open-webui.serviceConfig.ExecStart = lib.mkForce "${pkgs.open-webui}/bin/open-webui serve --host \"0.0.0.0\" --port 8080";

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
    extraGroups = [ "networkmanager" "wheel" "users" "video" "input" "plugdev" "lp" "scanner" "openrazer" "mlocate" "renders" ];
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

  fonts.packages = with pkgs; [ font-awesome noto-fonts pkgs.nerd-fonts._0xproto pkgs.nerd-fonts.droid-sans-mono fira-code-symbols jetbrains-mono ];

  environment.systemPackages = PackageList ;
  system.stateVersion = "25.05";
}
