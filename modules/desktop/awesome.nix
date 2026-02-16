# Awesome Window Manager
# Highly configurable, dynamic window manager for X11 with complete stack

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "awesome";
in

{
  config = lib.mkIf enabled {
    # Awesome window manager
    services.xserver.windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
        lgi
      ];
    };

    # Display manager
    services.xserver.displayManager.lightdm.enable = true;

    # XDG Desktop Portal
    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Complete Awesome WM application stack
    environment.systemPackages = with pkgs; [
      # Launchers and menus
      rofi                              # Application launcher
      dmenu                             # Simple menu
      
      # Compositor and effects
      picom                             # Compositor
      
      # Wallpaper
      feh                               # Wallpaper setter
      nitrogen                          # Wallpaper manager
      
      # Notifications
      dunst                             # Notification daemon
      libnotify                         # Notification library
      
      # Terminal emulators
      alacritty                         # GPU-accelerated terminal
      kitty                             # Alternative terminal
      
      # File managers
      pcmanfm                           # Lightweight file manager
      ranger                            # Terminal file manager
      
      # Screenshot tools
      scrot                             # Screenshot utility
      maim                              # Alternative screenshot
      flameshot                         # Feature-rich screenshot
      
      # System monitors
      htop                              # Process viewer
      conky                             # System monitor
      
      # Audio control
      pavucontrol                       # PulseAudio volume control
      pamixer                           # CLI mixer
      
      # Network management
      networkmanagerapplet              # NetworkManager applet
      
      # Power management
      xfce.xfce4-power-manager          # Power manager
      
      # Display configuration
      arandr                            # GUI for xrandr
      autorandr                         # Automatic display config
      
      # Clipboard manager
      clipmenu                          # Clipboard manager
      xclip                             # Clipboard CLI
      
      # Screen locker
      i3lock                            # Screen locker
      xss-lock                          # Screen locker integration
      
      # Appearance
      lxappearance                      # GTK theme switcher
      
      # Additional utilities
      xdotool                           # X11 automation
      wmctrl                            # Window manager control
      
      # Fonts
      dejavu_fonts
      liberation_ttf
      font-awesome
      nerdfonts
    ];

    # Enable sound support
    hardware.pulseaudio.enable = lib.mkDefault true;

    # Enable dconf
    programs.dconf.enable = true;
  };
}
