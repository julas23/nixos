{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "mate") {

  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.enable = true;
  services.xserver.desktopManager.mate.enable = true;
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    desktop-file-utils xdotool wmctrl whisper-cpp hidapi libusb1 open-webui
    mate.pluma
    mate.engrampa
    mate.atril
    mate.eom
    mate.mate-calc
    mate.mate-screenshot
    mate.mate-system-monitor
    mate.mozo
    mate.caja-dropbox
    mate.caja-open-terminal
    mate.caja-share
    mate.mate-power-manager
    mate.mate-applets
    mate.mate-tweak
  ];
}
