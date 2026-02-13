# NixOS TUI Installer

Multi-phase text user interface installer for NixOS with responsive design and framebuffer support.

## Features

- **6-Phase Installation Workflow**: Network → User → Disk → Environment → Desktop → Review
- **Responsive Design**: Adapts to terminal size (25-60+ lines)
- **Framebuffer Support**: Optimized for high-resolution console
- **Tab Navigation**: Free navigation between phases
- **Phase Validation**: Ensures complete configuration
- **JSON Persistence**: Save/load installation profiles
- **Zero Dependencies**: Pure Python stdlib

## Quick Start

### Download and Run

```bash
# Download
curl -o /tmp/installer.py \
  https://raw.githubusercontent.com/julas23/nixos/main/installer.py

# Run
chmod +x /tmp/installer.py
python3 /tmp/installer.py
```

## Recommended: Enable Framebuffer Console

For the best experience (40-60 lines instead of 25):

### At Boot (Temporary)
1. Boot NixOS ISO
2. Press 'e' at GRUB menu
3. Add to kernel line: `vga=791`
4. Press F10 to boot

### After Installation (Permanent)
Add to `/etc/nixos/configuration.nix`:
```nix
boot.kernelParams = [ "vga=791" ];  # 1024x768 (40-50 lines)
```

### Resolution Options
- `vga=791`: 1024x768 (40-50 lines) ← **Recommended**
- `vga=792`: 1280x1024 (60-70 lines)
- `vga=794`: 1600x1200 (80+ lines)

## Keyboard Controls

| Key | Action |
|-----|--------|
| **Ctrl+←/→** | Switch between phases |
| **↑/↓** | Navigate within phase |
| **Enter** | Edit selected field |
| **F2** | Back to previous phase |
| **F3** | Next phase (validates current) |
| **F4** | Finish installation |
| **F10/Esc** | Abort installation |

### Phase-Specific Keys
- **Network**: `c` = check status, `n` = configure (nmtui)
- **Disk**: `d` = change disk selection
- **Desktop**: `a` = add custom packages

## Installation Phases

### 1. Network
- Automatic connectivity detection
- Manual configuration via nmtui
- Validation: Must be online

### 2. User
- Username and full name
- UID/GID configuration
- Group membership
- Sudo and root password
- Validation: Username ≥3 chars, full name required

### 3. Disk
- Interactive disk selection
- LVM/ZFS options
- Filesystem selection (ext4, xfs, btrfs)
- Mountpoint configuration
- Validation: Root (/) mountpoint required

### 4. Environment
- Graphics server (Wayland/Xorg/Text)
- Desktop environment selection
- Platform-specific options
- Validation: Desktop must be selected

### 5. Desktop
- Default package stack
- Custom package addition
- Platform validation

### 6. Review
- Complete configuration overview
- Edit any phase before installation
- Final confirmation

## Output

### JSON Configuration
Saved to `/tmp/nixos_install_config.json`:
```json
{
  "network": {"status": "online", "ip": "192.168.1.100", ...},
  "user": {"username": "julas", "fullname": "Julas Silva", ...},
  "disks": [{"device": "/dev/nvme0n1", "filesystem": "ext4", ...}],
  "environment": {"graphics": "wayland", "desktop": "cosmic", ...},
  "desktop": {"stack": [...], "custom_packages": [...]}
}
```

### Shell Variables
Also printed to stdout:
```bash
hostname='julas-nixos'
username='julas'
fullname='Julas Silva'
disk='/dev/nvme0n1'
filesystem='ext4'
graphics='wayland'
desktop='cosmic'
```

## Responsive Design

The installer automatically adapts to terminal size:

### Compact Mode (< 30 lines)
- Minimal header (3 lines)
- Abbreviated tab names
- Compact help text
- ~18 lines for content

### Normal Mode (30-44 lines)
- Standard header (7 lines)
- Full tab names
- Complete help text
- ~25 lines for content

### Expanded Mode (45+ lines)
- Detailed header (11 lines)
- Extra system information
- Full descriptions
- ~35+ lines for content

## Integration with install.sh

```bash
#!/usr/bin/env bash

# Run TUI configurator
python3 installer.py > /tmp/config_vars.sh

if [ $? -eq 0 ]; then
    # Source variables
    source /tmp/config_vars.sh
    
    # Load JSON for detailed config
    CONFIG_JSON="/tmp/nixos_install_config.json"
    
    # Continue with installation
    echo "Installing NixOS for user: $username"
    echo "Disk: $disk"
    echo "Desktop: $desktop"
    
    # ... rest of installation
else
    echo "Configuration cancelled"
    exit 1
fi
```

## Architecture

- **Dataclasses**: Type-safe configuration with validation
- **JSON**: Human-readable persistence
- **Curses**: Terminal UI with full control
- **Responsive**: Adapts to any terminal size
- **Modular**: Clean phase-based structure

## Requirements

- Python 3.7+ (included in NixOS ISO)
- Terminal with UTF-8 support
- Minimum 80×25 terminal (works, but cramped)
- Recommended 80×40+ terminal (framebuffer)

## Troubleshooting

### Terminal looks weird
```bash
export TERM=xterm-256color
python3 installer.py
```

### Can't proceed from Network phase
Network must be online. Configure manually:
```bash
# WiFi
nmcli device wifi connect "SSID" password "PASSWORD"

# Or use nmtui
nmtui
```

### Validation errors
Check requirements for each phase:
- Network: Must be online
- User: Username ≥3 chars, full name required
- Disk: Root (/) mountpoint required
- Environment: Desktop must be selected

## Development

### File Structure
```
nixos/
├── install.sh              # Bash installer (stable)
├── installer.py            # TUI installer (new)
├── INSTALLER_README.md     # This file
└── modules/
    ├── base.nix
    ├── vars.nix
    └── ...
```

### Code Structure
- ~1000 lines of well-structured Python
- Type hints throughout
- Responsive design system
- Phase-based architecture
- JSON configuration persistence

## Status

**Beta** - Ready for testing in NixOS Live USB

Tested on:
- NixOS Minimal ISO
- Various terminal sizes (25-60 lines)
- Framebuffer and standard console

## License

Same as the main NixOS configuration repository.

---

**Last Updated**: 2026-02-12  
**Version**: 1.0  
**Repository**: https://github.com/julas23/nixos
