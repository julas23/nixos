{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.ollama == "S") {

  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
  };

  services.open-webui = {
    package = pkgs.open-webui;
    enable = true;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://192.168.0.18:11434/api";
      OLLAMA_BASE_URL = "http://192.168.0.18:11434";
    };
  };
  systemd.services.open-webui.serviceConfig.ExecStart = lib.mkForce "${pkgs.open-webui}/bin/open-webui serve --host \"0.0.0.0\" --port 8080";
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    (python3.withPackages (ps: with ps; [
      ps.requests
      ps.termcolor
      ps.pip
      #ps.torchWithCuda
      #ps.torch-bin
      ps.transformers
      ps.accelerate
      ps.datasets
    ]))
  ];
}
