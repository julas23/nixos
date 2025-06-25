pkgs: with pkgs; [
  #(import ./wavebox.nix { inherit pkgs; })

#### internet
  chromium transmission_4-gtk brave tor-browser-bundle-bin

#### development
  dbeaver-bin vscode lens

#### office
  bitwarden sublime4 libreoffice xed

#### design
  brscan5 simple-scan blender cheese drawio feh freecad gimp kdePackages.gwenview inkscape openscad sweethome3d.application pkgs.gnome-screenshot

#### multimidia
  mpv mpvpaper ardour audacity hydrogen muse musescore rhythmbox rosegarden obs-studio vlc

#### Já parte do pacote CUPS
#  cups gutenprint ghostscript cups-filters foomatic-db foomatic-db-engine

#### GNOME
   gnome-tweaks gnome-console nautilus desktop-file-utils

#### THEMES
   papirus-icon-theme tela-icon-theme arc-theme arc-icon-theme dracula-icon-theme kdePackages.breeze-icons kdePackages.oxygen-icons mint-l-icons windows10-icons material-design-icons pkgs.adwaita-icon-theme

#### system
  alsa-firmware alsa-utils arandr networkmanagerapplet
  cronie htop inxi exo eza font-manager freerdp git glxinfo lsof mc micro hyprpaper
  eww waybar wofi wl-clipboard cliphist pstree pavucontrol
  dmidecode lshw neofetch lm_sensors

#### tools
  wavebox alacritty foot ansible kitty tmux termite zsh fish wlogout swaybg kdePackages.okular grimblast
  btop popsicle blueman kdePackages.dolphin nano nettools nfs-utils mlocate p7zip curl nvme-cli usbutils
  rpi-imager rdesktop remmina system-config-printer unrar unzip virtualbox numlockx file dnsutils whois
  pkgs.gnome-calculator wget wl-clipboard clipman xdg-utils xdg-desktop-portal

#### opcional
  lsyncd
  cava
  conky
  openrgb
  steam
  solaar

#### pending
  #simplenote
  #amd-ucode
  #base-devel
  vulkan-loader
  vulkan-tools
  xorg.xrandr
  python3 python3Packages.pip
]
