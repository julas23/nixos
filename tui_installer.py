#!/usr/bin/env python3
"""
NixOS TUI Installer - Proof of Concept
Full-screen interface with system info header and configuration options
Uses only Python standard library (curses) - no external dependencies
"""

import curses
import subprocess
import re
from typing import List, Dict, Tuple

# Configuration options
CONFIG_OPTIONS = {
    'hostname': {
        'label': 'hostname',
        'type': 'input',
        'value': 'nixos',
        'width': 30
    },
    'username': {
        'label': 'username',
        'type': 'input',
        'value': 'user',
        'width': 30
    },
    'video': {
        'label': 'video',
        'type': 'select',
        'options': ['nvidia', 'amdgpu', 'intel', 'vm'],
        'value': 'amdgpu'
    },
    'graphic': {
        'label': 'graphic',
        'type': 'select',
        'options': ['wayland', 'xorg'],
        'value': 'wayland'
    },
    'desktop': {
        'label': 'desktop',
        'type': 'select',
        'options': ['cosmic', 'gnome', 'hyprland', 'i3', 'xfce', 'mate', 'awesome'],
        'value': 'cosmic'
    },
    'locale': {
        'label': 'locale',
        'type': 'select',
        'options': ['us', 'br', 'uk', 'fr', 'de', 'es', 'it', 'custom'],
        'value': 'us'
    },
    'localeCode': {
        'label': 'localeCode',
        'type': 'select',
        'options': ['en_US.UTF-8', 'en_GB.UTF-8', 'pt_BR.UTF-8', 'pt_PT.UTF-8', 'fr_FR.UTF-8', 'de_DE.UTF-8', 'es_ES.UTF-8', 'it_IT.UTF-8', 'custom'],
        'value': 'en_US.UTF-8'
    },
    'timezone': {
        'label': 'timezone',
        'type': 'select',
        'options': ['America/Miami', 'America/Sao_Paulo', 'America/New_York', 'Europe/London', 'Europe/Paris', 'Europe/Berlin', 'Asia/Tokyo', 'custom'],
        'value': 'America/Miami'
    },
    'keymap': {
        'label': 'keymap',
        'type': 'select',
        'options': ['us', 'uk', 'br-abnt2', 'pt', 'es', 'fr', 'de', 'it', 'custom'],
        'value': 'us'
    },
    'xkbLayout': {
        'label': 'xkbLayout',
        'type': 'select',
        'options': ['us', 'uk', 'br', 'pt', 'es', 'fr', 'de', 'it'],
        'value': 'us'
    },
    'xkbVariant': {
        'label': 'xkbVariant',
        'type': 'select',
        'options': ['', 'alt-intl', 'custom'],
        'value': 'alt-intl'
    },
    'ollama': {
        'label': 'ollama',
        'type': 'select',
        'options': ['YES', 'NO'],
        'value': 'NO'
    },
    'docker': {
        'label': 'docker',
        'type': 'select',
        'options': ['YES', 'NO'],
        'value': 'YES'
    }
}

def get_system_info() -> Dict[str, str]:
    """Gather system information for the header"""
    info = {}
    
    # CPU info
    try:
        with open('/proc/cpuinfo', 'r') as f:
            cpuinfo = f.read()
            model = re.search(r'model name\s*:\s*(.+)', cpuinfo)
            if model:
                info['cpu'] = model.group(1).strip()
            else:
                info['cpu'] = 'Unknown CPU'
            
            cores = len(re.findall(r'processor\s*:', cpuinfo))
            info['cores'] = str(cores)
    except:
        info['cpu'] = 'Unknown'
        info['cores'] = 'Unknown'
    
    # Memory info
    try:
        with open('/proc/meminfo', 'r') as f:
            meminfo = f.read()
            mem_total = re.search(r'MemTotal:\s+(\d+)', meminfo)
            if mem_total:
                mem_gb = int(mem_total.group(1)) // 1024 // 1024
                info['memory'] = f"{mem_gb} GB"
            else:
                info['memory'] = 'Unknown'
    except:
        info['memory'] = 'Unknown'
    
    # Disk info
    try:
        result = subprocess.run(['lsblk', '-d', '-n', '-o', 'NAME,SIZE', '-e', '7,11'], 
                              capture_output=True, text=True)
        disks = result.stdout.strip().split('\n')
        info['disks'] = ', '.join([f"{d.split()[0]}({d.split()[1]})" for d in disks if d])
    except:
        info['disks'] = 'Unknown'
    
    # IP info
    try:
        result = subprocess.run(['ip', '-4', 'addr', 'show'], capture_output=True, text=True)
        ips = re.findall(r'inet\s+(\d+\.\d+\.\d+\.\d+)', result.stdout)
        # Filter out localhost
        ips = [ip for ip in ips if not ip.startswith('127.')]
        info['ip'] = ', '.join(ips) if ips else 'No network'
    except:
        info['ip'] = 'Unknown'
    
    return info

