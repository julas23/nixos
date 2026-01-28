{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "awesome") {
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks # para gerenciar pacotes lua
        luadbi-mysql # se precisar de banco de dados
      ];
    };
  };

  # Pacotes essenciais para um workflow com AwesomeWM
  environment.systemPackages = with pkgs; [
    alacritty    # Terminal recomendado
    rofi         # Launcher de aplicativos
    picom        # Compositor para transparências e sombras
    nitrogen     # Gerenciador de papel de parede
    lxappearance # Para configurar temas GTK
    networkmanagerapplet # Ícone de rede na systray
    pasystray    # Ícone de áudio na systray
  ];

  # Habilita suporte a fontes e ícones necessários para muitos temas do Awesome
  fonts.packages = with pkgs; [
    font-awesome
    nerdfonts
  ];
}
