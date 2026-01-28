{ lib, ... }:

{
  options = {
    install.system = {
      host = lib.mkOption {
        type = lib.types.enum [ "ryzen" "hp" "think" "server" ];
        default = "ryzen";
      };
      desktop = lib.mkOption {
        type = lib.types.enum [ "gnome" "hyprland" "i3" "xfce" "mate" "cosmic" "awesome" ];
        default = "cosmic";
      };
      graphic = lib.mkOption {
        type = lib.types.enum [ "xorg" "wayland" ];
        default = "wayland";
      };
      user = lib.mkOption {
        type = lib.types.enum [ "user" ];
        default = "user";
      };
      video = lib.mkOption {
        type = lib.types.enum [ "nvidia" "amdgpu" "intel" "vm" ];
        default = "amdgpu";
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
