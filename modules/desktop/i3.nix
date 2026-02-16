# i3 Window Manager
# Tiling window manager for X11 with complete application stack

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "i3";
in

{
  config = lib.mkIf enabled {
    # i3 window manager
    services.xserver.windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3lock
        i3blocks
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

    # Complete i3 application stack
    environment.systemPackages = with pkgs; [
      # i3 components
      i3status                          # Status bar
      i3lock                            # Screen locker
      i3lock-fancy                      # Fancy screen locker
      i3blocks                          # Alternative status bar
      i3-gaps                           # i3 with gaps
      
      # Launchers and menus
      dmenu                             # Simple menu
      rofi                              # Application launcher
      j4-dmenu-desktop                  # Desktop file launcher
      
      # Compositor and effects
      picom                             # Compositor (transparency, shadows)
      
      # Wallpaper and appearance
      feh                               # Wallpaper setter
      nitrogen                          # Wallpaper manager GUI
      lxappearance                      # GTK theme switcher
      
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
      
      # System monitors and bars
      polybar                           # Customizable status bar
      conky                             # System monitor
      htop                              # Process viewer
      
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
      
      # Session management
      xss-lock                          # Screen locker integration
      xautolock                         # Auto screen lock
      
      # Additional utilities
      xdotool                           # X11 automation
      wmctrl                            # Window manager control
      xorg.xev                          # Event viewer
      xorg.xprop                        # Property viewer
      
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
