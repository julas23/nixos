{ config, pkgs, lib, ... }:

{
  # Overlay específico para corrigir locale em apps Chromium/Electron
  nixpkgs.overlays = [
    (self: super: {
      # Função helper para wrapper com locale
      withLocaleFix = pkg: pkg.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ self.makeWrapper ];
        postInstall = (oldAttrs.postInstall or "") + ''
          # Para binários
          for binary in $out/bin/*; do
            if [ -f "$binary" ] && [ -x "$binary" ]; then
              wrapProgram "$binary" \
                --set LOCALE_ARCHIVE "${pkgs.glibcLocales}/lib/locale/locale-archive" \
                --set LC_ALL "pt_BR.UTF-8" \
                --set LANG "pt_BR.UTF-8" \
                --set LANGUAGE "pt_BR:pt:en"
            fi
          done
          
          # Para arquivos .desktop
          if [ -d "$out/share/applications" ]; then
            for desktop in $out/share/applications/*.desktop; do
              if [ -f "$desktop" ]; then
                sed -i 's|^Exec=|Exec=env LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive LC_ALL=pt_BR.UTF-8 LANG=pt_BR.UTF-8 |g' "$desktop"
              fi
            done
          fi
        '';
      });

      # Aplicar o fix aos pacotes problemáticos
      chromium = self.withLocaleFix super.chromium;
      ferdium = self.withLocaleFix super.ferdium;
      
      # Opcional: outros apps Electron
      discord = self.withLocaleFix super.discord;
      slack = self.withLocaleFix super.slack;
      vscode = self.withLocaleFix super.vscode;
    })
  ];

  # Pacote necessário para locale
  environment.systemPackages = with pkgs; [
    glibcLocales
  ];
}
