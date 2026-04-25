# Modular NixOS Configuration

A clean, modular, and professional NixOS configuration system with centralized configuration management.

## Features

- **Highly Modular**: Every component is in its own module
- **Centralized Configuration**: Single source of truth in `modules/config.nix`
- **Profile-Based**: Pre-configured profiles for different use cases
- **Conditional Activation**: Modules activate based on configuration
- **AppImage Support**: binfmt registration + auto-download of managed AppImages
- **Storage Management**: External volume mounts + `/data` directory layout for package managers
- **Security Toolkit**: Optional OSINT/pentest module with comprehensive tooling

## Directory Structure

```
nixos/
├── configuration.nix          # Main entry point
├── hardware-configuration.nix # Generated hardware config (not tracked)
│
├── modules/
│   ├── config.nix            # ⭐ Centralized configuration
│   ├── packages.nix          # System-wide packages (7 categories)
│   ├── appimage.nix          # AppImage binfmt + managed apps
│   │
│   ├── core/                 # Core system modules
│   │   ├── boot.nix
│   │   ├── network.nix
│   │   ├── nix.nix
│   │   └── system.nix
│   │
│   ├── locale/               # Regional settings
│   │   ├── default.nix
│   │   ├── timezone.nix
│   │   ├── i18n.nix
│   │   ├── console.nix
│   │   └── xkb.nix
│   │
│   ├── hardware/             # Hardware support
│   │   ├── gpu/ (amd, nvidia, intel)
│   │   ├── audio.nix
│   │   ├── bluetooth.nix
│   │   └── printing.nix
│   │
│   ├── graphics/             # Display servers
│   │   ├── wayland.nix
│   │   └── xorg.nix
│   │
│   ├── desktop/              # Desktop environments
│   │   ├── fonts.nix
│   │   ├── cosmic.nix
│   │   ├── gnome.nix
│   │   ├── hyprland.nix
│   │   ├── i3.nix
│   │   ├── mate.nix
│   │   ├── xfce.nix
│   │   └── awesome.nix
│   │
│   ├── services/             # System services
│   │   ├── docker.nix
│   │   ├── ollama.nix
│   │   ├── claude.nix        # Claude Code CLI
│   │   ├── ssh.nix
│   │   └── lsyncd.nix        # Live sync to external volume
│   │
│   ├── storage/              # Storage management
│   │   ├── data.nix          # /data directory layout + env vars
│   │   ├── volumes.nix       # External mounts + bind mounts
│   │   ├── lvm.nix
│   │   └── zfs.nix
│   │
│   ├── users/                # User management
│   │   ├── default.nix
│   │   └── groups.nix
│   │
│   └── profiles/             # Optional feature profiles
│       ├── security.nix      # OSINT / pentest toolkit
│       └── SECURITY_README.md
│
├── profiles/                 # System profiles
│   ├── minimal.nix
│   ├── desktop.nix
│   ├── server.nix
│   └── developer.nix
│
├── dotfiles/
│   └── awesome/              # AwesomeWM dotfiles
│       ├── rc.lua
│       ├── dunstrc
│       └── picom.conf
│
└── install/                  # Interactive Python installer
    ├── configurator.py
    ├── lib/
    │   ├── config_generator.py
    │   └── validators.py
    └── data/                 # JSON data for installer options
```

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/julas23/nixos.git /etc/nixos
cd /etc/nixos
```

### 2. Configure Your System

Edit `modules/config.nix`:

```nix
system.config = {
  system.hostname = "my-nixos";

  locale = {
    timezone = "America/New_York";
    language = "en_US.UTF-8";
  };

  hardware.gpu = "amd";
  graphics = {
    server = "wayland";
    desktop = "cosmic";
  };

  user = {
    name = "myuser";
    fullName = "My Name";
  };
};
```

### 3. Build and Switch

```bash
sudo nixos-rebuild switch
```

## Using Profiles

Uncomment a profile in `configuration.nix`:

```nix
imports = [
  # ...
  ./profiles/desktop.nix
];
```

**Available Profiles:**
- `minimal` — Bare minimum (no GUI)
- `desktop` — Full workstation
- `server` — Headless server
- `developer` — Dev environment

## Configuration Options

### System

```nix
system = {
  hostname = "nixos";
  stateVersion = "24.11";
};
```

### Locale

```nix
locale = {
  timezone = "America/Miami";
  language = "en_US.UTF-8";
  keyboard = {
    console = "us";
    layout = "us";
    variant = "alt-intl";
  };
};
```

### Hardware

```nix
hardware = {
  gpu = "amd";  # amd | nvidia | intel | none
  audio = {
    enable = true;
    backend = "pipewire";  # pipewire | pulseaudio
  };
  bluetooth.enable = false;
  printing.enable = false;
};
```

### Graphics

```nix
graphics = {
  server = "wayland";  # wayland | xorg
  desktop = "cosmic";  # cosmic | gnome | hyprland | i3 | mate | xfce | awesome | none
};
```

### Services

```nix
services = {
  docker.enable = true;
  ollama.enable = false;
  claude.code.enable = false;  # installs claude-code from nixpkgs
  ssh = {
    enable = true;
    permitRootLogin = false;
  };
};
```

> **lsyncd** is enabled by its presence in `imports` rather than a flag — comment/uncomment
> `./modules/services/lsyncd.nix` in `configuration.nix` to toggle it.

### User

```nix
user = {
  name = "user";
  fullName = "User Name";
  uid = 1000;
  gid = 100;
  group = "users";
  extraGroups = [ "wheel" "networkmanager" ];
  sudoer = true;
  nopasswd = false;
  shell = "bash";  # bash | zsh | fish
};
```

### Network

```nix
network = {
  networkmanager.enable = true;
  firewall = {
    enable = true;
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };
};
```

### Boot

```nix
boot = {
  loader = "systemd-boot";  # systemd-boot | grub
  timeout = 5;
  quietBoot = true;
};
```

### Nix

```nix
nix = {
  flakes = true;
  autoOptimiseStore = true;
  gc = {
    enable = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
};
```

## Storage Layout

`modules/storage/data.nix` creates a `/data` directory tree that keeps package
managers and runtimes outside `$HOME`:

```
/data/
├── appimage/        AppImage binaries
├── docker/          Docker data root
├── python/
│   ├── venvs/
│   └── packages/    pip user installs (PYTHONUSERBASE)
├── node/
│   ├── npm/         npm global packages
│   └── yarn/        yarn global packages
├── rust/
│   ├── cargo/       Cargo registry and binaries
│   └── rustup/      Rust toolchains
├── flatpak/
└── projects/
```

Environment variables (`CARGO_HOME`, `NPM_CONFIG_PREFIX`, etc.) are set
system-wide via `/etc/profile.d/data-dirs.sh`.

`modules/storage/volumes.nix` mounts external volumes (`/mnt/DOCK`, `/mnt/NVME`)
and creates bind mounts so Docker, Node, Python, and Rust data persist across
NixOS rebuilds.

## AppImage Support

`modules/appimage.nix` enables `binfmt` so AppImages run directly without a
wrapper, and provides a systemd one-shot service that downloads the following
managed AppImages on first boot:

| App | Category |
|-----|----------|
| Wavebox | Productivity browser |
| Simplenote | Note-taking |
| AnthemScore | Music transcription |

AppImages are stored in `/data/appimage/` and `.desktop` entries are created
automatically in `~/.local/share/applications/`.

A helper script `run-appimage` is also available for running arbitrary AppImages
with the correct library path.

## Security / OSINT Module

`modules/profiles/security.nix` is an optional import that installs a
comprehensive toolkit organized into 13 categories:

1. OSINT (theHarvester, recon-ng, spiderfoot, amass, subfinder…)
2. SOCMINT (sherlock, yt-dlp…)
3. Network sniffing (Wireshark, Bettercap, Aircrack-ng…)
4. Brute force / password cracking (Hydra, Hashcat, John…)
5. Penetration testing frameworks (Metasploit, OWASP ZAP, sqlmap…)
6. Vulnerability scanning (nmap, Rustscan, Lynis…)
7. Privacy / anonymity (Tor, WireGuard, ProxyChains…)
8. Reconnaissance & enumeration (enum4linux, smbmap…)
9. Social engineering helpers
10. Post-exploitation (pwncat, CrackMapExec…)
11. Forensics (Binwalk, Volatility3, Steghide…)
12. Reverse engineering (Radare2, Ghidra)
13. Utilities (netcat, socat, sslscan, Python security libs…)

> These tools are for authorized security research, CTF competitions, and
> penetration testing engagements only. Unauthorized use may be illegal.

## Additional Features

- **nix-ld**: enabled in `packages.nix` so unpatched binaries run without
  manual patching
- **Flatpak**: system Flatpak service enabled; user data redirected to
  `/data/flatpak`
- **Android Debug Bridge**: `programs.adb.enable = true`
- **Scientific Python**: bundled environment with NumPy, SciPy, TensorFlow,
  PyTorch, Jupyter, and more

## Maintenance

```bash
# Rebuild and switch
sudo nixos-rebuild switch

# Dry run (check without applying)
sudo nixos-rebuild dry-build

# Garbage collection
sudo nix-collect-garbage -d
```

## How It Works

All settings live in `modules/config.nix` — the single source of truth. Each
module reads from `config.system.config` and activates conditionally:

```nix
let
  enabled = config.system.config.hardware.gpu == "amd";
in
{
  config = lib.mkIf enabled {
    # AMD-specific configuration
  };
}
```

## License

MIT License

## Author

Created by julas23
