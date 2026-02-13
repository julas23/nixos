# Server Profile
# Headless server configuration

{ ... }:

{
  system.config = {
    graphics = {
      server = "none";
      desktop = "none";
    };
    
    hardware = {
      audio.enable = false;
      bluetooth.enable = false;
      printing.enable = false;
    };
    
    services = {
      docker.enable = true;
      ollama.enable = false;
      ssh = {
        enable = true;
        permitRootLogin = false;
      };
    };
    
    boot = {
      quietBoot = true;
      timeout = 1;
    };
  };
}
