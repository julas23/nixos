# Developer Profile
# Development workstation with tools and services

{ pkgs, ... }:

{
  system.config = {
    hardware = {
      audio = {
        enable = true;
        backend = "pipewire";
      };
      bluetooth.enable = false;
      printing.enable = false;
    };
    
    graphics = {
      server = "wayland";
      desktop = "hyprland";
    };
    
    services = {
      docker.enable = true;
      ollama.enable = true;
      ssh.enable = true;
    };
    
    user = {
      shell = "zsh";
    };
  };

  # Development tools
  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    tmux
    htop
    curl
    wget
    jq
    ripgrep
    fd
    bat
    eza
  ];
}
