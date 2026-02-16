# System Packages Configuration
# Comprehensive application stack for development, multimedia, and daily use

{ config, lib, pkgs, ... }:

let
  # Scientific Python environment with common packages
  scientific-python = pkgs.python3.withPackages (ps: with ps; [
    numpy scipy sympy qutip tensorflow torch matplotlib pandas
    jupyterlab pip requests termcolor
  ]);
in

{
  environment.systemPackages = with pkgs; [

    #### 1. INTERNET & BROWSERS
    (chromium.override {
      commandLineArgs = [
        "--disable-gpu"
        "--disable-software-rasterizer"
        "--ozone-platform=x11"
      ];
    })
    transmission_4-gtk
    brave
    firefox
    librewolf
    ferdium

    #### 2. DEVELOPMENT & CLOUD
    vscode
    vscodium
    dbeaver-bin
    lens
    nodejs_24
    npm-check
    sqlite
    terraform
    helm
    docker-compose
    rustup
    cmake
    gcc
    gnumake
    ansible
    scientific-python
    kubectl
    drawio

    #### 3. OFFICE & DESIGN
    bitwarden-desktop
    sublime4
    libreoffice
    simple-scan
    blender
    gimp
    inkscape
    openscad
    sweethome3d.application
    pdfarranger
    zathura
    scribus

    #### 4. MULTIMEDIA
    mpv
    mpvpaper
    ardour
    audacity
    hydrogen
    muse-sequencer
    musescore
    rhythmbox
    obs-studio
    vlc
    clementine
    picard
    strawberry
    pwvucontrol
    helvum
    rosegarden
    cava
    feh
    zoom-us
    cheese
    loupe

    #### 5. SYSTEM & TERMINAL
    git
    jq
    mc
    thunderbird
    pciutils
    vulkan-tools
    btop
    htop
    eza
    inxi
    nvme-cli
    lshw
    dmidecode
    neofetch
    kitty
    alacritty
    zsh
    tmux
    curl
    netcat-openbsd
    popsicle

    #### 6. UTILS & TROUBLESHOOTING
    wl-clipboard
    libinput-gestures
    mlocate
    p7zip
    wget
    psmisc
    procps
    bc
    nfs-utils
    lsyncd
    android-tools
    lsof
    mtr
    net-tools
    usbutils
    ethtool
    unzip
    unrar
    rar
    zip
    xdg-utils
    fuse3
    rpi-imager
    solaar
    tcpdump
    nmap
    dnsutils
    socat
    sysstat
    atop
    iotop
    powertop
    ncdu
    tldr
    eww
    gnome-disk-utility
    appimage-run
    flatpak
    whois
    
    #### 7. ADDITIONAL TOOLS
    waydroid
  ];

  # Allow unfree packages (required for many proprietary software)
  nixpkgs.config.allowUnfree = true;

  # Permit specific insecure packages that are still needed
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
    "wavebox-10.137.11-2"
  ];

  # Enable nix-ld for running unpatched binaries
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

  # Enable Android Debug Bridge
  programs.adb.enable = true;

  # Enable Flatpak support
  services.flatpak.enable = true;
}
