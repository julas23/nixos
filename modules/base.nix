{ config, lib, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./fonts.nix
    ./docker.nix
    ./vars.nix
    ./amdgpu.nix
    ./nvidia.nix
    ./intel.nix
    ./wayland.nix
    ./xorg.nix
    ./gnome.nix
    ./hyprland.nix
    ./i3.nix
    ./mate.nix
    ./xfce.nix
    ./user.nix
    ./locale-br.nix
    ./locale-us.nix
    ./ollama.nix
    ./cosmic.nix
    ./awesome.nix
  ];

  install.system = {
    video = "amdgpu";
    host = "hp";
    graphic = "wayland";
    desktop = "cosmic";
    user = "user";
    locale = "us";
    ollama = "N";
  };

  system.activationScripts.createDataDirs = {
    text = ''
      # Ensure /data exists and is owned by the user
      mkdir -p /data/docker /data/python /data/node /data/rust
      chown -R @USERNAME@:users /data || true
      chmod -R 755 /data || true
      
      # Fix home directory and .local ownership to prevent root-lockout
      # This is critical because of the Python/Rust bind-mounts
      if [ -d /home/@USERNAME@ ]; then
        echo "Ensuring ownership for /home/@USERNAME@..."
        mkdir -p /home/@USERNAME@/.local/lib/python3.13
        mkdir -p /home/@USERNAME@/.cargo
        chown -R @USERNAME@:users /home/@USERNAME@
      fi
    '';
  };

  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" "wavebox-10.137.11-2" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # DOCKER
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    data-root = "/data/docker";
  };

  fileSystems."/var/lib/docker" = {
    device = "/data/docker";
    options = [ "bind" ];
    noCheck = true;
  };

  # NODEJS
  fileSystems."/usr/local/share/npm" = {
    device = "/data/node/share";
    options = [ "bind" "nofail" ];
  };

  # PYTHON
  fileSystems."/home/@USERNAME@/.local/lib/python3.13" = {
    device = "/data/python/lib";
    options = [ "bind" "nofail" ];
  };

  # RUST
  fileSystems."/home/@USERNAME@/.cargo" = {
    device = "/data/rust";
    options = [ "bind" "nofail" ];
  };

  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "@USERNAME@" ];

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8"];
  networking.search = [ "home.local" ];
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 11434 8080 22 ];
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;

  services.xserver.enable = true;
  services.libinput.enable = true;
  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.cron.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.blueman.enable = true;
  services.upower.enable = true; # Critical for COSMIC Settings
  services.journald.extraConfig = '' Storage=persistent '';
  services.flatpak.enable = true;
  
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.printing.enable = true;

  # Force D-Bus environment update on session start
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.dbus}/bin/dbus-update-activation-environment --all
  '';

  programs.adb.enable = true;

  systemd.user.services.pixel-bridge = {
    description = "Reverse Tethering for Pixel 8 Pro";
    serviceConfig = {
      ExecStart = "${pkgs.gnirehtet}/bin/gnirehtet run";
      Restart = "always";
      RestartSec = "5s";
    };
    wantedBy = [ "default.target" ];
  };

  system.stateVersion = "25.11";

}
