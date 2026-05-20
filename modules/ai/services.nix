# AI Stack — Services
#
# Services managed here:
#   • ai-init.service     one-shot that seeds /data/ai config files on first boot
#   • docker-litellm      LiteLLM LLM router          → http://127.0.0.1:4000
#   • docker-open-webui   OpenWebUI chat interface     → http://127.0.0.1:3000
#   • docker-comfyui      ComfyUI Stable Diffusion     → http://127.0.0.1:8188
#   • Ollama              handled by modules/services/ollama.nix, activated here
#   • whisper-cpp         installed as a system package
#   • Webcam kernel mod   v4l2loopback + udev + video group
#
# All containers use --network=host so they reach Ollama on 127.0.0.1:11434
# without needing Ollama to bind on 0.0.0.0.
#
# Secrets: /data/ai/secrets.env (chmod 600, not tracked in git).
# A template is written there on first boot if the file does not exist.

{ config, lib, pkgs, ... }:

let
  aiEnabled = config.system.config.ai.enable;
  gpu       = config.system.config.hardware.gpu;
  username  = config.system.config.user.name;

  # ComfyUI image variant matches the GPU backend.
  comfyuiImage =
    if gpu == "amd"
    then "ghcr.io/ai-dock/comfyui:latest-rocm"
    else "ghcr.io/ai-dock/comfyui:latest-cuda";   # default: NVIDIA / CPU

  # Docker extra options for GPU passthrough, conditional per GPU vendor.
  comfyuiGpuOpts =
    if gpu == "nvidia" then [ "--gpus=all" ]
    else if gpu == "amd" then [ "--device=/dev/kfd" "--device=/dev/dri" "--group-add=video" "--group-add=render" ]
    else [];

  # ── Config file templates ────────────────────────────────────────────────
  # These are written to /data/ai/ on first boot only (user edits are preserved).

  litellmConfigTemplate = pkgs.writeText "litellm-config.yaml" ''
    # LiteLLM router config — edit to match your installed Ollama models.
    # Full docs: https://docs.litellm.ai/docs/routing
    #
    # Pull models first:
    #   ollama pull qwen3.5:9b
    #   ollama pull qwen3.5:27b      # CPU offload viable with 256 GB RAM
    #   ollama pull qwen2.5-coder:14b
    model_list:
      - model_name: local-fast
        litellm_params:
          model: ollama/qwen3.5:9b
          api_base: http://localhost:11434

      - model_name: local-smart
        litellm_params:
          # 27B Q4 ~20 GB — fits in 16 GB VRAM + CPU offload via 256 GB RAM
          model: ollama/qwen3.5:27b
          api_base: http://localhost:11434

      - model_name: local-coder
        litellm_params:
          model: ollama/qwen2.5-coder:14b
          api_base: http://localhost:11434

      - model_name: claude-fallback
        litellm_params:
          model: claude-sonnet-4-6
          api_key: os.environ/ANTHROPIC_API_KEY

    router_settings:
      routing_strategy: usage-based-routing
      fallbacks:
        - local-smart: [claude-fallback]
        - local-fast:  [local-smart, claude-fallback]

    litellm_settings:
      drop_params: true
      set_verbose: false
  '';

  secretsEnvTemplate = pkgs.writeText "secrets.env.template" ''
    # AI Stack secrets — fill in and rename to /data/ai/secrets.env
    # This file must have chmod 600. It is NOT tracked in git.
    ANTHROPIC_API_KEY=sk-ant-REPLACE_ME
    LITELLM_MASTER_KEY=sk-litellm-REPLACE_ME
    WEBUI_SECRET_KEY=REPLACE_ME_WITH_RANDOM_STRING
  '';

in

