# Julas NixOS Configuration

This repository contains my unified NixOS configurations for multiple devices (HP Laptop, Thinkpad, Ryzen Desktop, and AI Server).

## 🚀 Quick Installation

After booting from the NixOS Live USB, follow the steps below:

### 1. Connect to the Internet
If you are using Wi-Fi, use the interactive command:
```bash
nmtui
```
*Or via direct command:*
```bash
nmcli device wifi connect "NETWORK_NAME" password "YOUR_PASSWORD"
```

### 2. Run the Installer
Once connected, run the command below to start the automatic provisioning:

```bash
sudo curl -L https://raw.githubusercontent.com/julas23/nixos/main/install.sh -o install.sh && chmod +x install.sh && sudo ./install.sh
```

## 🛠️ What does the script do?
1. **Partitioning**: Configures the selected disk (EFI + Root).
2. **Cloning**: Downloads this repository to `/mnt/etc/nixos`.
3. **Hardware**: Generates `hardware-configuration.nix` locally.
4. **Configuration**: Prompts for your username, hostname, GPU, and desired Desktop.
5. **Installation**: Finalizes with `nixos-install`.

## 🖥️ Supported Environments
- **Desktops**: Cosmic, Hyprland, Gnome, XFCE, Mate, i3, Awesome.
- **Hardware**: AMDGPU, NVIDIA, Intel, VM.
- **Services**: Docker, Ollama (AI), PostgreSQL, Stable Diffusion.
