{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.locale == "pt") {

  time.timeZone = "Europe/Lisbon";

  i18n.supportedLocales = [ "pt_PT.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LANG = "en_US.UTF-8";
    LC_ALL = "pt_PT.UTF-8";
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
    LC_CTYPE= "pt_PT.UTF-8";
    LC_COLLATE= "pt_PT.UTF-8";
    LC_MESSAGES= "pt_PT.UTF-8";
  };

  services.xserver.xkb = {
      layout = "us";
      variant = "alt-intl";
    };
  console.keyMap = "us";
  fonts.fontconfig.enable = true;

}
