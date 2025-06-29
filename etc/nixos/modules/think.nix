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

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.amdgpu.amdgpu_vaapi.enable = true;
  hardware.amdgpu.opencl.enable = true;
  hardware.amdgpu.rocm.enable = true;

  boot.initrd.kernelModules = [ "amdgpu" ];

  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [ xdg-desktop-portal-hyprland hyprland-protocols hyprpaper hyprpicker hyprlock hypridle wl-clipboard grim slurp waybar mako wofi cliphist rocm-smi whisper-cpp python3 python3Packages.pip python3Packages.transformers python3Packages.torchvision python3Packages.pytorchWithRocm python3Packages.tensorflow-rocm ];

}
