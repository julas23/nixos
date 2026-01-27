{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.locale == "br") {
  time.timeZone = "America/Sao_Paulo";

  i18n = {
    defaultLocale = "pt_BR.UTF-8";
    supportedLocales = [ "pt_BR.UTF-8/UTF-8" ];
    
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
      LC_CTYPE = "pt_BR.UTF-8";
      LC_COLLATE = "pt_BR.UTF-8";
      LC_MESSAGES = "pt_BR.UTF-8";
    };
  };

  console.keyMap = "us";

  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  #i18n.inputMethod = {
  #  enabled = false;
  #};

  environment.sessionVariables = {
    GTK_IM_MODULE = lib.mkForce "cedilla";
    QT_IM_MODULE = lib.mkForce "cedilla";
    XMODIFIERS = lib.mkForce "@im=none";
    XCOMPOSEFILE = lib.mkForce "/etc/X11/XCompose";
  };

  environment.etc."X11/XCompose".text = ''
    include "%L"
    <dead_acute> <C> : "Ç"
    <dead_acute> <c> : "ç"
  '';

  system.activationScripts.cedillaCleanup = lib.stringAfter [ "users" ] ''
    rm -f /home/juliano/.XCompose
    rm -f /home/juliano/.config/gtk-3.0/settings.ini
    rm -f /home/juliano/.config/gtk-4.0/settings.ini
  '';
}