def draw_header(stdscr, system_info: Dict[str, str]):
    """Draw the system information header"""
    height, width = stdscr.getmaxyx()
    
    # Draw top border
    stdscr.addstr(0, 0, "╔" + "═" * (width - 2) + "╗")
    
    # Title
    title = "NIXOS INSTALLATION CONFIGURATOR"
    stdscr.addstr(1, (width - len(title)) // 2, title, curses.A_BOLD)
    
    # System info
    info_line1 = f"CPU: {system_info.get('cpu', 'Unknown')[:40]} | Cores: {system_info.get('cores', '?')} | RAM: {system_info.get('memory', '?')}"
    info_line2 = f"Disks: {system_info.get('disks', 'Unknown')[:50]}"
    info_line3 = f"IP: {system_info.get('ip', 'Unknown')}"
    
    stdscr.addstr(2, 2, info_line1[:width-4])
    stdscr.addstr(3, 2, info_line2[:width-4])
    stdscr.addstr(4, 2, info_line3[:width-4])
    
    # Separator
    stdscr.addstr(5, 0, "╠" + "═" * (width - 2) + "╣")
    
    return 6  # Return the starting row for content

def draw_config_line(stdscr, row: int, col: int, label: str, config: Dict, 
                     is_selected: bool, is_editing: bool, edit_index: int = -1):
    """Draw a single configuration line"""
    height, width = stdscr.getmaxyx()
    
    # Label
    label_text = f"{label:15s} = "
    if is_selected:
        stdscr.addstr(row, col, label_text, curses.A_REVERSE)
    else:
        stdscr.addstr(row, col, label_text)
    
    col_offset = col + len(label_text)
    
    if config['type'] == 'input':
        # Input field
        value = config['value']
        field = f"[{value:<{config['width']}}]"
        if is_selected and is_editing:
            stdscr.addstr(row, col_offset, field, curses.A_BOLD | curses.A_UNDERLINE)
        elif is_selected:
            stdscr.addstr(row, col_offset, field, curses.A_REVERSE)
        else:
            stdscr.addstr(row, col_offset, field)
    
    elif config['type'] == 'select':
        # Multiple choice buttons
        for idx, option in enumerate(config['options']):
            if option == config['value']:
                button = f"[{option}]"
                attr = curses.A_BOLD
            else:
                button = f" {option} "
                attr = curses.A_DIM
            
            if is_selected and is_editing and idx == edit_index:
                attr |= curses.A_REVERSE
            elif is_selected and not is_editing:
                attr |= curses.A_UNDERLINE
            
            if col_offset + len(button) + 2 < width - 2:
                stdscr.addstr(row, col_offset, button, attr)
                col_offset += len(button) + 2

def draw_footer(stdscr):
    """Draw the footer with help text"""
    height, width = stdscr.getmaxyx()
    
    # Bottom border
    stdscr.addstr(height - 3, 0, "╠" + "═" * (width - 2) + "╣")
    
    # Help text
    help_text = "↑/↓: Navigate | Enter: Edit | Space: Select | Tab: Next | Esc: Cancel | F10: Save & Continue"
    stdscr.addstr(height - 2, 2, help_text[:width-4], curses.A_DIM)
    
    # Bottom border
    stdscr.addstr(height - 1, 0, "╚" + "═" * (width - 2) + "╝")

def edit_input_field(stdscr, row: int, col: int, config: Dict) -> str:
    """Edit an input field"""
    curses.echo()
    curses.curs_set(1)
    
    # Clear the field
    stdscr.addstr(row, col, " " * (config['width'] + 2))
    stdscr.addstr(row, col, "[")
    stdscr.refresh()
    
    # Get input
    value = stdscr.getstr(row, col + 1, config['width']).decode('utf-8')
    
    curses.noecho()
    curses.curs_set(0)
    
    return value if value else config['value']

def main_tui(stdscr):
    """Main TUI loop"""
    # Initialize colors
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_WHITE)
    curses.init_pair(2, curses.COLOR_WHITE, curses.COLOR_BLUE)
    curses.init_pair(3, curses.COLOR_GREEN, -1)
    
    # Hide cursor
    curses.curs_set(0)
    
    # Get system info
    system_info = get_system_info()
    
    # Configuration state
    config_keys = list(CONFIG_OPTIONS.keys())
    current_row = 0
    is_editing = False
    edit_index = 0
    
    while True:
        stdscr.clear()
        height, width = stdscr.getmaxyx()
        
        # Draw header
        content_start = draw_header(stdscr, system_info)
        
        # Draw configuration options
        row_offset = content_start + 1
        for idx, key in enumerate(config_keys):
            if row_offset + idx < height - 4:
                draw_config_line(
                    stdscr, 
                    row_offset + idx, 
                    2, 
                    CONFIG_OPTIONS[key]['label'],
                    CONFIG_OPTIONS[key],
                    idx == current_row,
                    is_editing and idx == current_row,
                    edit_index if is_editing and idx == current_row else -1
                )
        
        # Draw footer
        draw_footer(stdscr)
        
        stdscr.refresh()
        
        # Handle input
        key = stdscr.getch()
        
        if key == 27:  # ESC
            if is_editing:
                is_editing = False
                edit_index = 0
            else:
                # Confirm exit
                return None
        
        elif key == curses.KEY_F10:  # F10 - Save and continue
            return CONFIG_OPTIONS
        
        elif key == curses.KEY_UP:
            if not is_editing:
                current_row = (current_row - 1) % len(config_keys)
        
        elif key == curses.KEY_DOWN:
            if not is_editing:
                current_row = (current_row + 1) % len(config_keys)
        
        elif key == curses.KEY_LEFT:
            if is_editing:
                current_config = CONFIG_OPTIONS[config_keys[current_row]]
                if current_config['type'] == 'select':
                    edit_index = (edit_index - 1) % len(current_config['options'])
        
        elif key == curses.KEY_RIGHT:
            if is_editing:
                current_config = CONFIG_OPTIONS[config_keys[current_row]]
                if current_config['type'] == 'select':
                    edit_index = (edit_index + 1) % len(current_config['options'])
        
        elif key in [10, 13, curses.KEY_ENTER]:  # Enter
            current_config = CONFIG_OPTIONS[config_keys[current_row]]
            
            if not is_editing:
                is_editing = True
                if current_config['type'] == 'select':
                    # Find current value index
                    try:
                        edit_index = current_config['options'].index(current_config['value'])
                    except ValueError:
                        edit_index = 0
            else:
                if current_config['type'] == 'input':
                    # Edit input field
                    label_len = len(current_config['label']) + 4
                    new_value = edit_input_field(
                        stdscr, 
                        content_start + 1 + current_row, 
                        2 + label_len,
                        current_config
                    )
                    current_config['value'] = new_value
                    is_editing = False
                elif current_config['type'] == 'select':
                    # Select option
                    current_config['value'] = current_config['options'][edit_index]
                    is_editing = False
        
        elif key == ord(' '):  # Space
            if is_editing:
                current_config = CONFIG_OPTIONS[config_keys[current_row]]
                if current_config['type'] == 'select':
                    current_config['value'] = current_config['options'][edit_index]
                    is_editing = False
        
        elif key == 9:  # Tab
            if is_editing:
                is_editing = False
            current_row = (current_row + 1) % len(config_keys)

def main():
    """Entry point"""
    try:
        result = curses.wrapper(main_tui)
        
        if result:
            print("\n" + "="*60)
            print("CONFIGURATION SAVED")
            print("="*60)
            for key, config in result.items():
                print(f"{config['label']:15s} = {config['value']}")
            print("="*60)
        else:
            print("\nInstallation cancelled.")
    
    except KeyboardInterrupt:
        print("\nInstallation cancelled.")
    except Exception as e:
        print(f"\nError: {e}")

if __name__ == '__main__':
    main()
