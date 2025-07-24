{ pkgs, ... }:

let
  scientific-python = pkgs.python3.withPackages (ps: with ps; [
    numpy
    scipy
    sympy
    qutip
    tensorflow
    pytorch
    matplotlib
    pandas
    jupyterlab
    pip
    requests
  ]);
in

{
  environment.systemPackages = with pkgs; [

#### internet
    chromium transmission_4-gtk brave tor-browser-bundle-bin

#### development
    dbeaver-bin vscode lens dart-sass nodejs_24 npm-check sqlite

#### office
    bitwarden sublime4 libreoffice simple-scan brscan5

#### design
    blender cheese drawio feh freecad gimp kdePackages.gwenview inkscape openscad
    sweethome3d.application pkgs.gnome-screenshot

#### multimidia
    mpv mpvpaper ardour audacity hydrogen muse musescore rhythmbox rosegarden obs-studio vlc xorg.xev
    clementine picard amarok strawberry

#### system
    alsa-firmware alsa-utils arandr networkmanagerapplet exo font-manager eww parted
    pciutils vulkan-loader vulkan-tools xorg.xrandr microcode-amd doublecmd pcmanfm freerdp git jq mc
    glxinfo lsof micro dmidecode lshw lm_sensors nixd sysstat gparted multipath-tools

#### terminal
    termite zsh oh-my-zsh fish oh-my-fish alacritty alacritty-theme btop cava tmux ansible eza inxi htop neofetch terminator

#### tools
    wavebox kdePackages.okular grimblast pipewire pwvucontrol
    popsicle blueman nano nettools nfs-utils mlocate p7zip curl nvme-cli usbutils links2 lynx xorg.xkill
    rpi-imager rdesktop remmina system-config-printer unrar unzip virtualbox numlockx file dnsutils whois
    pkgs.gnome-calculator wget xdg-utils xdg-desktop-portal psmisc procps bc rofi-screenshot exfatprogs

#### thunar
    xfce.thunar xfce.thunar-volman xfce.thunar-archive-plugin xfce.thunar-media-tags-plugin xfce.thunar-vcs-plugin xfce.thunar-archive-plugin xfce.tumbler gnome-settings-daemon

#### themes
    tela-icon-theme arc-theme arc-icon-theme dracula-icon-theme kdePackages.breeze-icons
    kdePackages.oxygen-icons mint-l-icons windows10-icons material-design-icons pkgs.adwaita-icon-theme

#### opcional
    lsyncd steam lutris
  ];
}
