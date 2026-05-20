# Jarvis — Voice Assistant (STT → LLM → TTS)
#
# Dependências runtime:
#   - whisper-cli   (whisper-cpp)  : transcrição de voz local
#   - Claude Haiku API             : raciocínio (chave em /etc/jarvis/env)
#   - Edge TTS                     : síntese de voz PT-BR via Microsoft
#
# Setup inicial (como root):
#   1. echo 'ANTHROPIC_API_KEY=sk-ant-...' > /etc/jarvis/env && chmod 600 /etc/jarvis/env
#   2. jarvis-setup   (baixa modelo whisper ~1.6 GB)
#
# Uso:
#   jarvis            (inicia loop de conversa no terminal)
#   jarvis-setup      (baixa/verifica modelo)

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.services.jarvis or {};

  jarvisPython = pkgs.python3.withPackages (ps: with ps; [
    anthropic
    edge-tts
  ]);

  jarvisScript = pkgs.writeTextFile {
    name = "jarvis.py";
    text  = builtins.readFile ./jarvis.py;
  };

  jarvisRun = pkgs.writeShellScriptBin "jarvis" ''
    export PATH="${jarvisPython}/bin:${pkgs.whisper-cpp}/bin:${pkgs.sox}/bin:${pkgs.mpv}/bin:$PATH"
    if [ -f /etc/jarvis/env ]; then
      set -a
      source /etc/jarvis/env
      set +a
    fi
    exec ${jarvisPython}/bin/python3 ${jarvisScript} "$@"
  '';

  jarvisSetup = pkgs.writeShellScriptBin "jarvis-setup" ''
    set -e
    MODEL_DIR=/var/lib/jarvis/models
    MODEL_FILE=$MODEL_DIR/ggml-large-v3-turbo.bin

    if [ -f "$MODEL_FILE" ]; then
      echo "Modelo já instalado: $MODEL_FILE"
      exit 0
    fi

    mkdir -p "$MODEL_DIR"
    echo "Baixando modelo whisper large-v3-turbo (~1.6 GB)..."
    ${pkgs.whisper-cpp}/bin/whisper-cpp-download-ggml-model large-v3-turbo "$MODEL_DIR"
    echo "Modelo instalado em $MODEL_FILE"
  '';
in
{
  config = lib.mkIf (cfg.enable or false) {
    environment.systemPackages = [
      jarvisRun
      jarvisSetup
      pkgs.whisper-cpp
      pkgs.sox
    ];

    systemd.tmpfiles.rules = [
      "d /var/lib/jarvis        0755 root root -"
      "d /var/lib/jarvis/models 0755 root root -"
      "d /etc/jarvis            0700 root root -"
    ];
  };
}
