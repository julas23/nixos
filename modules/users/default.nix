# User Configuration Module
# Handles user account creation and configuration

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.user;
  shellPackage = {
    bash = pkgs.bash;
    zsh = pkgs.zsh;
    fish = pkgs.fish;
  }.${cfg.shell} or pkgs.bash;
in

{
  # Define user account
  users.users.${cfg.name} = {
    isNormalUser = true;
    description = cfg.fullName;
    uid = cfg.uid;
    group = cfg.group;
    extraGroups = cfg.extraGroups;
    shell = shellPackage;
    
    # Initial password (should be changed after first login)
    initialPassword = "changeme";
  };

  # Create user's primary group if needed
  users.groups.${cfg.group} = lib.mkIf (cfg.group != "users") {
    gid = cfg.gid;
  };

  # Sudo configuration
  security.sudo = lib.mkIf cfg.sudoer {
    enable = true;
    wheelNeedsPassword = !cfg.nopasswd;
  };

  # Shell programs
  programs.bash.enable = cfg.shell == "bash";
  programs.zsh.enable = cfg.shell == "zsh";
  programs.fish.enable = cfg.shell == "fish";
}