{
  config = lib.mkIf aiEnabled {

    # ── 1. Docker must be enabled for oci-containers ─────────────────────────
    virtualisation.docker.enable = lib.mkDefault true;
    virtualisation.oci-containers.backend = "docker";

    # ── 2. Seed /data/ai config files on first boot ───────────────────────────
    systemd.services.ai-init = {
      description   = "AI stack — seed initial configuration files";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "systemd-tmpfiles-setup.service" ];
      before        = [
        "docker-litellm.service"
        "docker-open-webui.service"
        "docker-comfyui.service"
      ];
      serviceConfig = {
        Type            = "oneshot";
        RemainAfterExit = true;
        User            = username;
        ExecStart = pkgs.writeShellScript "ai-init" ''
          set -euo pipefail

          if [ ! -f /data/ai/litellm/config.yaml ]; then
            cp ${litellmConfigTemplate} /data/ai/litellm/config.yaml
            echo "[ai-init] Created /data/ai/litellm/config.yaml — edit to match your Ollama models"
          fi

          if [ ! -f /data/ai/secrets.env ]; then
            cp ${secretsEnvTemplate} /data/ai/secrets.env
            chmod 600 /data/ai/secrets.env
            echo "[ai-init] Created /data/ai/secrets.env — fill in your API keys before starting services"
          fi
        '';
      };
    };

    # ── 3. LiteLLM — LLM router (port 4000) ──────────────────────────────────
    virtualisation.oci-containers.containers.litellm = {
      image            = "ghcr.io/berriai/litellm:main-latest";
      volumes          = [ "/data/ai/litellm:/app/config:ro" ];
      cmd              = [ "--config" "/app/config/config.yaml" "--port" "4000" "--host" "127.0.0.1" ];
      environmentFiles = [ "/data/ai/secrets.env" ];
      # host network: containers reach Ollama on 127.0.0.1:11434 without extra config.
      extraOptions     = [ "--network=host" ];
    };

    systemd.services.docker-litellm = {
      after    = [ "ai-init.service" "ollama.service" ];
      requires = [ "ai-init.service" ];
    };

    # ── 4. OpenWebUI — Chat UI (port 3000) ───────────────────────────────────
    virtualisation.oci-containers.containers.open-webui = {
      image   = "ghcr.io/open-webui/open-webui:main";
      volumes = [ "/data/ai/open-webui:/app/backend/data" ];
      environment = {
        OLLAMA_BASE_URL      = "http://127.0.0.1:11434";
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK         = "True";
        # WEBUI_SECRET_KEY is picked up from secrets.env below.
      };
      environmentFiles = [ "/data/ai/secrets.env" ];
      extraOptions     = [ "--network=host" ];
    };

    systemd.services.docker-open-webui = {
      after    = [ "ai-init.service" ];
      requires = [ "ai-init.service" ];
    };

    # ── 5. ComfyUI — Stable Diffusion (port 8188) ────────────────────────────
    virtualisation.oci-containers.containers.comfyui = {
      image   = comfyuiImage;
      volumes = [
        "/data/ai/models/comfyui:/root/ComfyUI/models"
        "/data/ai/comfyui/output:/root/ComfyUI/output"
        "/data/ai/comfyui/custom_nodes:/root/ComfyUI/custom_nodes"
      ];
      extraOptions = [ "--network=host" "--ipc=host" ] ++ comfyuiGpuOpts;
    };

    systemd.services.docker-comfyui = {
      after    = [ "ai-init.service" ];
      requires = [ "ai-init.service" ];
    };

    # ── 6. Webcam — kernel module + udev + video group ───────────────────────
    # v4l2loopback creates virtual video devices (useful for OBS virtual cam, etc.)
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    boot.kernelModules       = [ "v4l2loopback" ];

    services.udev.extraRules = ''
      KERNEL=="video[0-9]*", GROUP="video", MODE="0664"
    '';

    users.users.${username}.extraGroups = [ "video" ];

    # ── 7. whisper-cpp — STT for voice-mcp ───────────────────────────────────
    # piper-tts is the lightweight TTS (CPU). Kokoro TTS (GPU) is installed
    # by ai-ml-setup into /data/python/venvs/ml/ (see modules/ai/quantum.nix).
    environment.systemPackages = with pkgs; [
      whisper-cpp  # STT binary; voice-mcp runs it via uvx voice-mode
    ];
  };
}
