{ config, pkgs, ... }:

let
  PackageList = import ./packages.nix pkgs;
  gpuVendor = "amdgpu";
  gpuModule = import ./${gpuVendor}.nix;
in
{
  imports = [ ./hardware-configuration.nix gpuModule ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  networking.hostName = "hp";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8"];
  networking.search = [ "home.local" ];

  fileSystems."/mnt/nfs" = {
    device = "192.168.0.3:/mnt/dt";
    fsType = "nfs";
    options = [ "defaults" "noatime" "nolock" "_netdev" ];
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
  hardware.pulseaudio.enable = false;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [ linux-firmware ];

  programs.firefox.enable = true;
  programs.hyprland.enable = true;
  security.rtkit.enable = true;
  services.printing.enable = true;
  services.openssh.enable = true;
  services.xserver.desktopManager.plasma5.enable = false;
  services.fstrim.enable = true;
  services.cron.enable = true;
  services.journald.extraConfig = '' Storage=persistent '';
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.xserver.enable = true;
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      Users.MinimumUid = 369;
      Users.MaximumUid = 369;
    };
  };
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
    extraGroups = [ "networkmanager" "wheel" "users" "video" "input" "plugdev" ];
    home = "/home/juliano";
    homeMode = "755";
    useDefaultShell = true;
    initialPassword = "jas2305X";
    description = "Juliano Alves dos Santos";
  };
  users.groups.juliano = {
    gid = 369;
  };

  fonts.packages = with pkgs; [
    font-awesome
    material-design-icons
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    papirus-icon-theme
    pkgs.adwaita-icon-theme
  ];

  environment.systemPackages = PackageList;
  system.stateVersion = "24.11";
}
