# Jarvis — Voice Assistant (STT → LLM → TTS)
#
# Dependências runtime:
#   - whisper-cli   (whisper-cpp)  : transcrição de voz local
#   - Claude Haiku API             : raciocínio (chave em /etc/jarvis/env)
#   - Piper TTS                    : síntese de voz PT-BR local (zero rede)
#
# Setup inicial (como root):
#   1. echo 'ANTHROPIC_API_KEY=sk-ant-...' > /etc/jarvis/env && chmod 600 /etc/jarvis/env
#   2. jarvis-setup   (baixa modelo whisper ~1.6 GB + modelo Piper PT-BR ~60 MB)
#
# Uso:
#   jarvis            (inicia loop de conversa no terminal)
#   jarvis-setup      (baixa/verifica modelos)

{ config, lib, pkgs, ... }:

let
  cfg = config.system.config.services.jarvis or {};

  jarvisPython = pkgs.python3.withPackages (ps: with ps; [
    anthropic
  ]);

  jarvisRun = pkgs.writeShellScriptBin "jarvis" ''
    export PATH="${jarvisPython}/bin:${pkgs.whisper-cpp}/bin:${pkgs.piper-tts}/bin:${pkgs.sox}/bin:${pkgs.mpv}/bin:$PATH"
    if [ -f /etc/jarvis/env ]; then
      set -a
      source /etc/jarvis/env
      set +a
    fi
    exec ${jarvisPython}/bin/python3 /etc/nixos/modules/services/jarvis.py "$@"
  '';

  jarvisSetup = pkgs.writeShellScriptBin "jarvis-setup" ''
    set -e
    MODEL_DIR=/var/lib/jarvis/models

    # Whisper
    WHISPER_MODEL=$MODEL_DIR/ggml-large-v3-turbo.bin
    if [ ! -f "$WHISPER_MODEL" ]; then
      mkdir -p "$MODEL_DIR"
      echo "Baixando modelo whisper large-v3-turbo (~1.6 GB)..."
      ${pkgs.whisper-cpp}/bin/whisper-cpp-download-ggml-model large-v3-turbo "$MODEL_DIR"
      echo "Whisper instalado: $WHISPER_MODEL"
    else
      echo "Whisper OK: $WHISPER_MODEL"
    fi

    # Piper PT-BR
    PIPER_MODEL=$MODEL_DIR/pt_BR-faber-medium.onnx
    if [ ! -f "$PIPER_MODEL" ]; then
      echo "Baixando modelo Piper pt_BR-faber-medium (~63 MB)..."
      BASE_URL="https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/pt/pt_BR/faber/medium"
      ${pkgs.curl}/bin/curl -L --progress-bar "$BASE_URL/pt_BR-faber-medium.onnx"      -o "$PIPER_MODEL"
      ${pkgs.curl}/bin/curl -L --progress-bar "$BASE_URL/pt_BR-faber-medium.onnx.json" -o "$PIPER_MODEL.json"
      echo "Piper instalado: $PIPER_MODEL"
    else
      echo "Piper OK: $PIPER_MODEL"
    fi
  '';
in
{
  config = lib.mkIf (cfg.enable or false) {
    environment.systemPackages = [
      jarvisRun
      jarvisSetup
      pkgs.whisper-cpp
      pkgs.piper-tts
      pkgs.sox
    ];

    systemd.tmpfiles.rules = [
      "d /var/lib/jarvis        0755 root root -"
      "d /var/lib/jarvis/models 0755 root root -"
      "d /etc/jarvis            0755 root root -"
    ];
  };
}
