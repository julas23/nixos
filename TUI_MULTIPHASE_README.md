# Multi-Phase TUI Installer

## Overview

**Calamares-style text mode installer** with multi-phase tab navigation, dataclasses architecture, and JSON persistence.

## Features

### Multi-Phase Installation

```
╔════════════════════════════════════════════════════════════════╗
║              NIXOS MULTI-PHASE INSTALLER                       ║
║ CPU: AMD Ryzen 9 | Cores: 16 | RAM: 64 GB                     ║
║ GPU: NVIDIA GeForce RTX 3080                                   ║
║ Disks: nvme0n1(1TB), sda(2TB)                                  ║
║ Network: 192.168.1.100                                         ║
╠════════════════════════════════════════════════════════════════╣
 ✓ Network | ○ User | ○ Disk | ○ Environment | ○ Desktop | ○ Review
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║ [Phase content here]                                           ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║ Ctrl+←/→: Switch tabs | Tab/Enter: Navigate | Esc: Abort      ║
║         [F10] Abort  [F2] Back  [F3] Next  [F4] Finish        ║
╚════════════════════════════════════════════════════════════════╝
```

### Six Installation Phases

1. **Network**: Check connectivity, configure WiFi/Ethernet
2. **User**: Username, full name, groups, sudo, root password
3. **Disk**: Select disk, LVM/ZFS, filesystem, mountpoint
4. **Environment**: Graphics server (Wayland/Xorg), Desktop environment
5. **Desktop**: Package stack, custom packages
6. **Review**: Complete overview before installation

### Architecture

- **Dataclasses**: Type-safe configuration with validation
- **JSON Persistence**: Save/load installation profiles
- **Phase Validation**: Each phase validates before proceeding
- **Tab Navigation**: Ctrl+Left/Right to switch phases
- **Zero Dependencies**: Pure Python stdlib (curses + json + dataclasses)

## Usage

### Basic Usage

```bash
# Make executable
chmod +x tui_installer_multiphase.py

# Run the installer
python3 tui_installer_multiphase.py
```

### Keyboard Controls

| Key | Action |
|-----|--------|
| **Ctrl+←** | Previous tab |
| **Ctrl+→** | Next tab |
| **↑/↓** | Navigate within phase |
| **Enter** | Edit selected field |
| **F2** | Back to previous phase |
| **F3** | Next phase (validates current) |
| **F4** | Finish installation |
| **F10/Esc** | Abort installation |

### Phase-Specific Controls

#### Network Phase
- **c**: Check network status
- **n**: Open nmtui for network configuration

#### User Phase
- **Enter**: Edit username, full name, etc.

#### Disk Phase
- **Enter**: Select disk from list
- **d**: Change disk selection

#### Environment Phase
- **↑/↓**: Navigate graphics/desktop options
- **Enter**: Select option

## Output

### JSON Configuration File

Configuration is saved to `/tmp/nixos_install_config.json`:

```json
{
  "network": {
    "status": "online",
    "interface": "eth0",
    "ip": "192.168.1.100",
    "validated": true
  },
  "user": {
    "username": "julas",
    "fullname": "Julas Silva",
    "uid": 1000,
    "groups": ["wheel"],
    "sudoer": true,
    "validated": true
  },
  "disks": [
    {
      "device": "/dev/nvme0n1",
      "size": "1T",
      "lvm": false,
      "filesystem": "ext4",
      "mountpoint": "/",
      "validated": true
    }
  ],
  "environment": {
    "graphics": "wayland",
    "desktop": "cosmic",
    "validated": true
  },
  "desktop": {
    "stack": [],
    "custom_packages": [],
    "validated": true
  }
}
```

### Shell Variables

Also outputs shell variables for integration:

```bash
hostname='julas-nixos'
username='julas'
fullname='Julas Silva'
disk='/dev/nvme0n1'
filesystem='ext4'
graphics='wayland'
desktop='cosmic'
```

