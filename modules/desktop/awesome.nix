# Awesome Window Manager
# Highly configurable, dynamic window manager for X11
# Visual stack aimed at a modern Hyprland-like appearance using:
#   - picom (blur, rounded corners, shadows, animations)
#   - rofi (app launcher with modern themes)
#   - eww (ElKowar's Wacky Widgets — sidebar/bar like waybar)
#   - dunst (notification daemon with rounded corners)
#   - luaPackages: vicious + awesome-wm-widgets (wibox widgets)
#   - lain + bling: installed as fetchFromGitHub overlays via activation script

{ config, lib, pkgs, ... }:

let
  enabled  = config.system.config.graphics.desktop == "awesome";
  username = config.system.config.user.name;

  # bling and lain are NOT in nixpkgs — fetch them as Lua libraries
  # and place them in ~/.config/awesome/libs/ via activation script
  blingSetup = pkgs.writeShellScript "awesome-bling-setup" ''
    set -euo pipefail
    LIBS_DIR="/home/${username}/.config/awesome/libs"
    mkdir -p "$LIBS_DIR"

    # bling — modern layouts, tag preview, playerctl widget, tabbed clients
    if [ ! -d "$LIBS_DIR/bling" ]; then
      echo "[awesome] Cloning bling..."
      ${pkgs.git}/bin/git clone --depth 1 \
        https://github.com/blingcorp/bling.git \
        "$LIBS_DIR/bling" \
        && echo "[awesome] bling installed." \
        || echo "[awesome] WARNING: Failed to clone bling."
    fi

    # lain — extra layouts, async widgets, utility functions
    if [ ! -d "$LIBS_DIR/lain" ]; then
      echo "[awesome] Cloning lain..."
      ${pkgs.git}/bin/git clone --depth 1 \
        https://github.com/lcpz/lain.git \
        "$LIBS_DIR/lain" \
        && echo "[awesome] lain installed." \
        || echo "[awesome] WARNING: Failed to clone lain."
    fi

    chown -R ${username}:users "$LIBS_DIR"
    echo "[awesome] Lua libraries ready."
  '';

in

{
  config = lib.mkIf enabled {

    # ── Awesome WM ──────────────────────────────────────────────────────────
    services.xserver.windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks               # Lua package manager
        luadbi-mysql           # Database abstraction layer
        lgi                    # GObject introspection bindings (required by bling)
        vicious                # Widget library (CPU, mem, net, battery, etc.)
        awesome-wm-widgets     # streetturtle's widget collection (spotify, volume, etc.)
      ];
    };

    # ── Display manager ─────────────────────────────────────────────────────
    services.xserver.displayManager.lightdm = {
      enable = true;
      greeters.gtk = {
        enable = true;
        theme.name   = "Adwaita-dark";
        iconTheme.name = "Papirus-Dark";
      };
    };

    # ── XDG Desktop Portal ──────────────────────────────────────────────────
    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # ── Application stack ───────────────────────────────────────────────────
    environment.systemPackages = with pkgs; [

      # Compositor — picom v13 supports blur, rounded corners, shadows, fading
      picom

      # App launcher — rofi with modern themes
      rofi
      #rofi-wayland              # Rofi with Wayland/X11 support (latest)
      dmenu                     # Fallback simple menu

      # Bar / widget system — eww (like waybar but for X11 too)
      eww

      # Wallpaper
      feh
      nitrogen

      # Notifications — dunst with rounded corners support
      dunst
      libnotify

      # Terminals
      alacritty
      kitty

      # File managers
      pcmanfm
      ranger
      gvfs                      # Virtual filesystem support for pcmanfm

      # Screenshot
      scrot
      maim
      flameshot

      # System monitors
      htop
      btop
      conky

      # Audio
      pavucontrol
      pamixer
      playerctl                 # MPRIS media player control (used by bling)

      # Network
      networkmanagerapplet

      # Power management
      xfce.xfce4-power-manager

      # Display configuration
      arandr
      autorandr

      # Clipboard
      clipmenu
      xclip
      xsel

      # Screen locker
      i3lock-color              # i3lock fork with color/blur/image support
      multilockscreen           # Wrapper for i3lock-color with blur effects
      xss-lock

      # Appearance — GTK themes and icons
      lxappearance
      papirus-icon-theme        # Modern icon theme (matches Hyprland rices)
      adwaita-icon-theme
      gnome-themes-extra

      # GTK theming support
      gtk3
      gtk4
      gsettings-desktop-schemas

      # Utilities
      xdotool
      wmctrl
      xorg.xrandr
      xorg.xev
      xorg.xprop
      xorg.xwininfo

      # Color picker (useful for theming)
      gpick

      # Fonts managed centrally in modules/desktop/fonts.nix
    ];

    # ── GTK dark theme system-wide ──────────────────────────────────────────
    programs.dconf.enable = true;
    environment.sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };

    # ── Systemd service: clone bling and lain on first boot ─────────────────
    systemd.services.awesome-libs-setup = {
      description = "Install Awesome WM Lua libraries (bling, lain)";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "network-online.target" ];
      wants       = [ "network-online.target" ];
      serviceConfig = {
        Type            = "oneshot";
        RemainAfterExit = true;
        ExecStart       = blingSetup;
      };
    };
  };
}
