{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.lsyncd;

  excludeListContent = lib.strings.concatStringsSep "\n" (lib.unique [
    "/home/juliano/.cache/babl"
    "/home/juliano/.cache/BraveSoftware"
    "/home/juliano/.cache/cliphist"
    "/home/juliano/.cache/com.bitwarden.desktop"
    "/home/juliano/.cache/epiphany"
    "/home/juliano/.cache/evolution"
    "/home/juliano/.cache/fish"
    "/home/juliano/.cache/flatpak"
    "/home/juliano/.cache/folks"
    "/home/juliano/.cache/fontconfig"
    "/home/juliano/.cache/font-manager"
    "/home/juliano/.cache/gegl-0.4"
    "/home/juliano/.cache/gimp"
    "/home/juliano/.cache/gnome-calculator"
    "/home/juliano/.cache/gnome-desktop-thumbnailer"
    "/home/juliano/.cache/gnome-screenshot"
    "/home/juliano/.cache/gnome-software"
    "/home/juliano/.cache/gstreamer-1.0"
    "/home/juliano/.cache/gtk-3.0"
    "/home/juliano/.cache/gtk-4.0"
    "/home/juliano/.cache/ImageMagick"
    "/home/juliano/.cache/jgmenu"
    "/home/juliano/.cache/kio_http"
    "/home/juliano/.cache/mc"
    "/home/juliano/.cache/mesa_shader_cache"
    "/home/juliano/.cache/mesa_shader_cache_db"
    "/home/juliano/.cache/Microsoft"
    "/home/juliano/.cache/mpv"
    "/home/juliano/.cache/nvidia"
    "/home/juliano/.cache/obexd"
    "/home/juliano/.cache/pip"
    "/home/juliano/.cache/pipx"
    "/home/juliano/.cache/polkit-kde-authentication-agent-1"
    "/home/juliano/.cache/polychromatic"
    "/home/juliano/.cache/protontricks"
    "/home/juliano/.cache/qtshadercache-x86_64-little_endian-lp64"
    "/home/juliano/.cache/radv_builtin_shaders"
    "/home/juliano/.cache/razer-cli"
    "/home/juliano/.cache/sessions"
    "/home/juliano/.cache/shutter"
    "/home/juliano/.cache/strawberry"
    "/home/juliano/.cache/thumbnails"
    "/home/juliano/.cache/tracker3"
    "/home/juliano/.cache/typescript"
    "/home/juliano/.cache/vlc"
    "/home/juliano/.config/audacity"
    "/home/juliano/.config/autostart"
    "/home/juliano/.config/BraveSoftware"
    "/home/juliano/.config/btop"
    "/home/juliano/.config/dconf"
    "/home/juliano/.config/dunst"
    "/home/juliano/.config/environment.d"
    "/home/juliano/.config/fish"
    "/home/juliano/.config/fontconfig"
    "/home/juliano/.config/GIMP"
    "/home/juliano/.config/glib-2.0"
    "/home/juliano/.config/goa-1.0"
    "/home/juliano/.config/gtk-2.0"
    "/home/juliano/.config/gtk-3.0"
    "/home/juliano/.config/gtk-4.0"
    "/home/juliano/.config/htop"
    "/home/juliano/.config/i3"
    "/home/juliano/.config/ibus"
    "/home/juliano/.config/inkscape"
    "/home/juliano/.config/jgmenu"
    "/home/juliano/.config/Kvantum"
    "/home/juliano/.config/libreoffice"
    "/home/juliano/.config/logs"
    "/home/juliano/.config/mc"
    "/home/juliano/.config/micro"
    "/home/juliano/.config/openrazer"
    "/home/juliano/.config/OpenRGB"
    "/home/juliano/.config/picom"
    "/home/juliano/.config/polybar"
    "/home/juliano/.config/polychromatic"
    "/home/juliano/.config/procps"
    "/home/juliano/.config/pulse"
    "/home/juliano/.config/qt5ct"
    "/home/juliano/.config/razergenie"
    "/home/juliano/.config/strawberry"
    "/home/juliano/.config/systemd"
    "/home/juliano/.config/Thunar"
    "/home/juliano/.config/VirtualBox"
    "/home/juliano/.config/vlc"
    "/home/juliano/.config/xsettingsd"
    "/home/juliano/.local/share/applications"
    "/home/juliano/.local/share/audacity"
    "/home/juliano/.local/share/baloo"
    "/home/juliano/.local/share/dolphin"
    "/home/juliano/.local/share/epiphany"
    "/home/juliano/.local/share/evolution"
    "/home/juliano/.local/share/fish"
    "/home/juliano/.local/share/flatpak"
    "/home/juliano/.local/share/folks"
    "/home/juliano/.local/share/gegl-0.4"
    "/home/juliano/.local/share/gnome-settings-daemon"
    "/home/juliano/.local/share/gnome-shell"
    "/home/juliano/.local/share/gnome-software"
    "/home/juliano/.local/share/gstreamer-1.0"
    "/home/juliano/.local/share/gvfs-metadata"
    "/home/juliano/.local/share/gwenview"
    "/home/juliano/.local/share/hyprland"
    "/home/juliano/.local/share/icc"
    "/home/juliano/.local/share/inxi"
    "/home/juliano/.local/share/keyrings"
    "/home/juliano/.local/share/kwalletd"
    "/home/juliano/.local/share/man"
    "/home/juliano/.local/share/mc"
    "/home/juliano/.local/share/nautilus"
    "/home/juliano/.local/share/okular"
    "/home/juliano/.local/share/openrazer"
    "/home/juliano/.local/share/org.gnome.TextEditor"
    "/home/juliano/.local/share/pipx"
    "/home/juliano/.local/share/remoteview"
    "/home/juliano/.local/share/sddm"
    "/home/juliano/.local/share/sounds"
    "/home/juliano/.local/share/Steam/steamapps"
    "/home/juliano/.local/share/strawberry"
    "/home/juliano/.local/share/Trash"
    "/home/juliano/.local/share/vlc"
    "/home/juliano/.local/share/vulkan"
    "/home/juliano/.local/share/xdg-desktop-portal"
  ]);

  filesListContent = ''
    .XCompose
    .aliasrc
    .bashrc
    .bitwarden-ssh-agent.sock
    .gitconfig
    .todo
    .zshrc
    .bash_history
    .zsh_history
  '';

  excludeFile = pkgs.writeTextFile { name = "lsyncd-exclude"; text = excludeListContent; };
  filesFile = pkgs.writeTextFile { name = "lsyncd-files"; text = filesListContent; };

  commonSyncSettings = {
    rsync = {
      archive = true;
      compress = false;
      update = true;
      verbose = true;
      bwlimit = 10000;
      whole_file = false;
      _extra = [
        "--partial"
        "--inplace"
        "--no-perms"
        "--no-group"
        "--delete"
        "--chmod=D755,F644"
      ];
    };
  };

  foldersToSync = [
    ".thunderbird"
    ".mozilla"
    ".tor project"
    ".wallpaper"
    ".data"
    ".fonts"
    ".oh-my-zsh"
    ".local/share/Steam/steamapps/compatdata"
    ".local/share/Steam/userdata"
    ".ssh"
    "Desktop"
    "Documents"
    "Downloads"
    "Git"
    "Music"
    "Public"
    "Pictures"
    "Videos"
    "Templates"
  ];

  isEnabled = if builtins.isBool cfg.enable 
              then cfg.enable 
              else cfg.enable == "S";

in {
  options.services.lsyncd = {
    #enable = mkEnableOption "lsyncd file synchronization";
    enable = mkOption {
      type = types.str;  # Changed from bool to str
      default = "";
      description = "Enable lsyncd (set to 'S' to enable)";
    };
    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Lsyncd configuration settings";
    };
  };

  config = mkIf isEnabled {
    environment.systemPackages = [ pkgs.lsyncd ];

    systemd.services.lsyncd = {
      description = "Lsyncd file synchronization service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        ExecStart = "${pkgs.lsyncd}/bin/lsyncd -nodaemon -log all ${pkgs.writeText "lsyncd.conf" (builtins.toJSON cfg.settings)}";
        User = "juliano";
        Group = "juliano";
        Restart = "on-failure";
      };
    };

    services.lsyncd.settings = {
      logfile = "/var/log/lsyncd/lsyncd.log";
      statusFile = "/var/log/lsyncd/lsyncd.status";
      maxProcesses = 1;
      insist = true;
      statusInterval = 60;
      nodaemon = true;

      sync = [
        {
          source = "/home/juliano/";
          target = "/mnt/nfs/juliano/";
          rsync = {
            _extra = [
              "--files-from=${pkgs.writeText "lsyncd-files" (concatStringsSep "\n" filesList)}"
              "--relative"
              "--no-R"
              "--no-implied-dirs"
            ];
          };
        }
      ] ++ (map (folder: {
        source = "/home/juliano/${folder}";
        target = "/mnt/nfs/juliano/${folder}";
      } // commonSyncSettings) foldersToSync);
    };
  };
}
