{ config, pkgs, ... }: {

  boot.initrd.kernelModules = [ "amdgpu" ];
  programs.hyprland.enable = true;

  networking.hostName = "hp";

  services.xserver.videoDrivers = [ "amdgpu" ];
  services.displayManager = {
    sddm ={
      enable = true;
      wayland.enable = true;
      settings = {
        Users.MinimumUid = 369;
        Users.MaximumUid = 369;
        XDisplay = {
          DisplayCommand = "/etc/nixos/Xsetup";
        };
      };
    };
  };

  hardware.graphics = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [ xdg-desktop-portal-hyprland ];
}
