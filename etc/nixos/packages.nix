pkgs: with pkgs; [
  #(import ./wavebox.nix { inherit pkgs; })

#### internet
  chromium transmission_4-gtk brave tor-browser-bundle-bin

#### development
  dbeaver-bin vscode lens

#### office
  bitwarden sublime4 libreoffice xed

#### design
  simple-scan brscan5 blender cheese drawio feh freecad gimp gwenview inkscape openscad sweethome3d.application pkgs.gnome-screenshot

#### multimidia
  mpv mpvpaper ardour audacity hydrogen muse musescore rhythmbox rosegarden obs-studio vlc

#### system
  cups gutenprint ghostscript cups-filters foomatic-db foomatic-db-engine
  alsa-firmware alsa-utils arandr networkmanagerapplet
  cronie htop inxi exo eza font-manager freerdp git glxinfo lsof mc micro hyprpaper
  eww waybar wofi wl-clipboard cliphist
  dmidecode lshw neofetch lm_sensors

#### tools
  alacritty foot ansible kitty tmux termite zsh fish wlogout swaybg
  btop popsicle blueman dolphin nano nettools nfs-utils mlocate p7zip curl 
  rpi-imager rdesktop remmina system-config-printer unrar unzip virtualbox
  pkgs.gnome-calculator noto-fonts wget xdg-utils wl-clipboard clipman xdg-desktop-portal-hyprland

#### opcional
  #lsyncd
  #polychromatic
  #cava
  #conky
  #openrgb
  solaar

#### pending
  #wavebox pending APPIMAGE
  #simplenote
  #amd-ucode
  vulkan-loader
  vulkan-tools
  #base-devel
  xorg.xrandr
  python3 python3Packages.pip
  (pkgs.nerdfonts.override {fonts = [ "JetBrainsMono" "Meslo" "FiraCode" ]; })
]
