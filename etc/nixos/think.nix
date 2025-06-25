{ config, pkgs, ... }: {

  boot.initrd.kernelModules = [ "amdgpu" ];
  networking.hostName = "think";
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
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [ xdg-desktop-portal-hyprland hyprland-protocols hyprpaper hyprpicker hyprlock hypridle wl-clipboard grim slurp waybar mako wofi cliphist ];
}
