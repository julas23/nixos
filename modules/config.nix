# Centralized System Configuration
# This file contains all system configuration options in one place
# All modules read from this configuration to determine what to enable

{ lib, ... }:

{
  options.system.config = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "Centralized system configuration";
  };

  config.system.config = {
    # System Identity
    system = {
      hostname = "nixos";
      stateVersion = "24.11";
    };

    # Locale and Regional Settings
    locale = {
      timezone = "America/Miami";
      language = "en_US.UTF-8";
      extraLocales = [ "en_US.UTF-8/UTF-8" ];
      keyboard = {
        console = "us";
        layout = "us";
        variant = "alt-intl";
        options = "";
      };
    };

    # Hardware Configuration
    hardware = {
      gpu = "amd";  # Options: amd | nvidia | intel | none
      audio = {
        enable = true;
        backend = "pipewire";  # Options: pipewire | pulseaudio
      };
      bluetooth = {
        enable = false;
      };
      printing = {
        enable = false;
      };
    };

    # Graphics Configuration
    graphics = {
      server = "wayland";  # Options: wayland | xorg
      desktop = "cosmic";  # Options: cosmic | gnome | hyprland | i3 | xfce | awesome | none
    };

    # Storage Configuration
    storage = {
      lvm = {
        enable = false;
        vgName = "vg0";
        lvName = "root";
      };
      zfs = {
        enable = false;
        poolName = "rpool";
      };
      filesystem = "ext4";  # Options: ext4 | btrfs | xfs | zfs
      mountpoint = "/";
    };

    # Services Configuration
    services = {
      docker = {
        enable = true;
      };
      ollama = {
        enable = false;
      };
      ssh = {
        enable = true;
        permitRootLogin = false;
      };
      lsyncd = {
        enable = false;
      };
    };

    # User Configuration
    user = {
      name = "user";
      fullName = "User Name";
      uid = 1000;
      gid = 1000;
      group = "users";
      extraGroups = [ "wheel" "networkmanager" ];
      sudoer = true;
      nopasswd = false;
      shell = "bash";  # Options: bash | zsh | fish
    };

    # Network Configuration
    network = {
      networkmanager = {
        enable = true;
      };
      firewall = {
        enable = true;
        allowedTCPPorts = [];
        allowedUDPPorts = [];
      };
    };

    # Boot Configuration
    boot = {
      loader = "systemd-boot";  # Options: systemd-boot | grub
      timeout = 5;
      quietBoot = true;
    };

    # Nix Configuration
    nix = {
      flakes = true;
      autoOptimiseStore = true;
      gc = {
        enable = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
  };
}
