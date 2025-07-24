{ lib, ... }:

{
  options = {
    
    install.system = {
      
      host = lib.mkOption {
        type = lib.types.enum [ "ryzen" "hp" "thinkpad" ];
        default = "ryzen";
        description = "Define o perfil de hardware específico da máquina.";
      };
      
      desktop = lib.mkOption {
        type = lib.types.enum [ "gnome" "hyprland" "i3" "xfce" "mate" "text" ];
        default = "text";
        description = "Seleciona o gestor de janelas.";
      };
      
      graphic = lib.mkOption {
        type = lib.types.enum [ "xorg" "wayland" ];
        default = "xorg";
        description = "Seleciona o ambiente gráfico.";
      };
      
      user = lib.mkOption {
        type = lib.types.enum [ "juliano" "normaluser" ];
        default = "juliano";
        description = "Seleciona o perfil do utilizador principal.";
      };

      video = lib.mkOption {
        type = lib.types.enum [ "nvidia" "amdgpu" "vm" ];
        default = "vm";
        description = "Seleciona o driver de vídeo a ser configurado.";
      };

      locale = lib.mkOption {
        type = lib.types.enum [ "us" "br" "pt" ];
        default = "us";
        description = "Seleciona o local a ser configurado.";
      };

      mount = lib.mkOption {
        type = lib.types.enum [ "S" "N" ];
        default = "N";
        description = "Seleciona se habilita ou não montagem do NFS.";
      };

      ollama = lib.mkOption {
        type = lib.types.enum [ "S" "N" ];
        default = "N";
        description = "Seleciona se habilita ou não o LLM.";
      };

    };
  };
}
