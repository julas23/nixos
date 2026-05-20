# AI Stack — Storage
#
# Two responsibilities:
#
# 1. /data mount (conditional on ai.enable)
#    When ai.enable = true, /data is mounted from a dedicated LVM RAID1 volume
#    (two 8 TB SATA drives mirrored). When ai.enable = false, /data is just a
#    directory on the root fs, created by modules/storage/data.nix as usual.
#
#    First-time setup (run once, before or after nixos-rebuild switch):
#      sudo ai-storage-setup /dev/sdX /dev/sdY
#    Then reboot so NixOS mounts the new volume at /data.
#
# 2. /data/ai directory tree
#    Created by systemd-tmpfiles (idempotent). Works whether /data is on root
#    or on the LVM volume — tmpfiles always run after filesystems are mounted.
#
# Layout:
#   /data/ai/
#   ├── models/
#   │   ├── ollama/          Ollama model blobs   (OLLAMA_MODELS)
#   │   ├── huggingface/     HuggingFace cache    (HF_HOME)
#   │   └── comfyui/         SD checkpoints, LoRAs, VAE
#   ├── comfyui/output/      Generated images
#   ├── comfyui/custom_nodes/
#   ├── open-webui/          OpenWebUI database + uploads
#   ├── litellm/             LiteLLM config.yaml
#   └── mcp-servers/         MCP server scripts

{ config, lib, pkgs, ... }:

let
  aiEnabled = config.system.config.ai.enable;
  dataCfg   = config.system.config.ai.data;
  username  = config.system.config.user.name;

  aiDirs = [
    "/data/ai"
    "/data/ai/models"
    "/data/ai/models/ollama"
    "/data/ai/models/huggingface"
    "/data/ai/models/comfyui"
    "/data/ai/models/comfyui/checkpoints"
    "/data/ai/models/comfyui/loras"
    "/data/ai/models/comfyui/vae"
    "/data/ai/comfyui"
    "/data/ai/comfyui/output"
    "/data/ai/comfyui/custom_nodes"
    "/data/ai/open-webui"
    "/data/ai/litellm"
    "/data/ai/mcp-servers"
  ];

  # One-time helper that creates the LVM RAID1 volume on two physical disks.
  # Run as root before (or after) setting ai.enable = true; then reboot.
  storageSetupScript = pkgs.writeShellScriptBin "ai-storage-setup" ''
    set -euo pipefail

    DISK1="''${1:-}"
    DISK2="''${2:-}"

    if [ -z "$DISK1" ] || [ -z "$DISK2" ]; then
      echo "Usage: sudo ai-storage-setup <disk1> <disk2>"
      echo "  e.g: sudo ai-storage-setup /dev/sdb /dev/sdc"
      echo ""
      echo "This creates a RAID1 LVM volume at /dev/vg-data/data."
      echo "After running, reboot so NixOS mounts /data from the new volume."
      exit 1
    fi

    VG="vg-data"
    LV="data"
    DEV="/dev/$VG/$LV"

    echo "=== AI Storage Setup: LVM RAID1 on $DISK1 + $DISK2 ==="
    echo ""
    echo "  Volume group : $VG"
    echo "  Logical vol  : $LV  →  $DEV"
    echo "  Mirror       : RAID1 (2 copies, 1 failure tolerated)"
    echo ""
    echo "WARNING: ALL DATA on $DISK1 and $DISK2 will be erased."
    read -r -p "Continue? [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

    echo "→ Creating physical volumes..."
    pvcreate "$DISK1" "$DISK2"

    echo "→ Creating volume group $VG..."
    vgcreate "$VG" "$DISK1" "$DISK2"

    echo "→ Creating RAID1 logical volume (this takes a moment to synchronise)..."
    lvcreate --type raid1 -m 1 -l 100%FREE -n "$LV" "$VG"

    echo "→ Formatting with ext4..."
    mkfs.ext4 -L ai-data "$DEV"

    UUID=$(blkid -s UUID -o value "$DEV")
    echo ""
    echo "=== Done ==="
    echo "Device : $DEV"
    echo "UUID   : $UUID"
    echo ""
    echo "Next steps:"
    echo "  1. (Optional) Update modules/config.nix:"
    echo "       ai.data.device = \"/dev/disk/by-uuid/$UUID\";"
    echo "  2. sudo nixos-rebuild switch"
    echo "  3. reboot   ← /data will now be mounted from the LVM volume"
  '';
in

{
  config = lib.mkIf aiEnabled (lib.mkMerge [

    # ── 1. Mount /data from LVM RAID1 when ai is enabled ─────────────────────
    {
      # Kernel modules for LVM RAID1 (dm-mirror) needed in initrd.
      boot.initrd.kernelModules = [ "dm-mod" "dm-mirror" "dm-raid" ];

      # LVM userspace tools (pvs, vgs, lvs, pvdisplay, etc.).
      environment.systemPackages = with pkgs; [ lvm2 storageSetupScript ];

      # Declare the /data mount. nofail: if the LVM volume is not yet created
      # (first boot before ai-storage-setup), the system boots normally and
      # /data falls back to the tmpfiles directory on root.
      fileSystems."/data" = {
        device  = dataCfg.device;
        fsType  = dataCfg.fsType;
        options = [ "defaults" "nofail" "x-systemd.device-timeout=10s" ];
      };
    }

    # ── 2. /data/ai subdirectory tree (idempotent, runs after mount) ──────────
    {
      systemd.tmpfiles.rules =
        map (dir: "d ${dir} 0755 ${username} users -") aiDirs;
    }

    # ── 3. AI runtime environment variables ───────────────────────────────────
    {
      environment.sessionVariables = {
        OLLAMA_MODELS      = "/data/ai/models/ollama";
        HF_HOME            = "/data/ai/models/huggingface";
        TRANSFORMERS_CACHE = "/data/ai/models/huggingface";
      };

      environment.etc."profile.d/ai-dirs.sh".text = ''
        # AI stack environment — managed by modules/ai/storage.nix
        export OLLAMA_MODELS="/data/ai/models/ollama"
        export HF_HOME="/data/ai/models/huggingface"
        export TRANSFORMERS_CACHE="/data/ai/models/huggingface"
      '';
    }

  ]);
}
