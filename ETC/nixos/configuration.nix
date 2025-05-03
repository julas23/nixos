{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];

  # Boot UEFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  #Files systems
  fileSystems."/" = {
  device = "/dev/disk/by-uuid/4eae3a7a-0da0-4a69-99f9-4b3a3649a4d9";
  fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/1def3eef-6f07-4e4d-9c47-bd587a6a24bc";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CD4D-9FB5";
    fsType = "vfat";
  };

  # Recursos modernos do Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Usuário Juliano
  users.users.juliano = {
    isNormalUser = true;
    group = "juliano";
    extraGroups = [ "wheel" "networkmanager" "video" "input" "plugdev" ];
    initialPassword = "P@$$w0rd";
  };
  users.groups.juliano = {};

  # Interface gráfica
  programs.hyprland.enable = true;

  # Driver GPU
  #services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.firmware = with pkgs; [ linux-firmware ];

  # Rede e som
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8"];
  networking.search = [ "home.local" ];

  services.pipewire.enable = true;
  services.pipewire.audio.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.jack.enable = true;

  # Serviços adicionais
  services.xserver ={
    enable = true;
    layout = "us";
    xkbVariant = "intl";
    libinput.enable = true;
  };
  services.xserver.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      Users.MinimumUid = 369;
      Users.MaximumUid = 369;
    };
  };
  services.xserver.desktopManager.plasma5.enable = false;
  services.fstrim.enable = true;
  services.cron.enable = true;
  services.openssh.enable = true;
  services.journald.extraConfig = '' Storage=persistent '';
  services.gvfs.enable = true;
  services.udisks2.enable = true;


  # Pacotes do sistema

  fonts.packages = with pkgs; [
    font-awesome
    material-design-icons
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    papirus-icon-theme
    gnome.adwaita-icon-theme
  ];

  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    HYPRLAND_WORKAREA_OFFSET = "0,40,0,0";
  };

  environment.systemPackages = with pkgs; [

    # Ferramentas e utilitários
    kmscube libdrm wayland sddm mlocate notepadqq p7zip mc curl
    remmina arandr alacritty kitty
    dmidecode lshw neofetch lm_sensors feh fish zsh
    tmux wget ansible lsof nfs-utils
    lsyncd virtualbox transmission_4-qt
    rpi-imager terminator termite komorebi mesa

    # Multimídia / Produtividade
    ardour audacity blender hydrogen gwenview
    obs-studio rhythmbox rosegarden musescore vlc

    # Desenvolvimento / Navegador
    brave vscode sublime4 chromium
    lens wavebox drawio libreoffice

    # Acessórios e drivers
    openscad gimp inkscape sweethome3d.application cheese simple-scan gnome.gnome-screenshot
    openrgb polychromatic solaar
    bitwarden gnome.gnome-calculator appimage-run

    # CLI estética e monitoramento
    eza conky cava btop bibata-cursors

    # Hyprland stuff
    polkit_gnome hyprpaper networkmanagerapplet eww

    # Scanner Brother (brscan5)
    brscan5

    # Banco de dados e ferramentas
    dbeaver-bin lens

    # Utilitários
    nvme-cli dolphin xfce.thunar mate.caja

    #PENDING PACKAGES
    # torbrowser
  ];

  system.stateVersion = "24.11";
}
