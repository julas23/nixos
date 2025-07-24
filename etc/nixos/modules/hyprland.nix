{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "hyprland") {

  programs.hyprland.enable = true;
  services.xserver.enable = true;
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland hyprland-protocols hyprpaper hyprpicker hyprlock hypridle wl-clipboard grim slurp waybar mako wofi cliphist rocm-smi whisper-cpp solaar
    desktop-file-utils xdotool wmctrl whisper-cpp hidapi libusb1 open-webui rofi-wayland mako swaylock-effects polybar picom dmenu dunst jgmenu swayidle grim slurp
    gammastep cliphist pamixer kitty thunar nwg-look catppuccin-gtk papirus-icon-theme lxqt.lxqt-policykit xdg-desktop-portal-gtk
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];
}
