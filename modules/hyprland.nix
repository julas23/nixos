{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "hyprland") {
  programs.hyprland.enable = true;
  services.xserver.enable = true;
  services.gvfs.enable = true;

  # XDG Portal Configuration for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "gtk" ];
    config.hyprland.default = [ "hyprland" "gtk" ];
  };

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland 
    hyprland-protocols 
    hyprpaper 
    hyprpicker 
    hyprlock 
    hypridle 
    wl-clipboard 
    grim 
    slurp 
    waybar 
    mako 
    wofi 
    cliphist 
    rocm-smi 
    whisper-cpp 
    solaar
    desktop-file-utils 
    xdotool 
    wmctrl 
    hidapi 
    libusb1 
    open-webui 
    rofi-wayland 
    swaylock-effects 
    polybar 
    picom 
    dmenu 
    dunst 
    jgmenu 
    swayidle 
    gammastep 
    pamixer 
    kitty 
    thunar 
    nwg-look 
    catppuccin-gtk 
    papirus-icon-theme 
    lxqt.lxqt-policykit
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];
}
