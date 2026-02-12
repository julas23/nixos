# TUI Installer - Interactive Configuration Interface

## Overview

This is an experimental **Text User Interface (TUI)** installer for NixOS that provides a full-screen, interactive configuration experience. It's being developed in parallel with the existing bash-based `install.sh` script.

## Features

### Visual Full-Screen Interface

```
╔════════════════════════════════════════════════════════════════╗
║              NIXOS INSTALLATION CONFIGURATOR                   ║
║ CPU: AMD Ryzen 9 5950X | Cores: 32 | RAM: 64 GB               ║
║ Disks: nvme0n1(1TB), sda(2TB), sdb(4TB)                       ║
║ IP: 192.168.1.100                                              ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║ hostname     = [nixos________________________]                 ║
║ username     = [user_________________________]                 ║
║ video        = [nvidia] [amdgpu] [intel] [vm]                 ║
║ graphic      = [wayland] [xorg]                               ║
║ desktop      = [cosmic] [gnome] [hyprland] [i3] [xfce] ...   ║
║ ...                                                            ║
╠════════════════════════════════════════════════════════════════╣
║ ↑/↓: Navigate | Enter: Edit | Space: Select | F10: Continue   ║
╚════════════════════════════════════════════════════════════════╝
```

### Key Features

- **System Information Header**: Displays CPU, memory, disks, and network info
- **Interactive Navigation**: Arrow keys to move between options
- **Text Input Fields**: For hostname, username, etc.
- **Multiple Choice Buttons**: Visual selection for GPU, desktop, etc.
- **Custom Input Support**: Option to enter custom values
- **Real-time Visual Feedback**: Highlighting, colors, and emphasis
- **Professional Layout**: Box drawing characters and clean design

## Requirements

- **Python 3**: Already available in NixOS ISO
- **curses module**: Part of Python standard library (no installation needed)
- **Terminal**: Any standard terminal (TTY, SSH, etc.)

**Zero external dependencies!**

## Usage

### Basic Usage

```bash
# Make executable
chmod +x tui_installer.py

# Run the TUI configurator
python3 tui_installer.py
```

### Keyboard Controls

| Key | Action |
|-----|--------|
| **↑/↓** | Navigate between configuration options |
| **←/→** | Navigate between choices (when editing select fields) |
| **Enter** | Start editing current field |
| **Space** | Select option and exit edit mode |
| **Tab** | Move to next field |
| **Esc** | Cancel editing / Exit application |
| **F10** | Save configuration and continue |

### Navigation Flow

1. **Start**: Launch the TUI - system info is displayed in header
2. **Navigate**: Use ↑/↓ to move between configuration options
3. **Edit**: Press Enter on a field to start editing
4. **Select**: 
   - For text fields: Type your value and press Enter
   - For select fields: Use ←/→ to navigate options, Space to select
5. **Save**: Press F10 when done to save configuration
6. **Output**: Configuration is printed to stdout in shell variable format

### Example Session

```bash
# Run TUI and save configuration
python3 tui_installer.py > /tmp/nixos_config.sh

# Check if user cancelled (exit code 1)
if [ $? -eq 0 ]; then
    # Source the configuration
    source /tmp/nixos_config.sh
    
    # Use the variables
    echo "Hostname: $hostname"
    echo "Username: $username"
    echo "Desktop: $desktop"
    # ... continue with installation
else
    echo "Installation cancelled by user"
    exit 1
fi
```

## Configuration Options

The TUI configures all `install.system` options:

| Option | Type | Description |
|--------|------|-------------|
| `hostname` | Input | System hostname |
| `username` | Input | Primary username |
| `video` | Select | GPU driver (nvidia, amdgpu, intel, vm) |
| `graphic` | Select | Graphics server (wayland, xorg) |
| `desktop` | Select | Desktop environment |
| `locale` | Select | Locale profile (us, br, uk, fr, de, es, it, custom) |
| `localeCode` | Select | Full locale code (en_US.UTF-8, pt_BR.UTF-8, etc.) |
| `timezone` | Select | System timezone |
| `keymap` | Select | Console keyboard layout |
| `xkbLayout` | Select | X11/Wayland keyboard layout |
| `xkbVariant` | Select | X11/Wayland keyboard variant |
| `ollama` | Select | Enable Ollama AI (YES/NO) |
| `docker` | Select | Enable Docker (YES/NO) |

## Output Format

The TUI outputs configuration in shell variable format:

```bash
hostname='workstation'
username='julas'
video='amdgpu'
graphic='wayland'
desktop='cosmic'
locale='br'
localeCode='pt_BR.UTF-8'
timezone='America/Sao_Paulo'
keymap='br-abnt2'
xkbLayout='br'
xkbVariant='alt-intl'
ollama='NO'
docker='YES'
```

This can be directly sourced in bash scripts.

## Integration with install.sh

### Option 1: Standalone Mode

Keep TUI as a separate script that can be run independently:

```bash
# In install.sh
echo "Starting interactive configuration..."
python3 tui_installer.py > /tmp/nixos_config.sh

if [ $? -ne 0 ]; then
    log_error "Configuration cancelled"
    exit 1
fi

source /tmp/nixos_config.sh

# Continue with installation using the variables
log_step "Installing with hostname: $hostname"
```

### Option 2: Integrated Mode

Embed TUI in install.sh and use eval:

