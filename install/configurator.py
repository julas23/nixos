#!/usr/bin/env python3
"""
NixOS Interactive Configuration Wizard
Guides users through system configuration with hardware detection and validation
"""

import os
import sys
import json
import subprocess
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple

# Add lib to path
sys.path.insert(0, str(Path(__file__).parent / "lib"))

from config_generator import generate_config_nix, save_choices_to_json
from validators import (
    validate_hostname, validate_username, validate_fullname,
    validate_uid_gid, validate_disk_path
)


class HardwareDetector:
    """Detect system hardware and suggest configurations"""
    
    @staticmethod
    def get_cpu_info() -> Dict[str, Any]:
        """Get CPU information"""
        try:
            with open("/proc/cpuinfo", "r") as f:
                content = f.read()
                lines = content.split("\n")
                
                model = ""
                cores = 0
                
                for line in lines:
                    if "model name" in line and not model:
                        model = line.split(":")[1].strip()
                    if "processor" in line:
                        cores += 1
                
                return {"model": model, "cores": cores}
        except:
            return {"model": "Unknown", "cores": 0}
    
    @staticmethod
    def get_memory_info() -> str:
        """Get total system memory"""
        try:
            with open("/proc/meminfo", "r") as f:
                for line in f:
                    if "MemTotal" in line:
                        kb = int(line.split()[1])
                        gb = round(kb / 1024 / 1024)
                        return f"{gb} GB"
        except:
            pass
        return "Unknown"
    
    @staticmethod
    def detect_gpu() -> Optional[str]:
        """Detect GPU and suggest driver"""
        try:
            result = subprocess.run(
                ["lspci"], 
                capture_output=True, 
                text=True, 
                timeout=5
            )
            output = result.stdout.lower()
            
            if "nvidia" in output or "geforce" in output:
                return "nvidia"
            elif "amd" in output or "radeon" in output:
                return "amd"
            elif "intel" in output and ("graphics" in output or "uhd" in output):
                return "intel"
        except:
            pass
        return None
    
    @staticmethod
    def list_disks() -> List[Dict[str, str]]:
        """List available disks"""
        try:
            result = subprocess.run(
                ["lsblk", "-d", "-n", "-o", "NAME,SIZE,TYPE,MODEL", "-e", "7,11"],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            disks = []
            for line in result.stdout.strip().split("\n"):
                if line:
                    parts = line.split(None, 3)
                    if len(parts) >= 3:
                        name = parts[0]
                        size = parts[1]
                        dtype = parts[2]
                        model = parts[3] if len(parts) > 3 else "Unknown"
                        
                        if dtype == "disk":
                            disks.append({
                                "device": f"/dev/{name}",
                                "size": size,
                                "model": model
                            })
            
            return disks
        except:
            return []
    
    @staticmethod
    def get_network_status() -> Tuple[bool, Optional[str]]:
        """Check network connectivity and get IP"""
        try:
            # Check connectivity
            result = subprocess.run(
                ["ping", "-c", "1", "-W", "2", "1.1.1.1"],
                capture_output=True,
                timeout=3
            )
            connected = result.returncode == 0
            
            # Get IP
            ip = None
            if connected:
                result = subprocess.run(
                    ["ip", "route", "get", "1.1.1.1"],
                    capture_output=True,
                    text=True,
                    timeout=2
                )
                for line in result.stdout.split("\n"):
                    if "src" in line:
                        parts = line.split("src")
                        if len(parts) > 1:
                            ip = parts[1].strip().split()[0]
                            break
            
            return connected, ip
        except:
            return False, None


class Configurator:
    """Interactive configuration wizard"""
    
    def __init__(self):
        self.choices = {}
        self.data_dir = Path(__file__).parent / "data"
        self.hw = HardwareDetector()
        
        # Load JSON data
        self.timezones = self.load_json("timezones.json")
        self.locales = self.load_json("locales.json")
        self.keymaps = self.load_json("keymaps.json")
        self.xkb_layouts = self.load_json("xkb-layouts.json")
        self.desktops = self.load_json("desktops.json")
        self.gpus = self.load_json("gpus.json")
    
    def load_json(self, filename: str) -> Any:
        """Load JSON data file"""
        path = self.data_dir / filename
        with open(path, "r") as f:
            return json.load(f)
    
    def print_header(self, title: str):
        """Print section header"""
        print("\n" + "=" * 60)
        print(f"  {title}")
        print("=" * 60 + "\n")
    
    def print_system_info(self):
        """Display detected hardware information"""
        cpu = self.hw.get_cpu_info()
        mem = self.hw.get_memory_info()
        gpu = self.hw.detect_gpu()
        connected, ip = self.hw.get_network_status()
        
        self.print_header("DETECTED HARDWARE")
        print(f"CPU:     {cpu['model']}")
        print(f"Cores:   {cpu['cores']}")
        print(f"Memory:  {mem}")
        print(f"GPU:     {gpu or 'Not detected'}")
        print(f"Network: {'Connected' if connected else 'Disconnected'} {f'({ip})' if ip else ''}")
    
    def select_from_list(self, items: List[Dict], title: str, value_key: str = "value", label_key: str = "label", default: Any = None, show_popular: bool = True) -> str:
        """Generic list selection"""
        print(f"\n{title}:\n")
        
        # Filter popular if requested
        display_items = items
        if show_popular and any(item.get("popular") for item in items):
            popular = [item for item in items if item.get("popular")]
            if popular:
                print("Popular choices:")
                for i, item in enumerate(popular, 1):
                    label = item[label_key]
                    desc = item.get("description", "")
                    print(f"  {i}. {label}" + (f" - {desc}" if desc else ""))
                
                print(f"\n  {len(popular) + 1}. Show all options")
                print(f"  {len(popular) + 2}. Custom value")
                
                while True:
                    choice = input(f"\nSelect (1-{len(popular) + 2}): ").strip()
                    try:
                        idx = int(choice) - 1
                        if 0 <= idx < len(popular):
                            return popular[idx][value_key]
                        elif idx == len(popular):
                            # Show all
                            display_items = items
                            break
                        elif idx == len(popular) + 1:
                            # Custom
                            return input("Enter custom value: ").strip()
                    except ValueError:
                        pass
                    print("Invalid choice, try again.")
        
        # Show all items
        print("\nAll options:")
        for i, item in enumerate(display_items, 1):
            label = item[label_key]
            desc = item.get("description", "")
            marker = " (suggested)" if default and item[value_key] == default else ""
            print(f"  {i}. {label}{marker}" + (f" - {desc}" if desc else ""))
        
        print(f"  {len(display_items) + 1}. Custom value")
        
        while True:
            choice = input(f"\nSelect (1-{len(display_items) + 1}): ").strip()
            try:
                idx = int(choice) - 1
                if 0 <= idx < len(display_items):
                    return display_items[idx][value_key]
                elif idx == len(display_items):
                    return input("Enter custom value: ").strip()
            except ValueError:
                pass
            print("Invalid choice, try again.")
    
    def select_region_timezone(self) -> str:
        """Select timezone by region"""
        regions = list(self.timezones.keys())
        
        print("\nSelect your region:\n")
        for i, region in enumerate(regions, 1):
            print(f"  {i}. {region}")
        
        while True:
            choice = input(f"\nSelect region (1-{len(regions)}): ").strip()
            try:
                idx = int(choice) - 1
                if 0 <= idx < len(regions):
                    region = regions[idx]
                    timezones = self.timezones[region]
                    return self.select_from_list(timezones, f"Select timezone in {region}")
            except ValueError:
                pass
            print("Invalid choice, try again.")
    
    def input_with_validation(self, prompt: str, validator, default: str = None) -> str:
        """Input with validation"""
        while True:
            if default:
                value = input(f"{prompt} [{default}]: ").strip() or default
            else:
                value = input(f"{prompt}: ").strip()
            
            valid, error = validator(value)
            if valid:
                return value
            else:
                print(f"  Error: {error}")
    
    def yes_no(self, prompt: str, default: bool = True) -> bool:
        """Yes/No question"""
        default_str = "Y/n" if default else "y/N"
        while True:
            choice = input(f"{prompt} ({default_str}): ").strip().lower()
            if not choice:
                return default
            if choice in ["y", "yes"]:
                return True
            if choice in ["n", "no"]:
                return False
            print("Please answer 'y' or 'n'")
    
    def configure_system(self):
        """Configure basic system settings"""
        self.print_header("SYSTEM CONFIGURATION")
        
        self.choices["hostname"] = self.input_with_validation(
            "Enter hostname",
            validate_hostname,
            default="nixos"
        )
    
    def configure_locale(self):
        """Configure regional settings"""
        self.print_header("REGIONAL SETTINGS")
        
        # Timezone
        self.choices["timezone"] = self.select_region_timezone()
        
        # Locale
        self.choices["locale"] = self.select_from_list(
            self.locales,
            "Select language/locale"
        )
        
        # Console keymap
        self.choices["console_keymap"] = self.select_from_list(
            self.keymaps,
            "Select console keyboard layout"
        )
        
        # X11 layout
        layout_data = self.select_from_list(
            self.xkb_layouts,
            "Select X11 keyboard layout",
            label_key="label"
        )
        
        # Find the selected layout to get variants
        selected_layout = next((l for l in self.xkb_layouts if l["value"] == layout_data), None)
        self.choices["xkb_layout"] = layout_data
        
        # X11 variant
        if selected_layout and selected_layout.get("variants"):
            variants = selected_layout["variants"]
            if len(variants) > 1:
                print("\nSelect X11 keyboard variant:\n")
                for i, variant in enumerate(variants, 1):
                    label = variant if variant else "(default)"
                    print(f"  {i}. {label}")
                
                while True:
                    choice = input(f"\nSelect (1-{len(variants)}): ").strip()
                    try:
                        idx = int(choice) - 1
                        if 0 <= idx < len(variants):
                            self.choices["xkb_variant"] = variants[idx]
                            break
                    except ValueError:
                        pass
                    print("Invalid choice, try again.")
            else:
                self.choices["xkb_variant"] = ""
        else:
            self.choices["xkb_variant"] = ""
    
    def configure_hardware(self):
        """Configure hardware"""
        self.print_header("HARDWARE CONFIGURATION")
        
        # GPU
        detected_gpu = self.hw.detect_gpu()
        self.choices["gpu"] = self.select_from_list(
            self.gpus,
            "Select GPU driver",
            default=detected_gpu
        )
        
        # Audio
        self.choices["audio_enable"] = self.yes_no("Enable audio support?", default=True)
        if self.choices["audio_enable"]:
            self.choices["audio_backend"] = "pipewire"  # Default to PipeWire
        
        # Bluetooth
        self.choices["bluetooth_enable"] = self.yes_no("Enable Bluetooth?", default=False)
        
        # Printing
        self.choices["printing_enable"] = self.yes_no("Enable printing (CUPS)?", default=False)
    
    def configure_desktop(self):
        """Configure desktop environment"""
        self.print_header("DESKTOP ENVIRONMENT")
        
        desktop = self.select_from_list(
            self.desktops,
            "Select desktop environment or window manager"
        )
        
        self.choices["desktop"] = desktop
        
        # Determine display server
        desktop_data = next((d for d in self.desktops if d["value"] == desktop), None)
        if desktop_data:
            if desktop_data["display_server"] == "both":
                self.choices["display_server"] = "wayland" if self.yes_no("Use Wayland?", default=True) else "xorg"
            elif desktop_data["display_server"] == "none":
                self.choices["display_server"] = "none"
            else:
                self.choices["display_server"] = desktop_data["display_server"]
    
    def configure_services(self):
        """Configure optional services"""
        self.print_header("SERVICES")
        
        self.choices["docker_enable"] = self.yes_no("Enable Docker?", default=False)
        self.choices["ollama_enable"] = self.yes_no("Enable Ollama (AI)?", default=False)
        self.choices["ssh_enable"] = self.yes_no("Enable SSH server?", default=True)
    
    def configure_user(self):
        """Configure user account"""
        self.print_header("USER CONFIGURATION")
        
        self.choices["username"] = self.input_with_validation(
            "Enter username",
            validate_username,
            default="user"
        )
        
        self.choices["user_fullname"] = self.input_with_validation(
            "Enter full name",
            validate_fullname,
            default="User"
        )
        
        self.choices["user_sudoer"] = self.yes_no("Add user to sudoers?", default=True)
        
        if self.choices["user_sudoer"]:
            self.choices["user_nopasswd"] = self.yes_no("Allow sudo without password?", default=False)
        
        # Default groups
        self.choices["user_groups"] = ["wheel", "networkmanager"]
        self.choices["user_uid"] = 1000
        self.choices["user_gid"] = 1000
        self.choices["user_shell"] = "bash"
    
    def show_summary(self):
        """Show configuration summary"""
        self.print_header("CONFIGURATION SUMMARY")
        
        print(f"Hostname:        {self.choices.get('hostname')}")
        print(f"Timezone:        {self.choices.get('timezone')}")
        print(f"Locale:          {self.choices.get('locale')}")
        print(f"Console Keymap:  {self.choices.get('console_keymap')}")
        print(f"X11 Layout:      {self.choices.get('xkb_layout')} {self.choices.get('xkb_variant', '')}")
        print(f"GPU:             {self.choices.get('gpu')}")
        print(f"Desktop:         {self.choices.get('desktop')}")
        print(f"Display Server:  {self.choices.get('display_server')}")
        print(f"Username:        {self.choices.get('username')}")
        print(f"Docker:          {'Yes' if self.choices.get('docker_enable') else 'No'}")
        print(f"Ollama:          {'Yes' if self.choices.get('ollama_enable') else 'No'}")
        print(f"SSH:             {'Yes' if self.choices.get('ssh_enable') else 'No'}")
    
    def run(self):
        """Run the configuration wizard"""
        print("\n" + "=" * 60)
        print("  NixOS Interactive Configuration Wizard")
        print("=" * 60)
        
        self.print_system_info()
        
        input("\nPress Enter to continue...")
        
        # Configuration steps
        self.configure_system()
        self.configure_locale()
        self.configure_hardware()
        self.configure_desktop()
        self.configure_services()
        self.configure_user()
        
        # Summary
        self.show_summary()
        
        if not self.yes_no("\nGenerate configuration?", default=True):
            print("\nConfiguration cancelled.")
            return False
        
        # Generate config.nix
        output_path = "/mnt/etc/nixos/modules/config.nix"
        
        try:
            config_content = generate_config_nix(self.choices, output_path)
            print(f"\n✓ Configuration written to: {output_path}")
            
            # Save choices to JSON for reference
            json_path = "/mnt/etc/nixos/install-choices.json"
            save_choices_to_json(self.choices, json_path)
            print(f"✓ Choices saved to: {json_path}")
            
            return True
        except Exception as e:
            print(f"\n✗ Error generating configuration: {e}")
            return False


def main():
    """Main entry point"""
    try:
        configurator = Configurator()
        success = configurator.run()
        
        if success:
            print("\n" + "=" * 60)
            print("  Configuration complete!")
            print("  You can now proceed with: nixos-install")
            print("=" * 60 + "\n")
            sys.exit(0)
        else:
            sys.exit(1)
    
    except KeyboardInterrupt:
        print("\n\nConfiguration cancelled by user.")
        sys.exit(1)
    except Exception as e:
        print(f"\n\nFatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
