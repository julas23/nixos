# Internationalization (i18n) Configuration
# Handles locale, language, and character encoding

{ config, ... }:

let
  cfg = config.system.config.locale;
in

{
  # Default locale
  i18n.defaultLocale = cfg.language;

  # Extra locale settings
  i18n.extraLocaleSettings = {
    LC_ADDRESS = cfg.language;
    LC_IDENTIFICATION = cfg.language;
    LC_MEASUREMENT = cfg.language;
    LC_MONETARY = cfg.language;
    LC_NAME = cfg.language;
    LC_NUMERIC = cfg.language;
    LC_PAPER = cfg.language;
    LC_TELEPHONE = cfg.language;
    LC_TIME = cfg.language;
  };

  # Supported locales
  i18n.supportedLocales = cfg.extraLocales;
}
