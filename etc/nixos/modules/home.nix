{ machine, lib, pkgs, ... }:

{
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    (catppuccin-kvantum.override {
      accent = "blue";
      variant = "mocha";
    })
    libsForQt5.qtstyleplugin-kvantum
    papirus-folders
  ];

  home.pointerCursor = {
    name = "Catppuccin-Mocha-Lavender-Cursors";
    package = pkgs.catppuccin-cursors.mochaLavender;
    gtk.enable = true;
    size = 22;
  };
  
  gtk = {
    enable = true;
    # ...
  };

  dconf.enable = true;

  dconf.settings = {
    "org/gtk/settings/file-chooser" = {
      sort-directories-first = true;
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = "Catppuccin-Mocha-Standard-Blue-Dark";
      color-scheme = "prefer-dark";
    };
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
    General.theme = "Catppuccin-Mocha-Blue";
  };
}
