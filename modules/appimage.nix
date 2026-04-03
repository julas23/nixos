# AppImage Support + Managed AppImage Applications
#
# - Enables binfmt so AppImages run directly (no wrapper needed)
# - Creates /data/appimage directory for storing AppImages
# - Downloads Wavebox, Simplenote, and AnthemScore on activation
# - Creates .desktop entries in ~/.local/share/applications per user

{ config, lib, pkgs, ... }:

let
  # Username from centralized config
  username = config.system.config.user.name;

  # AppImage storage directory
  appimageDir = "/data/appimage";

  # Extra libraries needed for Electron-based AppImages (Wavebox, Simplenote)
  extraLibs = with pkgs; [
    libGL zlib glib dbus fontconfig freetype
    xorg.libX11 xorg.libXcursor xorg.libXcomposite
    xorg.libXdamage xorg.libXext xorg.libXfixes
    xorg.libXi xorg.libXrender xorg.libXtst
    xorg.libXrandr alsa-lib at-spi2-atk atk
    cairo cups expat gdk-pixbuf gtk3 libdrm
    libnotify libsecret libuuid mesa nspr nss
    pango systemd fuse3 libxkbcommon
  ];

in

{
  # Enable AppImage binfmt support (run AppImages directly without wrapper)
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Helper wrapper for manual AppImage execution with correct libs
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "run-appimage" ''
      export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath extraLibs}:$LD_LIBRARY_PATH"
      export NIXOS_OZONE_WL=1
      exec ${pkgs.appimage-run}/bin/appimage-run "$@"
    '')
  ];

  # Create /data/appimage directory with correct ownership
  systemd.tmpfiles.rules = [
    "d /data/appimage 0755 ${username} users -"
  ];

  # Systemd one-shot service: downloads missing AppImages and creates .desktop entries
  systemd.services.appimage-setup = {
    description = "Download and register AppImage applications";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "network-online.target" "systemd-tmpfiles-setup.service" ];
    wants       = [ "network-online.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      ExecStart       = pkgs.writeShellScript "appimage-setup" ''
        set -euo pipefail

        APPIMAGE_DIR="${appimageDir}"
        DESKTOP_DIR="/home/${username}/.local/share/applications"
        ICON_DIR="/home/${username}/.local/share/icons"

        mkdir -p "$APPIMAGE_DIR" "$DESKTOP_DIR" "$ICON_DIR"
        chown ${username}:users "$APPIMAGE_DIR"

        # ── Wavebox ────────────────────────────────────────────────────
        if [ ! -f "$APPIMAGE_DIR/Wavebox.AppImage" ]; then
          echo "[appimage] Downloading Wavebox..."
          ${pkgs.curl}/bin/curl -L --retry 3 --retry-delay 2 \
            -o "$APPIMAGE_DIR/Wavebox.AppImage" \
            "https://download.wavebox.app/latest/stable/linux/appimage" \
            && echo "[appimage] Wavebox downloaded." \
            || echo "[appimage] WARNING: Failed to download Wavebox."
        else
          echo "[appimage] Wavebox already present, skipping."
        fi
        [ -f "$APPIMAGE_DIR/Wavebox.AppImage" ] && chmod +x "$APPIMAGE_DIR/Wavebox.AppImage"

        cat > "$DESKTOP_DIR/wavebox.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Wavebox
Comment=Next-gen productivity browser
Exec=/data/appimage/Wavebox.AppImage %U
Icon=wavebox
Categories=Network;WebBrowser;
Terminal=false
StartupNotify=true
StartupWMClass=Wavebox
EOF

        # ── Simplenote ─────────────────────────────────────────────────
        if [ ! -f "$APPIMAGE_DIR/Simplenote.AppImage" ]; then
          echo "[appimage] Downloading Simplenote..."
          ${pkgs.curl}/bin/curl -L --retry 3 --retry-delay 2 \
            -o "$APPIMAGE_DIR/Simplenote.AppImage" \
            "https://github.com/Automattic/simplenote-electron/releases/latest/download/Simplenote-linux-x86_64.AppImage" \
            && echo "[appimage] Simplenote downloaded." \
            || echo "[appimage] WARNING: Failed to download Simplenote."
        else
          echo "[appimage] Simplenote already present, skipping."
        fi
        [ -f "$APPIMAGE_DIR/Simplenote.AppImage" ] && chmod +x "$APPIMAGE_DIR/Simplenote.AppImage"

        cat > "$DESKTOP_DIR/simplenote.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Simplenote
Comment=Simple and fast note-taking app
Exec=/data/appimage/Simplenote.AppImage %U
Icon=simplenote
Categories=Office;TextEditor;
Terminal=false
StartupNotify=true
StartupWMClass=Simplenote
EOF

        # ── AnthemScore ────────────────────────────────────────────────
        if [ ! -f "$APPIMAGE_DIR/AnthemScore.AppImage" ]; then
          echo "[appimage] Downloading AnthemScore..."
          ${pkgs.curl}/bin/curl -L --retry 3 --retry-delay 2 \
            -o "$APPIMAGE_DIR/AnthemScore.AppImage" \
            "https://www.lunaverus.com/download/linuxAppimage" \
            && echo "[appimage] AnthemScore downloaded." \
            || echo "[appimage] WARNING: Failed to download AnthemScore."
        else
          echo "[appimage] AnthemScore already present, skipping."
        fi
        [ -f "$APPIMAGE_DIR/AnthemScore.AppImage" ] && chmod +x "$APPIMAGE_DIR/AnthemScore.AppImage"

        cat > "$DESKTOP_DIR/anthemscore.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=AnthemScore
Comment=Automatic music transcription software
Exec=/data/appimage/AnthemScore.AppImage %U
Icon=anthemscore
Categories=Audio;Music;
Terminal=false
StartupNotify=true
StartupWMClass=AnthemScore
EOF

        # Fix ownership of all created files
        chown -R ${username}:users "$APPIMAGE_DIR" "$DESKTOP_DIR"

        echo "[appimage] Setup complete."
      '';
    };
  };
}