```bash
# In install.sh
eval "$(python3 tui_installer.py)"

if [ $? -ne 0 ]; then
    log_error "Configuration cancelled"
    exit 1
fi

# Variables are now available
HOSTNAME="$hostname"
USERNAME="$username"
```

## Development Status

### Current Status: Prototype ✅

The TUI is a **working prototype** with core functionality:

- ✅ System information header
- ✅ All configuration options
- ✅ Navigation (up/down/left/right)
- ✅ Text input fields
- ✅ Select fields with multiple options
- ✅ Visual feedback and highlighting
- ✅ Configuration output

### Planned Enhancements

Future improvements to be added:

1. **Disk Selection**: Integrate disk selection into TUI
2. **Password Fields**: Secure password input with masking
3. **Validation**: Real-time input validation with error messages
4. **Help Text**: Context-sensitive help (F1 key)
5. **Preview Screen**: Configuration review before confirmation
6. **Progress Indicator**: Show installation progress
7. **Multi-page Support**: Split into multiple pages if needed
8. **Color Themes**: Customizable color schemes

## Testing

### Test in NixOS Live USB

```bash
# 1. Boot NixOS Live USB

# 2. Download the TUI script
curl -o /tmp/tui_installer.py https://raw.githubusercontent.com/julas23/nixos/main/tui_installer.py

# 3. Make executable
chmod +x /tmp/tui_installer.py

# 4. Run it
python3 /tmp/tui_installer.py

# 5. Test all features:
#    - Navigate with arrow keys
#    - Edit text fields
#    - Select options
#    - Press F10 to save
#    - Press Esc to cancel
```

### Test Output

```bash
# Run and capture output
python3 tui_installer.py > /tmp/test_config.sh

# View the output
cat /tmp/test_config.sh

# Test sourcing
source /tmp/test_config.sh
echo "Hostname is: $hostname"
```

## Troubleshooting

### Terminal Not Supported

**Problem**: Error about terminal capabilities

**Solution**: Ensure you're running in a proper terminal (not a pipe or redirect). The TUI requires an interactive terminal.

```bash
# This works:
python3 tui_installer.py

# This doesn't work (no terminal):
python3 tui_installer.py | cat
```

### Display Issues

**Problem**: Characters not displaying correctly

**Solution**: Ensure your terminal supports UTF-8 and box-drawing characters. Most modern terminals do.

```bash
# Check terminal type
echo $TERM

# Should be something like: xterm-256color, linux, screen, etc.
```

### Keyboard Not Working

**Problem**: Arrow keys not responding

**Solution**: The terminal might not be sending proper escape sequences. Try:

```bash
# Set terminal type
export TERM=xterm-256color

# Run again
python3 tui_installer.py
```

## Technical Details

### Architecture

```python
# Configuration definition
CONFIG_OPTIONS = {
    'hostname': {
        'label': 'hostname',
        'type': 'input',
        'value': 'nixos',
        'width': 30
    },
    # ... more options
}

# Main components:
1. get_system_info()     # Gather CPU, RAM, disk, IP info
2. draw_header()         # Draw system info header
3. draw_config_line()    # Draw one configuration option
4. draw_footer()         # Draw help text
5. main_tui()            # Main event loop
```

### File Structure

```
nixos/
├── install.sh                      # Main bash installer (current)
├── tui_installer.py                # TUI installer (new, experimental)
├── TUI_README.md                   # This file
├── TUI_IMPLEMENTATION_ANALYSIS.md  # Technical analysis and design
└── modules/
    ├── base.nix
    ├── vars.nix
    └── ...
```

## Advantages Over Sequential Prompts

### Current Approach (install.sh)

```
Prompt 1: Enter hostname
Prompt 2: Enter username
Prompt 3: Select GPU (menu)
Prompt 4: Select Desktop (menu)
...
```

**Issues**:
- Can't see all options at once
- Can't go back to change earlier choices
- Sequential, time-consuming
- No overview of configuration

### TUI Approach

```
All options visible in one screen
Navigate freely between any field
Change any value at any time
See complete configuration before confirming
```

**Benefits**:
- ✅ Faster configuration
- ✅ Better overview
- ✅ Easy to correct mistakes
- ✅ Professional appearance
- ✅ More user-friendly

## Contributing

This is an experimental feature being developed in parallel. Contributions and feedback are welcome!

### How to Contribute

1. Test the TUI in NixOS Live USB
2. Report issues or suggestions
3. Propose enhancements
4. Submit pull requests

### Development Guidelines

- Keep zero external dependencies (only Python stdlib)
- Maintain compatibility with NixOS Minimal ISO
- Follow the existing code structure
- Add comments for complex logic
- Test in actual terminal environments

## Future Vision

The ultimate goal is to create a complete TUI-based installer that handles:

1. **System Detection**: Automatic hardware detection
2. **Disk Management**: Visual disk selection and partitioning
3. **Configuration**: All system settings in one interface
4. **Installation**: Progress tracking with visual feedback
5. **Post-Install**: Configuration summary and next steps

All while maintaining zero external dependencies and working perfectly in the NixOS Minimal ISO environment.

## License

Same as the main NixOS configuration repository.

## Credits

Developed as part of the NixOS installation automation project.

---

**Status**: Experimental - Ready for testing  
**Last Updated**: 2026-02-12  
**Compatibility**: NixOS Minimal ISO (Python 3.11+)
