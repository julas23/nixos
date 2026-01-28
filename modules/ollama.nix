{ config, lib, pkgs, ... }:

lib.mkIf (config.install.system.ollama == "Y") {
  # 1. OLLAMA SERVICE
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
    # Dynamic acceleration based on selected GPU
    acceleration = if config.install.system.video == "amdgpu" then "rocm" 
                   else if config.install.system.video == "nvidia" then "cuda"
                   else null;
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "8";
      OLLAMA_MAX_LOADED_MODELS = "4";
    } // (lib.optionalAttrs (config.install.system.video == "amdgpu") {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    });
  };

  # 2. OPEN WEBUI
  services.open-webui = {
    package = pkgs.open-webui;
    enable = true;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      # Automatic URL adjustment based on IP/Hostname
      OLLAMA_API_BASE_URL = "http://localhost:11434/api";
      OLLAMA_BASE_URL = "http://localhost:11434";
    };
  };
  systemd.services.open-webui.serviceConfig.ExecStart = lib.mkForce "${pkgs.open-webui}/bin/open-webui serve --host \"0.0.0.0\" --port 8080";

  # 3. STABLE DIFFUSION (Container)
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

  # 4. POSTGRESQL WITH PGVECTOR
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

  # 5. MODEL DOWNLOAD SCRIPT
  systemd.services.download-models = {
    description = "Download initial AI models";
    after = [ "network.target" "ollama.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      sleep 15
      ${pkgs.curl}/bin/curl -X POST http://localhost:11434/api/pull -d '{"name": "llama3.2:3b"}'
      ${pkgs.curl}/bin/curl -X POST http://localhost:11434/api/pull -d '{"name": "llava:7b"}'
      nohup ${pkgs.curl}/bin/curl -X POST http://localhost:11434/api/pull -d '{"name": "llama3.2:70b"}' > /var/log/ollama-pull-70b.log 2>&1 &
    '';
    serviceConfig.Type = "oneshot";
  };

  # 6. ADDITIONAL PACKAGES
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    clinfo
    radeontop
    (python3.withPackages (ps: with ps; [
      ps.requests
      ps.termcolor
      ps.pip
      ps.transformers
      ps.accelerate
      ps.datasets
    ]))
  ];
}
