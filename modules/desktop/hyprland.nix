# Hyprland Window Manager
# Dynamic tiling Wayland compositor with complete application stack

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "hyprland";
in

{
  config = lib.mkIf enabled {
    # Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Display manager
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    # XDG Desktop Portal for Hyprland
    xdg.portal = {
      enable = true;
      extraPortals = [ 
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    # Complete Hyprland application stack
    environment.systemPackages = with pkgs; [
      # Hyprland components
      hyprpaper                         # Wallpaper daemon
      hyprlock                          # Screen locker
      hypridle                          # Idle daemon
      hyprpicker                        # Color picker
      
      # Status bars
      waybar                            # Wayland bar
      eww                               # Widget system
      
      # Launchers and menus
      rofi-wayland                      # Application launcher
      wofi                              # Wayland launcher
      fuzzel                            # App launcher
      
      # Notifications
      dunst                             # Notification daemon
      mako                              # Wayland notification daemon
      libnotify                         # Notification library
      
      # Wallpaper
      swww                              # Wallpaper daemon
      swaybg                            # Background setter
      wpaperd                           # Wallpaper daemon
      
      # Screenshot and screen recording
      grim                              # Screenshot
      slurp                             # Screen area selection
      swappy                            # Screenshot editor
      wf-recorder                       # Screen recorder
      
      # Terminal emulators
      kitty                             # GPU-accelerated terminal
      alacritty                         # Alternative terminal
      foot                              # Wayland terminal
      
      # File managers
      pcmanfm                           # Lightweight file manager
      nautilus                          # GNOME file manager
      ranger                            # Terminal file manager
      
      # Clipboard managers
      wl-clipboard                      # Wayland clipboard utilities
      cliphist                          # Clipboard history
      
      # Audio control
      pavucontrol                       # PulseAudio volume control
      pwvucontrol                       # PipeWire volume control
      pamixer                           # CLI mixer
      
      # Brightness control
      brightnessctl                     # Brightness control
      
      # Network management
      networkmanagerapplet              # NetworkManager applet
      
      # Power management
      poweralertd                       # Power alerts
      
      # Display configuration
      wlr-randr                         # Display config for wlroots
      wdisplays                         # GUI display config
      
      # System monitors
      htop                              # Process viewer
      btop                              # Modern system monitor
      
      # Session management
      swayidle                          # Idle manager
      swaylock                          # Screen locker
      
      # Additional Wayland utilities
      wtype                             # xdotool for Wayland
      wlsunset                          # Day/night gamma adjustment
      kanshi                            # Dynamic display config
      
      # GTK/Qt theming
      qt5.qtwayland
      qt6.qtwayland
      lxappearance                      # GTK theme switcher
      
      # Fonts
      dejavu_fonts
      liberation_ttf
      font-awesome
      nerdfonts
    ];

    # Enable sound support with PipeWire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # Enable dconf
    programs.dconf.enable = true;

    # Enable polkit
    security.polkit.enable = true;
  };
}
