{ lib, ... }:

{
  options = {
    install.system = {
      # System Identity
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "nixos";
        description = "System hostname";
      };
      
      # User Configuration
      user = lib.mkOption {
        type = lib.types.enum [ "user" ];
        default = "user";
        description = "User profile to activate";
      };
      username = lib.mkOption {
        type = lib.types.str;
        default = "user";
        description = "Primary username";
      };
      
      # Hardware Configuration
      host = lib.mkOption {
        type = lib.types.enum [ "ryzen" "hp" "think" "server" ];
        default = "ryzen";
        description = "Host machine profile";
      };
      video = lib.mkOption {
        type = lib.types.enum [ "nvidia" "amdgpu" "intel" "vm" ];
        default = "amdgpu";
        description = "GPU/Video driver";
      };
      
      # Graphics Configuration
      graphic = lib.mkOption {
        type = lib.types.enum [ "xorg" "wayland" ];
        default = "wayland";
        description = "Graphics server protocol";
      };
      desktop = lib.mkOption {
        type = lib.types.enum [ "gnome" "hyprland" "i3" "xfce" "mate" "cosmic" "awesome" ];
        default = "cosmic";
        description = "Desktop environment";
      };
      
      # Locale and Regional Settings
      locale = lib.mkOption {
        type = lib.types.enum [ "us" "br" ];
        default = "us";
        description = "Locale profile (legacy, prefer localeCode)";
      };
      localeCode = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "Full locale code (e.g., en_US.UTF-8, pt_BR.UTF-8)";
      };
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "America/Miami";
        description = "System timezone (e.g., America/Sao_Paulo)";
      };
      
      # Keyboard Configuration
      keymap = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Console keyboard layout";
      };
      xkbLayout = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "X11/Wayland keyboard layout";
      };
      xkbVariant = lib.mkOption {
        type = lib.types.str;
        default = "alt-intl";
        description = "X11/Wayland keyboard variant";
      };
      
      # Storage Configuration
      enabledMounts = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "nfs" "usb" "nvm" "ssd" ]);
        default = [ ];
        description = "Additional filesystem mounts to enable";
      };
      
      # Optional Services
      ollama = lib.mkOption {
        type = lib.types.enum [ "Y" "N" ];
        default = "N";
        description = "Enable Ollama AI service";
      };
      docker = lib.mkOption {
        type = lib.types.enum [ "Y" "N" ];
        default = "Y";
        description = "Enable Docker containerization";
      };
    };
  };
}
