{ pkgs, ... }:

let
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
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "fix-appimage" ''
      export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath extraLibs}:$LD_LIBRARY_PATH"
      export NIXOS_OZONE_WL=1
      exec ${pkgs.appimage-run}/bin/appimage-run "$@"
    '')
  ];
}