## Integration with install.sh

### Option 1: Use TUI for Configuration

```bash
#!/usr/bin/env bash
# install.sh

# Run TUI configurator
python3 tui_installer_multiphase.py > /tmp/config_vars.sh

if [ $? -eq 0 ]; then
    # Source the variables
    source /tmp/config_vars.sh
    
    # Load JSON for detailed config
    CONFIG_JSON="/tmp/nixos_install_config.json"
    
    # Continue with installation using the variables
    echo "Installing NixOS for user: $username"
    echo "Disk: $disk"
    echo "Desktop: $desktop"
    
    # ... rest of installation
else
    echo "Configuration cancelled"
    exit 1
fi
```

### Option 2: Load JSON Configuration

```bash
# Parse JSON with Python
python3 << 'EOF'
import json
with open('/tmp/nixos_install_config.json', 'r') as f:
    config = json.load(f)
    print(f"username='{config['user']['username']}'")
    print(f"disk='{config['disks'][0]['device']}'")
    # ... etc
EOF
```

## Configuration Classes

### NetworkConfig
- `status`: "online", "offline", "checking"
- `interface`: Network interface name
- `ip`, `gateway`, `dns`: Network details
- `validated`: Phase completion status

### UserConfig
- `username`, `fullname`: User identity
- `uid`, `gid`, `group_name`: User IDs
- `groups`: List of additional groups
- `sudoer`, `nopasswd`: Sudo configuration
- `root_password_set`: Root password status
- `validated`: Phase completion

### DiskConfig
- `device`, `size`, `model`: Disk information
- `lvm`, `zfs`: Volume management
- `vg_name`, `lv_name`: LVM names
- `filesystem`: ext4, xfs, btrfs, etc.
- `mountpoint`: Mount location
- `validated`: Configuration status

### EnvironmentConfig
- `graphics`: "wayland", "xorg", "text"
- `desktop`: Desktop environment name
- `description`: Environment description
- `validated`: Selection status

### DesktopConfig
- `stack`: Default package list
- `custom_packages`: User-added packages
- `validated`: Configuration status

## Validation

Each phase validates before allowing progression:

- **Network**: Must be online
- **User**: Username ≥3 chars, full name required
- **Disk**: At least one disk, root (/) mountpoint required
- **Environment**: Desktop environment selected
- **Desktop**: Always valid (packages optional)
- **Review**: All phases must be validated

## Testing

### Test in NixOS Live USB

```bash
# 1. Boot NixOS Live USB

# 2. Download
curl -o /tmp/tui_multiphase.py \
  https://raw.githubusercontent.com/julas23/nixos/main/tui_installer_multiphase.py

# 3. Run
chmod +x /tmp/tui_multiphase.py
python3 /tmp/tui_multiphase.py

# 4. Navigate through phases
#    - Ctrl+Right to next phase
#    - Enter to edit fields
#    - F3 to validate and advance
#    - F4 to finish

# 5. Check output
cat /tmp/nixos_install_config.json
```

## Advantages Over Single-Screen TUI

### Old Approach (Single Screen)
- All options on one screen
- Cluttered interface
- Hard to organize logically
- No validation flow

### New Approach (Multi-Phase)
- ✅ Organized by logical phases
- ✅ Clear progression (Network → User → Disk → etc.)
- ✅ Validation per phase
- ✅ Review phase for final check
- ✅ Professional workflow
- ✅ Similar to Calamares/Anaconda

## Comparison: bash vs TUI Multiphase

| Aspect | bash install.sh | TUI Multiphase |
|--------|-----------------|----------------|
| **Interface** | Sequential prompts | Multi-phase tabs |
| **Navigation** | Linear only | Free navigation |
| **Validation** | Per-prompt | Per-phase |
| **Review** | No overview | Complete review phase |
| **Corrections** | Must restart | Navigate back anytime |
| **Profiles** | No | JSON save/load |
| **Professional** | Basic | Very professional |

