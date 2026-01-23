# Identificar discos
lsblk

# Particionar NVMe 1 (120GB)
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary 1GiB 50GiB
sudo parted /dev/nvme0n1 -- mkpart primary 50GiB 110GiB

# Formatá-las
sudo mkfs.fat -F 32 /dev/nvme0n1p1 -n BOOT
sudo mkfs.ext4 /dev/nvme0n1p2 -L NIXROOT
sudo mkfs.ext4 /dev/nvme0n1p3 -L NIXSTORE

# Montar
sudo mount /dev/nvme0n1p2 /mnt
sudo mkdir -p /mnt/boot /mnt/nix
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo mount /dev/nvme0n1p3 /mnt/nix

# Particionar NVMe 2 (2TB) para modelos
sudo parted /dev/nvme1n1 -- mklabel gpt
sudo parted /dev/nvme1n1 -- mkpart primary 0% 100%
sudo mkfs.btrfs -f -L MODELS /dev/nvme1n1p1
sudo mkdir -p /mnt/models
sudo mount -o compress=zstd:3,noatime /dev/nvme1n1p1 /mnt/models

# Repetir para NVMe 3 (dados)
sudo parted /dev/nvme2n1 -- mklabel gpt
sudo parted /dev/nvme2n1 -- mkpart primary 0% 100%
sudo mkfs.btrfs -f -L DATA /dev/nvme2n1p1
sudo mkdir -p /mnt/data
sudo mount -o compress=zstd:1,noatime /dev/nvme2n1p1 /mnt/data
