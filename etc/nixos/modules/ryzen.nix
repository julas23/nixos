{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.host == "ryzen") {

  networking.hostName = "ryzen";

  hardware.openrazer.enable = true;
  boot.kernelModules = ["i2c-dev" "ddcci_backlight"];
  boot.kernelParams = [ "usbcore.quirks=0079:181c:i" ];

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="008b", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="007f", MODE="0666"
    ACTION=="add", ATTRS{idVendor}=="0079", ATTRS{idProduct}=="181c", RUN+="${pkgs.kmod}/bin/modprobe xpad", RUN+="${pkgs.bash}/bin/sh -c 'echo 0079 181c > /sys/bus/usb/drivers/xpad/new_id'"
  '';
  environment.systemPackages = with pkgs; [ openrgb polychromatic openrazer-daemon ];
}
