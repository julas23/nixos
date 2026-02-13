# NixOS Configuration Wizard

Interactive configuration wizard that simplifies NixOS installation for non-technical users.

## Features

- **Hardware Detection**: Automatically detects CPU, GPU, memory, disks, and network
- **Guided Configuration**: Step-by-step wizard for all system settings
- **Validation**: Input validation to prevent configuration errors
- **Suggestions**: Smart defaults based on detected hardware
- **JSON Data**: Comprehensive lists of timezones, locales, keymaps, etc.
- **Auto-Generation**: Generates `modules/config.nix` automatically

## Usage

### During Installation

```bash
# After partitioning and mounting to /mnt
cd /mnt/etc/nixos
python3 install/configurator.py
```

The wizard will:
1. Display detected hardware
2. Guide you through configuration
3. Generate `modules/config.nix`
4. Save choices to `install-choices.json`

### Configuration Steps

1. **System**: Hostname
2. **Regional Settings**: Timezone, locale, keyboard
3. **Hardware**: GPU driver, audio, bluetooth, printing
4. **Desktop**: Desktop environment or window manager
5. **Services**: Docker, Ollama, SSH
6. **User**: Username, full name, sudo access

## Data Files

### `data/timezones.json`
Comprehensive list of timezones organized by region with UTC offsets.

### `data/locales.json`
Available system locales with language and country information.

### `data/keymaps.json`
Console keyboard layouts with descriptions.

### `data/xkb-layouts.json`
X11 keyboard layouts with available variants.

### `data/desktops.json`
Desktop environments and window managers with metadata.

### `data/gpus.json`
GPU drivers with detection keywords.

## Library Functions

### `lib/config_generator.py`
- `generate_config_nix(choices, output_path)`: Generate Nix configuration
- `load_choices_from_json(json_path)`: Load saved choices
- `save_choices_to_json(choices, json_path)`: Save choices

### `lib/validators.py`
- `validate_hostname(hostname)`: Validate hostname (RFC 1123)
- `validate_username(username)`: Validate Unix username
- `validate_fullname(fullname)`: Validate full name
- `validate_uid_gid(value)`: Validate UID/GID
- `validate_disk_path(path)`: Validate disk device path
- `validate_vg_name(name)`: Validate LVM volume group name
- `validate_lv_name(name)`: Validate LVM logical volume name
- `validate_zfs_pool_name(name)`: Validate ZFS pool name
- `validate_password(password, confirm)`: Validate password strength

## Example Usage

```python
from lib.config_generator import generate_config_nix

choices = {
    "hostname": "my-nixos",
    "timezone": "America/Sao_Paulo",
    "locale": "pt_BR.UTF-8",
    "console_keymap": "br-abnt2",
    "xkb_layout": "br",
    "gpu": "amd",
    "desktop": "cosmic",
    "username": "julas",
}

config = generate_config_nix(choices, "/mnt/etc/nixos/modules/config.nix")
```

## Adding New Options

### Add a New Timezone Region

Edit `data/timezones.json`:

```json
{
  "NewRegion": [
    {
      "value": "Region/City",
      "label": "City (TZ, UTC±X)",
      "country": "Country",
      "popular": true
    }
  ]
}
```

### Add a New Desktop Environment

Edit `data/desktops.json`:

```json
{
  "value": "mydesktop",
  "label": "My Desktop",
  "description": "Description of desktop",
  "type": "DE",
  "display_server": "wayland",
  "difficulty": "easy",
  "popular": false
}
```

## Testing

Test the configuration generator:

```bash
cd install/lib
python3 config_generator.py
```

Test validators:

```bash
cd install/lib
python3 validators.py
```

## Integration with Installer

The configurator can be integrated into the main installation script:

```bash
#!/bin/bash

# Partition and mount disks
# ...

# Clone repository
git clone https://github.com/julas23/nixos.git /mnt/etc/nixos

# Run configurator
python3 /mnt/etc/nixos/install/configurator.py

# Generate hardware config
nixos-generate-config --root /mnt

# Install
nixos-install
```

## Architecture

```
install/
├── configurator.py           # Main wizard
├── data/                     # JSON data files
│   ├── timezones.json
│   ├── locales.json
│   ├── keymaps.json
│   ├── xkb-layouts.json
│   ├── desktops.json
│   └── gpus.json
└── lib/                      # Libraries
    ├── config_generator.py   # Config generation
    └── validators.py         # Input validation
```

## License

MIT License
