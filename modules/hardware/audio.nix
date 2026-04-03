# Audio Configuration
# PipeWire only (services.pulseaudio renamed from hardware.pulseaudio in NixOS 25.11)

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.hardware.audio;
in

{
  config = lib.mkIf cfg.enable {
    # PipeWire (modern audio system — replaces PulseAudio)
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;  # PulseAudio compatibility layer
      jack.enable = true;   # JACK compatibility layer
    };

    # PulseAudio MUST be disabled when using PipeWire
    # (renamed from hardware.pulseaudio to services.pulseaudio in NixOS 25.11)
    services.pulseaudio.enable = false;

    # Real-time audio for low-latency
    security.rtkit.enable = true;
  };
}
