# Modular NixOS Configuration

A clean, modular, and professional NixOS configuration system with centralized configuration management.

## ✨ Features

- **Highly Modular**: Every component is in its own module
- **Centralized Configuration**: Single source of truth in `modules/config.nix`
- **Profile-Based**: Pre-configured profiles for different use cases
- **Flakes Support**: Modern Nix flakes for reproducibility
- **Conditional Activation**: Modules activate based on configuration
- **Well-Documented**: Clear structure and documentation

## 📁 Directory Structure

```
nixos/
├── configuration.nix          # Main entry point
├── flake.nix                  # Flakes configuration
├── hardware-configuration.nix # Generated hardware config
│
├── modules/
│   ├── config.nix            # ⭐ Centralized configuration
│   │
│   ├── core/                 # Core system modules
│   │   ├── boot.nix
│   │   ├── network.nix
│   │   ├── nix.nix
│   │   └── system.nix
│   │
│   ├── locale/               # 🌍 Regional settings
│   │   ├── timezone.nix
│   │   ├── i18n.nix
│   │   ├── console.nix
│   │   └── xkb.nix
│   │
│   ├── hardware/             # 🖥️ Hardware support
│   │   ├── gpu/ (amd, nvidia, intel)
│   │   ├── audio.nix
│   │   ├── bluetooth.nix
│   │   └── printing.nix
│   │
│   ├── graphics/             # Display servers
│   │   ├── wayland.nix
│   │   └── xorg.nix
│   │
│   ├── desktop/              # 🎨 Desktop environments
│   │   ├── cosmic.nix
│   │   ├── gnome.nix
│   │   ├── hyprland.nix
│   │   ├── i3.nix
│   │   ├── xfce.nix
│   │   └── awesome.nix
│   │
│   ├── services/             # 🔧 System services
│   │   ├── docker.nix
│   │   ├── ollama.nix
│   │   └── ssh.nix
│   │
│   ├── storage/              # 💾 Storage management
│   │   ├── lvm.nix
│   │   └── zfs.nix
│   │
│   └── users/                # 👤 User management
│       └── default.nix
│
└── profiles/                 # 📦 Pre-configured profiles
    ├── minimal.nix
    ├── desktop.nix
    ├── server.nix
    └── developer.nix
```

## 🚀 Quick Start

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

## 📦 Using Profiles

### With Flakes

```bash
sudo nixos-rebuild switch --flake .#desktop
```

### Without Flakes

Uncomment in `configuration.nix`:

```nix
imports = [
  # ...
  ./profiles/desktop.nix
];
```

**Available Profiles:**
- `minimal` - Bare minimum (no GUI)
- `desktop` - Full workstation
- `server` - Headless server
- `developer` - Dev environment

## ⚙️ Configuration Options

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
  gpu = "amd";  # amd | nvidia | intel
  audio.enable = true;
  bluetooth.enable = false;
};
```

### Graphics

```nix
graphics = {
  server = "wayland";
  desktop = "cosmic";
};
```

### Services

```nix
services = {
  docker.enable = true;
  ollama.enable = false;
  ssh.enable = true;
};
```

### User

```nix
user = {
  name = "user";
  fullName = "User Name";
  extraGroups = [ "wheel" "networkmanager" ];
  sudoer = true;
  shell = "bash";
};
```

## 🔧 How It Works

### Centralized Configuration

All settings in `modules/config.nix` - single source of truth.

### Conditional Activation

Modules activate automatically based on configuration:

```nix
let
  enabled = config.system.config.hardware.gpu == "amd";
in
{
  config = lib.mkIf enabled {
    # AMD configuration
  };
}
```

## 🛠️ Maintenance

```bash
# Update system
sudo nixos-rebuild switch

# Garbage collection
sudo nix-collect-garbage -d

# Check configuration
sudo nixos-rebuild dry-build
```

## 📝 License

MIT License

## 👤 Author

Created by julas23
