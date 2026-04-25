inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  # ── Claude AI ─────────────────────────────────────────────────────────
  claude-code-nix.url    = "github:sadjow/claude-code-nix";       # code/terminal
  claude-desktop.url     = "github:aaddrick/claude-desktop-debian"; # desktop (não oficial)
  # ─────────────────────────────────────────────────────────────────────

  outputs = { self, nixpkgs, claude-code-nix, claude-desktop, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };  # ← necessário para o módulo acessar inputs
      modules = [
        ./configuration.nix
      ];
    };
  };
};
