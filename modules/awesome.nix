{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.desktop == "awesome") {
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks # for managing lua packages
        luadbi-mysql # if database support is needed
      ];
    };
  };

  # Essential packages for an AwesomeWM workflow
  environment.systemPackages = with pkgs; [
    alacritty    # Recommended terminal
    rofi         # Application launcher
    picom        # Compositor for transparency and shadows
    nitrogen     # Wallpaper manager
    lxappearance # For configuring GTK themes
    networkmanagerapplet # Network icon in systray
    pasystray    # Audio icon in systray
  ];

  # Enable support for fonts and icons needed for many Awesome themes
  fonts.packages = with pkgs; [
    font-awesome
    nerdfonts
  ];
}
