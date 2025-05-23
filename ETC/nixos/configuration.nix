{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
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
  #hardware.enableAllFirmware = true;
  hardware.firmware = with pkgs; [ linux-firmware ];

  programs.firefox.enable = true;
  programs.hyprland.enable = true;
  security.rtkit.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
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
    initialPassword = "P4$$W0rd";
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

  environment.systemPackages = with pkgs; [
    #internet
    chromium transmission_4-qt brave

    #development
    dbeaver-bin vscode lens

    #office
    bitwarden sublime4 libreoffice

    #design
    simple-scan brscan5 blender cheese drawio feh freecad gimp gwenview inkscape openscad sweethome3d.application pkgs.gnome-screenshot

    #multimidia
    mpv mpvpaper ardour audacity hydrogen muse musescore rhythmbox rosegarden obs-studio vlc

    #system
    cups gutenprint ghostscript cups-filters foomatic-db foomatic-db-engine
    alsa-firmware alsa-utils arandr networkmanagerapplet
    cronie htop inxi exo eza font-manager freerdp git glxinfo lsof mc micro hyprpaper
    dmidecode lshw neofetch lm_sensors

    #tools
    alacritty foot ansible kitty tmux termite zsh fish
    btop popsicle blueman dolphin nano nettools nfs-utils mlocate p7zip curl 
    rpi-imager rdesktop remmina system-config-printer unrar unzip virtualbox
    pkgs.gnome-calculator noto-fonts wget xdg-utils wl-clipboard clipman xdg-desktop-portal-hyprland

    #opcional
    #simplenote
    #lsyncd
    #polychromatic
    eww
    waybar
    wofi
    #cava
    #conky
    #openrgb
    solaar

    #pending
    # wavebox
    # amd-ucode base base-devel torbrowser xrandr bpytop vulkan-radeon vulkan-tools lib32-glibc lib32-gcc-libs python python-pip
    # ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono ttf-jetbrains-mono-nerd ttf-meslo-nerd ttf-firacode-nerd
  ];
  system.stateVersion = "24.11";
}
