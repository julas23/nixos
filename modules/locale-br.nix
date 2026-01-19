{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.locale == "br") {

  time.timeZone = "America/Sao_Paulo";

  i18n.supportedLocales = [ "pt_BR.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LANG = "pt_BR.UTF-8";
    LC_ALL = "pt_BR.UTF-8";
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
    LC_CTYPE= "pt_BR.UTF-8";
    LC_COLLATE= "pt_BR.UTF-8";
    LC_MESSAGES= "pt_BR.UTF-8";
  };

  services.xserver.xkb = {
      layout = "us";
      variant = "alt-intl";
    };
  console.keyMap = "us";
  fonts.fontconfig.enable = true;

}
