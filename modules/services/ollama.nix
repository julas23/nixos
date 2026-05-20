# Ollama Service Configuration
# Local AI model runner with automatic GPU acceleration detection.
# Activated by services.ollama.enable OR ai.enable (AI stack master switch).

{ config, lib, ... }:

let
  cfg      = config.system.config.services.ollama;
  aiEnabled = config.system.config.ai.enable;
  gpu      = config.system.config.hardware.gpu;

  # Map the system GPU setting to the Ollama acceleration backend.
  # Quadro P5000 → nvidia → cuda; future Radeon Instinct MI50X → amd → rocm.
  acceleration =
    if gpu == "nvidia" then "cuda"
    else if gpu == "amd" then "rocm"
    else null;
in

{
  config = lib.mkIf (cfg.enable || aiEnabled) (lib.mkMerge [
    {
      services.ollama = {
        enable = true;
        # Model storage redirected to /data/ai — set via OLLAMA_MODELS env var in storage.nix.
        # Ollama picks it up automatically when the env var is present.
      };
    }

    # Apply acceleration only when a supported GPU is detected.
    (lib.mkIf (acceleration != null) {
      services.ollama.acceleration = acceleration;
    })
  ]);
}
