# Ollama Service Configuration
# Local AI model runner

{ config, lib, ... }:

let
  cfg = config.system.config.services.ollama;
in

{
  config = lib.mkIf cfg.enable {
    # Enable Ollama service
    services.ollama.enable = true;

    # Ollama listens on localhost:11434 by default
    services.ollama.acceleration = "rocm";  # or "cuda" for NVIDIA
  };
}
