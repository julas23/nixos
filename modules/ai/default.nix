# AI / QC / ML Stack — Module Aggregator
#
# Enabled via:  config.system.config.ai.enable = true
#
# Sub-modules:
#   cuda.nix     — GPU acceleration packages (CUDA / ROCm) + nvidia-container-toolkit
#   storage.nix  — /data LVM RAID1 mount + /data/ai directory tree + env vars
#   services.nix — LiteLLM, OpenWebUI, ComfyUI (Docker) + webcam kernel module
#   mcp.nix      — MCP server scripts for Claude Code (webcam, comfyui)
#   quantum.nix  — Quantum Espresso, scientific Python, ML/QC venvs, Piper TTS

{ ... }:

{
  imports = [
    ./cuda.nix
    ./storage.nix
    ./services.nix
    ./mcp.nix
    ./quantum.nix
  ];
}
