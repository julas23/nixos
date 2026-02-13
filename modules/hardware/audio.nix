# Audio Configuration
# Handles PipeWire or PulseAudio

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.hardware.audio;
in

{
  config = lib.mkIf cfg.enable {
    # PipeWire (modern, recommended)
    services.pipewire = lib.mkIf (cfg.backend == "pipewire") {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # PulseAudio (legacy)
    hardware.pulseaudio = lib.mkIf (cfg.backend == "pulseaudio") {
      enable = true;
      support32Bit = true;
    };

    # Real-time audio (optional, for low-latency)
    security.rtkit.enable = true;
  };
}
