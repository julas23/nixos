# Minimal Profile
# Bare minimum system without GUI

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
      docker.enable = false;
      ollama.enable = false;
      ssh.enable = true;
    };
  };
}
