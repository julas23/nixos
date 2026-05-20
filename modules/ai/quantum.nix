# AI Stack — Quantum Computing + ML Scientific Packages
#
# System-level packages (nixpkgs, always available):
#   quantum-espresso   Plane-wave DFT / ab initio MD (MPI-enabled)
#   python scientific  numpy, scipy, sympy, matplotlib, qutip, ipython, jupyterlab
#   piper-tts          Lightweight neural TTS (CPU, no GPU needed)
#   openmpi            MPI runtime for Quantum Espresso parallel runs
#
# Venv-based packages (pip, installed into /data/python/venvs/):
#   /data/python/venvs/ml/   PyTorch (CUDA/ROCm/CPU), TensorFlow, scikit-learn,
#                            pandas, Jupyter kernel, Kokoro TTS
#   /data/python/venvs/qc/   QuTiP, PyQuComp, Qiskit, Cirq, pennylane
#
# To initialise venvs after nixos-rebuild switch (run once as user):
#   ai-ml-setup

{ config, lib, pkgs, ... }:

let
  aiEnabled = config.system.config.ai.enable;
  gpu       = config.system.config.hardware.gpu;
  username  = config.system.config.user.name;

  # PyTorch wheel index per GPU backend.
  torchIndex =
    if gpu == "nvidia" then "https://download.pytorch.org/whl/cu121"
    else if gpu == "amd" then "https://download.pytorch.org/whl/rocm5.7"
    else "https://download.pytorch.org/whl/cpu";

  # TensorFlow package name per GPU backend.
  tfPackage =
    if gpu == "nvidia" then "tensorflow[and-cuda]"
    else if gpu == "amd"  then "tensorflow-rocm"
    else "tensorflow";

  mlSetupScript = pkgs.writeShellScriptBin "ai-ml-setup" ''
    set -euo pipefail

    PYTHON=${pkgs.python3}/bin/python3

    echo "=== AI/ML venv setup ==="

    # ── QC venv: quantum computing libraries ──────────────────────────────────
    if [ ! -d /data/python/venvs/qc ]; then
      echo "→ Creating QC venv at /data/python/venvs/qc ..."
      "$PYTHON" -m venv /data/python/venvs/qc
      /data/python/venvs/qc/bin/pip install --upgrade pip
      /data/python/venvs/qc/bin/pip install \
        qutip \
        pyqucomp \
        qiskit \
        qiskit-aer \
        cirq \
        pennylane \
        openfermion
      echo "✓ QC venv ready"
      echo "  Activate: source /data/python/venvs/qc/bin/activate"
    else
      echo "  QC venv already exists — skipping (delete to recreate)"
    fi

    # ── ML venv: deep learning + TTS ─────────────────────────────────────────
    if [ ! -d /data/python/venvs/ml ]; then
      echo "→ Creating ML venv at /data/python/venvs/ml (downloading PyTorch — may take a while) ..."
      "$PYTHON" -m venv /data/python/venvs/ml
      /data/python/venvs/ml/bin/pip install --upgrade pip

      # PyTorch (GPU-specific wheel index)
      /data/python/venvs/ml/bin/pip install \
        torch torchvision torchaudio \
        --index-url ${torchIndex}

      # TensorFlow
      /data/python/venvs/ml/bin/pip install ${tfPackage}

      # Kokoro TTS (neural TTS, ~1 GB VRAM when on GPU)
      /data/python/venvs/ml/bin/pip install kokoro soundfile

      # General ML tooling
      /data/python/venvs/ml/bin/pip install \
        scikit-learn \
        pandas \
        xgboost \
        jupyter \
        ipykernel \
        transformers \
        accelerate \
        datasets \
        peft

      # Register as Jupyter kernel
      /data/python/venvs/ml/bin/python -m ipykernel install \
        --user --name ml --display-name "ML (PyTorch + TF)"

      echo "✓ ML venv ready"
      echo "  Activate: source /data/python/venvs/ml/bin/activate"
      echo "  Kokoro TTS available inside this venv"
    else
      echo "  ML venv already exists — skipping (delete to recreate)"
    fi

    echo ""
    echo "=== Setup complete ==="
    echo "QC venv : /data/python/venvs/qc"
    echo "ML venv : /data/python/venvs/ml"
    echo "Quantum Espresso: available system-wide as 'pw.x', 'ph.x', etc."
    echo "Piper TTS       : available system-wide as 'piper'"
  '';

in

{
  config = lib.mkIf aiEnabled {

    environment.systemPackages = with pkgs; [
      # ── Quantum Chemistry / DFT ───────────────────────────────────────────
      quantum-espresso    # pw.x, ph.x, cp.x — plane-wave DFT (MPI-enabled)
      openmpi             # MPI runtime for parallel QE runs
      gnuplot             # plotting for QE output (xcrysden, vesta are also options)

      # ── Scientific Python (system-wide, fast imports without venv) ────────
      (python3.withPackages (ps: with ps; [
        numpy
        scipy
        sympy
        matplotlib
        qutip          # quantum systems simulation
        ipython
        jupyterlab
        notebook
      ]))

      # ── Lightweight TTS (CPU, no GPU needed) ─────────────────────────────
      piper-tts          # fast neural TTS; models downloaded to ~/.local/share/piper

      # ── Venv initialiser ─────────────────────────────────────────────────
      mlSetupScript
    ];

    # Venv directories in /data (created before ai-ml-setup is run).
    systemd.tmpfiles.rules = [
      "d /data/python/venvs/qc 0755 ${username} users -"
      "d /data/python/venvs/ml 0755 ${username} users -"
    ];

    # MPI jobs can use all cores by default.
    environment.variables.OMPI_MCA_btl_vader_single_copy_mechanism = "none";
  };
}
