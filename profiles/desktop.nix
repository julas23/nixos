# Desktop Profile
# Full desktop workstation with all features

{ ... }:

{
  system.config = {
    hardware = {
      audio = {
        enable = true;
        backend = "pipewire";
      };
      bluetooth.enable = true;
      printing.enable = true;
    };
    
    graphics = {
      server = "wayland";
      desktop = "cosmic";
    };
    
    services = {
      docker.enable = true;
      ollama.enable = false;
      ssh.enable = true;
    };
  };
}
