# KDE Plasma Desktop Environment Configuration
# Modern, feature-rich, and highly customizable desktop environment
# Full KDE Plasma 6 with all components and applications

{ config, lib, pkgs, ... }:

let
  enabled = config.system.config.graphics.desktop == "plasma";
in

{
  config = lib.mkIf enabled {
    # Enable X11 and Wayland support
    services.xserver.enable = true;
    
    # Display Manager - SDDM (Simple Desktop Display Manager)
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    
    # KDE Plasma Desktop Manager
    services.desktopManager.plasma6.enable = true;
    
    # XDG Desktop Portal for Plasma
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-kde ];
    };
    
    # Enable KDE Connect for device integration
    programs.kdeconnect.enable = true;
    
    # Enable Partition Manager
    programs.partition-manager.enable = true;
    
    # Enable dconf for some GTK app settings
    programs.dconf.enable = true;
    
    # KDE Plasma Applications and Components
    environment.systemPackages = with pkgs; [
      # KDE Plasma Core
      kdePackages.plasma-desktop
      kdePackages.plasma-workspace
      kdePackages.plasma-workspace-wallpapers
      kdePackages.plasma-systemmonitor
      kdePackages.plasma-browser-integration
      kdePackages.plasma-thunderbolt
      kdePackages.plasma-firewall
      kdePackages.plasma-nm              # NetworkManager integration
      kdePackages.plasma-pa              # PulseAudio integration
      kdePackages.bluedevil              # Bluetooth integration
      kdePackages.powerdevil             # Power management
      kdePackages.kscreen                # Screen management
      kdePackages.kwayland-integration   # Wayland integration
      
      # KDE Frameworks
      kdePackages.kio
      kdePackages.kio-extras
      kdePackages.kio-admin
      kdePackages.kio-fuse
      
      # KDE System Settings
      kdePackages.systemsettings
      kdePackages.kinfocenter
      
      # KDE File Management
      kdePackages.dolphin                # File manager
      kdePackages.dolphin-plugins
      kdePackages.ark                    # Archive manager
      kdePackages.krusader               # Advanced file manager
      kdePackages.filelight              # Disk usage analyzer
      
      # KDE Utilities
      kdePackages.konsole                # Terminal emulator
      kdePackages.kate                   # Advanced text editor
      kdePackages.kwrite                 # Simple text editor
      kdePackages.kcalc                  # Calculator
      kdePackages.spectacle              # Screenshot tool
      kdePackages.kfind                  # File search
      kdePackages.sweeper                # System cleaner
      kdePackages.kwalletmanager         # Wallet manager
      kdePackages.ksystemlog             # System log viewer
      kdePackages.partitionmanager       # Partition manager
      
      # KDE Graphics
      kdePackages.gwenview               # Image viewer
      kdePackages.okular                 # Document viewer
      kdePackages.kolourpaint            # Paint program
      kdePackages.kcolorchooser          # Color chooser
      kdePackages.kruler                 # Screen ruler
      
      # KDE Multimedia
      kdePackages.elisa                  # Music player
      kdePackages.dragon                 # Video player
      kdePackages.kamoso                 # Webcam application
      kdePackages.kdenlive               # Video editor
      kdePackages.k3b                    # CD/DVD burning
      
      # KDE Internet
      kdePackages.kget                   # Download manager
      kdePackages.krfb                   # Desktop sharing
      kdePackages.krdc                   # Remote desktop client
      kdePackages.kdeconnect-kde         # Device integration
      
      # KDE PIM (Personal Information Management)
      kdePackages.kontact                # PIM suite
      kdePackages.kmail                  # Email client
      kdePackages.kaddressbook           # Address book
      kdePackages.korganizer             # Calendar and organizer
      kdePackages.akregator              # RSS feed reader
      
      # KDE Office
      kdePackages.okular                 # PDF viewer
      
      # KDE Development (optional but useful)
      kdePackages.kate                   # Advanced text editor
      kdePackages.kompare                # Diff viewer
      
      # KDE Accessibility
      kdePackages.kmag                   # Screen magnifier
      kdePackages.kmousetool             # Mouse automation
      
      # KDE Games (optional - comment out if not needed)
      kdePackages.kmines                 # Minesweeper
      kdePackages.ksudoku                # Sudoku
      kdePackages.kpat                   # Patience card games
      
      # KDE Themes and Appearance
      kdePackages.breeze                 # Breeze theme
      kdePackages.breeze-gtk             # Breeze GTK theme
      kdePackages.breeze-icons           # Breeze icons
      kdePackages.oxygen                 # Oxygen theme
      kdePackages.oxygen-icons           # Oxygen icons
      
      # KDE Plasma Widgets
      kdePackages.plasma-vault           # Encrypted vaults
      kdePackages.kgamma                 # Gamma correction
      
      # Additional KDE utilities
      kdePackages.kdialog                # Dialog boxes
      kdePackages.keditbookmarks         # Bookmark editor
      kdePackages.kmenuedit              # Menu editor
      kdePackages.khelpcenter            # Help center
      
      # System integration
      kdePackages.xdg-desktop-portal-kde
      kdePackages.kde-gtk-config         # GTK configuration
      
      # Additional useful packages
      desktop-file-utils
      xdotool
      wmctrl
      
      # Fonts
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-emoji
    ];
    
    # Enable sound support with PipeWire (modern audio system)
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    
    # Disable PulseAudio (PipeWire replaces it)
    hardware.pulseaudio.enable = false;
    
    # Enable NetworkManager
    networking.networkmanager.enable = true;
    
    # Enable Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = lib.mkDefault false; # KDE has its own bluetooth manager
    
    # Enable CUPS for printing
    services.printing.enable = true;
    
    # Enable scanner support
    hardware.sane.enable = true;
    
    # Enable thumbnails
    services.tumbler.enable = true;
    
    # Enable location services (for automatic timezone, etc.)
    services.geoclue2.enable = true;
    
    # Enable firmware updates
    services.fwupd.enable = true;
  };
}
