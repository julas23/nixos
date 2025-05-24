{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "wavebox";
  version = "10.136.15-2";

  src = pkgs.fetchurl {
    url = "https://download.wavebox.app/stable/linux/deb/amd64/wavebox_10.136.15-2_amd64.deb";
    sha256 = "16j0dmx1a3cr3p1j6dcnca3nbzcszym0g5vh3xfxws1qb0h153sm";
  };

  nativeBuildInputs = [ pkgs.dpkg pkgs.autoPatchelfHook ];

  unpackPhase = "true";

  dontMakeSourcesWritable = true;

  installPhase = ''
    mkdir -p $out
    dpkg-deb -x $src $TMPDIR/wavebox
    rm -Rf $TMPDIR/wavebox/opt/wavebox/chrome-sandbox
    chmod 755 -R $TMPDIR/wavebox
    cp -r $TMPDIR/wavebox/. $out
  '';

  postUnpack = ''
    chmod +x wavebox
  '';

  meta = with pkgs.lib; {
    description = "Wavebox Email & Web App Browser";
    homepage = "https://wavebox.io";
    platforms = platforms.linux;
  };
}
