{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.locale == "us") {

  time.timeZone = "America/Miami";

  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_CTYPE= "en_US.UTF-8";
    LC_COLLATE= "en_US.UTF-8";
    LC_MESSAGES= "en_US.UTF-8";
  };

  services.xserver.xkb = {
      layout = "us";
      variant = "alt-intl";
    };
  console.keyMap = "us";
  fonts.fontconfig.enable = true;

}
