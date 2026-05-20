# AI GPU Acceleration
#
# NVIDIA (current): Quadro P5000 16 GB — CUDA 6.1 (Pascal, sm_61)
#   - nvidia-container-toolkit: Docker GPU passthrough (--gpus=all)
#   - cudatoolkit: CUDA compiler + libraries for native workloads
#
# AMD (future): Radeon Instinct MI50X 32 GB — ROCm / GFX 9.0.6 (Vega 20)
#   - rocmPackages.clr: HIP runtime
#   - HSA_OVERRIDE_GFX_VERSION=9.0.6: required for apps that don't list Vega 20 explicitly

{ config, lib, pkgs, ... }:

let
  aiEnabled = config.system.config.ai.enable;
  gpu       = config.system.config.hardware.gpu;
in

{
  config = lib.mkIf aiEnabled (lib.mkMerge [

    # ── NVIDIA CUDA ─────────────────────────────────────────────────────────
    (lib.mkIf (gpu == "nvidia") {
      # Enables the CDI device plugin so Docker can pass the GPU into containers.
      hardware.nvidia-container-toolkit.enable = true;

      environment.systemPackages = with pkgs; [
        cudatoolkit          # nvcc, cuda headers, cublas, curand, etc.
        nvtopPackages.nvidia # GPU utilisation monitor
      ];

      environment.variables = {
        # Expose GPU 0 to processes that read these vars (e.g. PyTorch, JAX).
        CUDA_VISIBLE_DEVICES   = "0";
        NVIDIA_VISIBLE_DEVICES = "all";
        NVIDIA_DRIVER_CAPABILITIES = "compute,utility";
      };
    })

    # ── AMD ROCm ─────────────────────────────────────────────────────────────
    (lib.mkIf (gpu == "amd") {
      environment.systemPackages = with pkgs; [
        rocmPackages.clr      # HIP runtime (replaces OpenCL + ROCm libraries)
        rocmPackages.rocminfo  # rocminfo, rocm-smi
        nvtopPackages.amd      # GPU utilisation monitor
      ];

      environment.variables = {
        # MI50X is Vega 20 — override so apps that only list Vega 10/14 still work.
        HSA_OVERRIDE_GFX_VERSION = "9.0.6";
        ROCR_VISIBLE_DEVICES     = "0";
      };

      # Grant user access to /dev/kfd (HSA) and /dev/dri (DRI rendering).
      users.users.${config.system.config.user.name}.extraGroups = [ "render" ];
    })

  ]);
}
