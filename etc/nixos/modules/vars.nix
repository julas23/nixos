{ lib, ... }:

{
  options = {
    install.system = {
      host = lib.mkOption {
        type = lib.types.enum [ "ryzen" "hp" "think" ];
        default = "ryzen";
      };
      desktop = lib.mkOption {
        type = lib.types.enum [ "gnome" "hyprland" "i3" "xfce" "mate" "text" ];
        default = "text";
      };
      graphic = lib.mkOption {
        type = lib.types.enum [ "xorg" "wayland" ];
        default = "xorg";
      };
      user = lib.mkOption {
        type = lib.types.enum [ "juliano" "normaluser" ];
        default = "juliano";
      };
      video = lib.mkOption {
        type = lib.types.enum [ "nvidia" "amdgpu" "vm" ];
        default = "vm";
      };
      locale = lib.mkOption {
        type = lib.types.enum [ "us" "br" "pt" ];
        default = "us";
      };
      enabledMounts = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "nfs" "usb" "nvm" "ssd" ]);
        default = [ ];
      };
      ollama = lib.mkOption {
        type = lib.types.enum [ "S" "N" ];
        default = "N";
      };
    };
  };
}
