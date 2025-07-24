{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "i3") {

  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.xserver.windowManager.i3.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.enable = true;
  services.gvfs.enable = true;
  #services.xserver.xinit.enable = "true";
  #services.xserver.xinit.script = '' exec ${pkgs.i3}/bin/i3 '';

  environment.systemPackages = with pkgs; [
    desktop-file-utils xdotool wmctrl whisper-cpp hidapi libusb1 open-webui
    i3-gaps i3status i3lock-color i3-layout-manager i3-cycle-focus i3-back i3-volume polybar picom rofi dmenu dunst jgmenu
  ];
}
