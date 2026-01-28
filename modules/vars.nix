{ lib, ... }:

{
  options = {
    install.system = {
      desktop = lib.mkOption {
        type = lib.types.enum [ "gnome" "hyprland" "i3" "xfce" "mate" "cosmic" ];
        default = " ";
      };
      graphic = lib.mkOption {
        type = lib.types.enum [ "xorg" "wayland" ];
        default = "wayland";
      };
      video = lib.mkOption {
        type = lib.types.enum [ "nvidia" "amdgpu" "intel" "vm" ];
        default = " ";
      };
      locale = lib.mkOption {
        type = lib.types.enum [ "us" "br" ];
        default = "us";
      };
      enabledMounts = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "nfs" "usb" "nvm" "ssd" ]);
        default = [ ];
      };
      ollama = lib.mkOption {
        type = lib.types.enum [ "Y" "N" ];
        default = "N";
      };
    };
  };
}