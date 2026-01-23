mkdir -p ~/nixos-config/modules
cat > ~/nixos-config/modules/ai-server.nix << 'EOF'
{ config, pkgs, ... }:

{
  # Ollama com suporte AMD ROCm
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "8";
      OLLAMA_MAX_LOADED_MODELS = "4";
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    };
  };
  
  # Stable Diffusion WebUI
  virtualisation.oci-containers.containers."stable-diffusion" = {
    image = "sd-webui:latest";
    ports = ["7860:7860"];
    volumes = [
      "/models/stable-diffusion:/models"
      "/data/stable-diffusion:/output"
    ];
    environment = {
      CLI_ARGS = "--api --listen --precision full --no-half";
    };
    extraOptions = ["--gpus=all" "--shm-size=8g"];
  };
  
  # PostgreSQL com pgvector
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableJIT = true;
    settings = {
      max_connections = 200;
      shared_buffers = "8GB";
      work_mem = "64MB";
      maintenance_work_mem = "2GB";
    };
  };
  
  # Script para baixar modelos iniciais
  systemd.services.download-models = {
    description = "Download initial AI models";
    after = [ "network.target" "ollama.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      sleep 10  # Aguardar ollama iniciar
      
      # Modelos leves para teste rápido
      ${pkgs.curl}/bin/curl -X POST http://localhost:11434/api/pull \
        -d '{"name": "llama3.2:3b"}'
      
      ${pkgs.curl}/bin/curl -X POST http://localhost:11434/api/pull \
        -d '{"name": "llava:7b"}'
      
      # Modelo grande (fazer overnight)
      nohup ${pkgs.curl}/bin/curl -X POST http://localhost:11434/api/pull \
        -d '{"name": "llama3.2:70b"}' > /var/log/ollama-pull-70b.log 2>&1 &
    '';
    serviceConfig.Type = "oneshot";
  };
}
EOF