## Future Enhancements

### Planned Features

1. **Password Fields**: Secure password input with masking
2. **Network Scanning**: WiFi SSID scanning and selection
3. **Advanced Partitioning**: Multiple partitions, custom layouts
4. **LVM/ZFS Wizard**: Guided volume setup
5. **Package Search**: Search and add packages
6. **Profile Management**: Save/load installation profiles
7. **Progress Tracking**: Real-time installation progress
8. **Help System**: F1 for context-sensitive help

### Potential Additions

- **Locale Configuration**: Timezone, keymap, locale in separate phase
- **Services**: Enable/disable system services
- **Bootloader**: GRUB/systemd-boot configuration
- **Encryption**: LUKS disk encryption setup
- **Multi-Disk**: Configure multiple disks with different purposes

## Technical Details

### File Structure

```
nixos/
├── install.sh                          # Bash installer (stable)
├── tui_installer.py                    # Single-screen TUI (prototype)
├── tui_installer_multiphase.py         # Multi-phase TUI (new)
├── TUI_MULTIPHASE_README.md            # This file
└── modules/
    ├── base.nix
    ├── vars.nix
    └── ...
```

### Code Structure

```python
# Configuration (dataclasses)
@dataclass
class NetworkConfig: ...
@dataclass
class UserConfig: ...
@dataclass
class DiskConfig: ...
@dataclass
class EnvironmentConfig: ...
@dataclass
class DesktopConfig: ...
@dataclass
class InstallConfig: ...

# System info
def get_system_info() -> dict: ...
def check_network_status() -> str: ...

# Drawing functions
def draw_header(stdscr, system_info): ...
def draw_tabs(stdscr, row, phases, current, config): ...
def draw_footer(stdscr, can_back, can_next, can_finish): ...

# Phase implementations
def draw_network_phase(...): ...
def draw_user_phase(...): ...
def draw_disk_phase(...): ...
def draw_environment_phase(...): ...
def draw_desktop_phase(...): ...
def draw_review_phase(...): ...

# Main class
class MultiPhaseInstaller:
    def run(self, stdscr): ...
    def handle_enter(self, stdscr): ...
    def edit_user_field(self, stdscr): ...
    def edit_disk_field(self, stdscr): ...
    def edit_environment_field(self): ...
```

**Total Lines**: ~850 lines (well-structured and documented)

## Troubleshooting

### Terminal Issues

**Problem**: Display not rendering correctly

**Solution**: Ensure terminal supports UTF-8 and box-drawing characters

```bash
export TERM=xterm-256color
python3 tui_installer_multiphase.py
```

### Network Configuration

**Problem**: nmtui not available

**Solution**: Use manual network configuration or skip network phase

### Validation Errors

**Problem**: Can't proceed to next phase

**Solution**: Check validation requirements for current phase (shown in error message)

## Development Status

### Current Status: Beta ✅

- ✅ All 6 phases implemented
- ✅ Tab navigation working
- ✅ Dataclasses + JSON architecture
- ✅ Phase validation
- ✅ Configuration persistence
- ✅ Review phase
- ⏳ Password input (planned)
- ⏳ WiFi scanning (planned)
- ⏳ Advanced disk setup (planned)

### Ready For

- ✅ Testing in NixOS Live USB
- ✅ Feedback collection
- ✅ Integration with install.sh
- ⏳ Production use (after testing)

## Contributing

This is an active development feature. Contributions welcome!

### How to Help

1. **Test**: Run in NixOS Live USB and report issues
2. **Feedback**: Suggest improvements to workflow
3. **Features**: Propose new phases or enhancements
4. **Code**: Submit pull requests

## License

Same as the main NixOS configuration repository.

---

**Status**: Beta - Ready for testing  
**Last Updated**: 2026-02-12  
**Architecture**: Dataclasses + JSON  
**Dependencies**: Python 3.7+ stdlib only  
**Compatibility**: NixOS Minimal ISO
