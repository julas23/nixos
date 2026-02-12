{ pkgs, ... }:

let
  scientific-python = pkgs.python3.withPackages (ps: with ps; [
    numpy scipy sympy qutip tensorflow torch matplotlib pandas
    jupyterlab pip requests termcolor #newsapi
  ]);
in

{
  environment.systemPackages = with pkgs; [

    #### 1. INTERNET & BROWSERS
    chromium transmission_4-gtk brave firefox librewolf ferdium
      (chromium.override {
        commandLineArgs = [
          "--disable-gpu"
          "--disable-software-rasterizer"
          "--ozone-platform=x11"
        ];
      })

    #### 2. DEVELOPMENT & CLOUD
    vscode vscodium dbeaver-bin lens nodejs_24 npm-check sqlite
    terraform helm docker-compose rustup cmake gcc gnumake ansible
    scientific-python kubectl drawio

    #### 3. OFFICE & DESIGN
    bitwarden-desktop sublime4 libreoffice simple-scan blender gimp
    inkscape openscad sweethome3d.application pdfarranger zathura
    scribus

    #### 4. MULTIMEDIA
    mpv mpvpaper ardour audacity hydrogen muse musescore rhythmbox 
    obs-studio vlc clementine picard strawberry pwvucontrol helvum
    rosegarden mpv cava feh cheese loupe

    #### 5. SYSTEM & TERMINAL
    git jq mc thunderbird pciutils vulkan-tools btop htop eza inxi
    nvme-cli lshw dmidecode neofetch kitty alacritty zsh tmux curl
    netcat-openbsd

    #### 6. UTILS & TROUBLESHOOTING
    wl-clipboard libinput-gestures mlocate p7zip wget psmisc procps
    bc nfs-utils lsyncd android-tools lsof mtr net-tools usbutils
    ethtool unzip unrar rar zip xdg-utils fuse3 rpi-imager solaar
    tcpdump nmap dnsutils socat sysstat atop iotop powertop ncdu
    tldr eww gnome-disk-utility appimage-run flatpak popsicle whois
    
    #### 7. ADDITIONAL TOOLS
    #pkgs.thunar
    #pkgs.thunar-archive-plugin
    cosmic-edit waydroid 
  ];
}
