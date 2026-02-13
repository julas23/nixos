#!/usr/bin/env python3
"""
Configuration Generator Library
Generates modules/config.nix from user choices
"""

import json
from typing import Dict, Any


def generate_nix_value(value: Any) -> str:
    """Convert Python value to Nix expression"""
    if isinstance(value, bool):
        return "true" if value else "false"
    elif isinstance(value, str):
        return f'"{value}"'
    elif isinstance(value, int):
        return str(value)
    elif isinstance(value, list):
        items = " ".join([generate_nix_value(v) for v in value])
        return f"[ {items} ]"
    elif isinstance(value, dict):
        return generate_nix_dict(value)
    else:
        return str(value)


def generate_nix_dict(data: Dict[str, Any], indent: int = 0) -> str:
    """Generate Nix attribute set from dictionary"""
    lines = []
    indent_str = "  " * indent
    
    for key, value in data.items():
        if isinstance(value, dict):
            lines.append(f"{indent_str}{key} = {{")
            lines.append(generate_nix_dict(value, indent + 1))
            lines.append(f"{indent_str}}};")
        else:
            nix_value = generate_nix_value(value)
            lines.append(f"{indent_str}{key} = {nix_value};")
    
    return "\n".join(lines)


def generate_config_nix(choices: Dict[str, Any], output_path: str = None) -> str:
    """
    Generate modules/config.nix from user choices
    
    Args:
        choices: Dictionary of user configuration choices
        output_path: Optional path to write the file
        
    Returns:
        Generated Nix configuration as string
    """
    
    # Build configuration structure
    config = {
        "system": {
            "hostname": choices.get("hostname", "nixos"),
            "stateVersion": "24.11"
        },
        "locale": {
            "timezone": choices.get("timezone", "UTC"),
            "language": choices.get("locale", "en_US.UTF-8"),
            "extraLocales": [f"{choices.get('locale', 'en_US.UTF-8')}/UTF-8"],
            "keyboard": {
                "console": choices.get("console_keymap", "us"),
                "layout": choices.get("xkb_layout", "us"),
                "variant": choices.get("xkb_variant", ""),
                "options": ""
            }
        },
        "hardware": {
            "gpu": choices.get("gpu", "none"),
            "audio": {
                "enable": choices.get("audio_enable", True),
                "backend": choices.get("audio_backend", "pipewire")
            },
            "bluetooth": {
                "enable": choices.get("bluetooth_enable", False)
            },
            "printing": {
                "enable": choices.get("printing_enable", False)
            }
        },
        "graphics": {
            "server": choices.get("display_server", "wayland"),
            "desktop": choices.get("desktop", "none")
        },
        "storage": {
            "lvm": {
                "enable": choices.get("lvm_enable", False),
                "vgName": choices.get("lvm_vg_name", "vg0"),
                "lvName": choices.get("lvm_lv_name", "root")
            },
            "zfs": {
                "enable": choices.get("zfs_enable", False),
                "poolName": choices.get("zfs_pool_name", "rpool")
            },
            "filesystem": choices.get("filesystem", "ext4"),
            "mountpoint": "/"
        },
        "services": {
            "docker": {
                "enable": choices.get("docker_enable", False)
            },
            "ollama": {
                "enable": choices.get("ollama_enable", False)
            },
            "ssh": {
                "enable": choices.get("ssh_enable", True),
                "permitRootLogin": choices.get("ssh_permit_root", False)
            },
            "lsyncd": {
                "enable": False
            }
        },
        "user": {
            "name": choices.get("username", "user"),
            "fullName": choices.get("user_fullname", "User Name"),
            "uid": choices.get("user_uid", 1000),
            "gid": choices.get("user_gid", 1000),
            "group": "users",
            "extraGroups": choices.get("user_groups", ["wheel", "networkmanager"]),
            "sudoer": choices.get("user_sudoer", True),
            "nopasswd": choices.get("user_nopasswd", False),
            "shell": choices.get("user_shell", "bash")
        },
        "network": {
            "networkmanager": {
                "enable": True
            },
            "firewall": {
                "enable": True,
                "allowedTCPPorts": [],
                "allowedUDPPorts": []
            }
        },
        "boot": {
            "loader": choices.get("bootloader", "systemd-boot"),
            "timeout": 5,
            "quietBoot": True
        },
        "nix": {
            "flakes": True,
            "autoOptimiseStore": True,
            "gc": {
                "enable": True,
                "dates": "weekly",
                "options": "--delete-older-than 7d"
            }
        }
    }
    
    # Generate Nix file content
    nix_content = f"""# Centralized System Configuration
# This file contains all system configuration options in one place
# All modules read from this configuration to determine what to enable

{{ lib, ... }}:

{{
  options.system.config = lib.mkOption {{
    type = lib.types.attrs;
    default = {{}};
    description = "Centralized system configuration";
  }};

  config.system.config = {{
{generate_nix_dict(config, indent=2)}
  }};
}}
"""
    
    # Write to file if path provided
    if output_path:
        with open(output_path, 'w') as f:
            f.write(nix_content)
    
    return nix_content


def load_choices_from_json(json_path: str) -> Dict[str, Any]:
    """Load user choices from JSON file"""
    with open(json_path, 'r') as f:
        return json.load(f)


def save_choices_to_json(choices: Dict[str, Any], json_path: str):
    """Save user choices to JSON file"""
    with open(json_path, 'w') as f:
        json.dump(choices, f, indent=2)


if __name__ == "__main__":
    # Example usage
    example_choices = {
        "hostname": "my-nixos",
        "timezone": "America/Sao_Paulo",
        "locale": "pt_BR.UTF-8",
        "console_keymap": "br-abnt2",
        "xkb_layout": "br",
        "xkb_variant": "",
        "gpu": "amd",
        "display_server": "wayland",
        "desktop": "cosmic",
        "username": "julas",
        "user_fullname": "Julas",
        "docker_enable": True,
    }
    
    config = generate_config_nix(example_choices)
    print(config)
