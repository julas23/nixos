#!/run/current-system/sw/bin/bash
clear
nix-collect-garbage -d
nix-store --optimize
nixos-rebuild switch --flake .#hp --refresh --option extra-substituters https://cosmic.cachix.org/ --option extra-trusted-public-keys cosmic.cachix.org-1:D7qyUR+MS4dnq2SKL/M/1m798E8P5qfbxP57FPpLGXg=
