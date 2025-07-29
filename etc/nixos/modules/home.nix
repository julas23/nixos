# /etc/nixos/modules/home.nix
{ machine, lib, pkgs, ... }:

{
  home.stateVersion = "25.05";

  # Pacotes do utilizador
  home.packages = with pkgs; [
    (catppuccin-kvantum.override {
      accent = "blue";
      variant = "mocha";
    })
    libsForQt5.qtstyleplugin-kvantum
    papirus-folders
  ];

  # ... (a sua configuração de cursor 'home.pointerCursor' está perfeita) ...
  home.pointerCursor = {
    name = "Catppuccin-Mocha-Lavender-Cursors";
    package = pkgs.catppuccin-cursors.mochaLavender;
    gtk.enable = true;
    size = 22;
  };
  
  # ... (a sua configuração 'gtk' está perfeita) ...
  gtk = {
    enable = true;
    # ...
  };

  # Ativa o serviço Dconf para que as configurações abaixo sejam aplicadas
  dconf.enable = true; # <--- ADICIONE ESTA LINHA

  # A sua configuração 'dconf.settings' está perfeita
  dconf.settings = {
    "org/gtk/settings/file-chooser" = {
      sort-directories-first = true;
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = "Catppuccin-Mocha-Standard-Blue-Dark";
      color-scheme = "prefer-dark";
    };
  };

  # A sua configuração 'xdg.configFile' está perfeita
  xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
    General.theme = "Catppuccin-Mocha-Blue";
  };
}
