{ config, lib, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./fonts.nix
    ./docker.nix
    ./vars.nix
    ./amdgpu.nix
    ./nvidia.nix
    ./intel.nix
    ./wayland.nix
    ./xorg.nix
    ./gnome.nix
    ./hyprland.nix
    ./i3.nix
    ./mate.nix
    ./xfce.nix
    ./user.nix
    ./locale-br.nix
    ./locale-us.nix
    ./ollama.nix
    ./cosmic.nix
    ./awesome.nix
    #./volumes.nix
    #./lsyncd.nix
  ];

  # ============================================================
  # SYSTEM CONFIGURATION INDEX
  # This block serves as a centralized declaration and index
  # of all system settings applied during installation.
  # Values are updated by install.sh based on user choices.
  # ============================================================
  install.system = {
    # System Identity
    hostname = "nixos";
    
    # User Configuration
    user = "user";
    username = "user";
    
    # Hardware Configuration
    video = "amdgpu";
    
    # Graphics Configuration
    graphic = "wayland";
    desktop = "cosmic";
    
    # Locale and Regional Settings
    locale = "us";              # Legacy locale profile
    localeCode = "en_US.UTF-8"; # Full locale specification
    timezone = "America/Miami";
    
    # Keyboard Configuration
    keymap = "us";              # Console keymap
    xkbLayout = "us";           # X11/Wayland layout
    xkbVariant = "alt-intl";    # X11/Wayland variant
    
    # Optional Services
    ollama = "N";
    docker = "Y";
  };

  # ============================================================
  # TIMEZONE CONFIGURATION
  # ============================================================
  time.timeZone = config.install.system.timezone;

  # ============================================================
  # LOCALE CONFIGURATION
  # ============================================================
  i18n.defaultLocale = config.install.system.localeCode;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = config.install.system.localeCode;
    LC_IDENTIFICATION = config.install.system.localeCode;
    LC_MEASUREMENT = config.install.system.localeCode;
    LC_MONETARY = config.install.system.localeCode;
    LC_NAME = config.install.system.localeCode;
    LC_NUMERIC = config.install.system.localeCode;
    LC_PAPER = config.install.system.localeCode;
    LC_TELEPHONE = config.install.system.localeCode;
    LC_TIME = config.install.system.localeCode;
  };

  # ============================================================
  # KEYBOARD CONFIGURATION
  # ============================================================
  console.keyMap = config.install.system.keymap;
  services.xserver.xkb = {
    layout = config.install.system.xkbLayout;
    variant = config.install.system.xkbVariant;
  };

  # ============================================================
  # HOSTNAME CONFIGURATION
  # ============================================================
  networking.hostName = config.install.system.hostname;

  # ============================================================
  # SYSTEM ACTIVATION SCRIPTS
  # ============================================================
  system.activationScripts.createDataDirs = {
    text = ''
      mkdir -p /data/docker /data/python /data/node /data/rust
      chown -R ${config.install.system.username}:users /data || true
      chmod -R 755 /data || true
      
      if [ -d /home/${config.install.system.username} ]; then
        echo "Ensuring ownership for /home/${config.install.system.username}..."
        mkdir -p /home/${config.install.system.username}/.local/lib/python3.13
        mkdir -p /home/${config.install.system.username}/.cargo
        chown -R ${config.install.system.username}:users /home/${config.install.system.username}
      fi
    '';
  };

  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];

  # ============================================================
  # BOOT CONFIGURATION
  # ============================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.preDeviceCommands = "vgchange -ay" ;
  boot.initrd = {
    services.lvm.enable = true;
    kernelModules = [ "dm-raid" "dm-mirror" "raid1" "dm-mod" ];
    supportedFilesystems = [ "ext4" "lvm2" ];
  };
  boot.kernel.sysctl = {
    "vm.nr_hugepages" = 1024;
    "vm.hugetlb_shm_group" = 0;
    "vm.swappiness" = 10;
  };
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/enabled - - - - always"
  ];

  # ============================================================
  # DOCKER CONFIGURATION
  # Conditionally enabled based on install.system.docker
  # ============================================================
  virtualisation.docker.enable = lib.mkIf (config.install.system.docker == "Y") true;
  virtualisation.docker.daemon.settings = lib.mkIf (config.install.system.docker == "Y") {
    data-root = "/data/docker";
  };

  fileSystems."/var/lib/docker" = lib.mkIf (config.install.system.docker == "Y") {
    device = "/data/docker";
    options = [ "bind" ];
    noCheck = true;
  };

  # ============================================================
  # DEVELOPMENT ENVIRONMENT MOUNTS
  # ============================================================
  # NODEJS
  fileSystems."/usr/local/share/npm" = {
    device = "/data/node/share";
    options = [ "bind" "nofail" ];
  };

  # PYTHON
  fileSystems."/home/${config.install.system.username}/.local/lib/python3.13" = {
    device = "/data/python/lib";
    options = [ "bind" "nofail" ];
  };

  # RUST
  fileSystems."/home/${config.install.system.username}/.cargo" = {
    device = "/data/rust";
    options = [ "bind" "nofail" ];
  };

  # ============================================================
  # HARDWARE CONFIGURATION
  # ============================================================
  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # ============================================================
  # NIX CONFIGURATION
  # ============================================================
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" config.install.system.username ];

  # ============================================================
  # NETWORKING CONFIGURATION
  # ============================================================
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8"];
  networking.search = [ "home.local" ];
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 11434 8080 22 ];
    allowedUDPPorts = [ 53 67 68 ];
  };

  # ============================================================
  # SECURITY CONFIGURATION
  # ============================================================
  security.rtkit.enable = true;
  security.polkit.enable = true;

  # ============================================================
  # SERVICES CONFIGURATION
  # ============================================================
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  services.libinput.enable = true;
  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.cron.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.blueman.enable = true;
  services.upower.enable = true; # Critical for COSMIC Settings
  services.journald.extraConfig = '' Storage=persistent '';
  services.flatpak.enable = true;
  
  # Audio Configuration
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Network Discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # Printing
  services.printing.enable = true;

  # D-Bus Configuration
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.dbus}/bin/dbus-update-activation-environment --all
  '';

  # ============================================================
  # PROGRAMS CONFIGURATION
  # ============================================================
  programs.adb.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libappindicator-gtk3
    libdrm
    libnotify
    libpulseaudio
    libuuid
    libusb1
    libxkbcommon
    mesa
    nspr
    nss
    pango
    pipewire
    systemd
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    xorg.libxshmfence
  ];

  # ============================================================
  # SYSTEMD USER SERVICES
  # ============================================================
  systemd.user.services.pixel-bridge = {
    description = "Reverse Tethering for Android";
    serviceConfig = {
      ExecStart = "${pkgs.gnirehtet}/bin/gnirehtet run";
      Restart = "always";
      RestartSec = "5s";
    };
    wantedBy = [ "default.target" ];
  };

  # ============================================================
  # SYSTEM VERSION
  # ============================================================
  system.stateVersion = "25.11";

}
