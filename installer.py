#!/usr/bin/env python3
"""
NixOS Multi-Phase TUI Installer
Responsive design with framebuffer console support
Architecture: Dataclasses + JSON for configuration persistence
"""

import curses
import subprocess
import re
import json
import time
from dataclasses import dataclass, field, asdict
from typing import List, Optional, Tuple
from pathlib import Path

# ============================================================================
# CONFIGURATION DATACLASSES
# ============================================================================

@dataclass
class NetworkConfig:
    """Network configuration"""
    status: str = "checking"
    interface: Optional[str] = None
    ip: Optional[str] = None
    gateway: Optional[str] = None
    dns: List[str] = field(default_factory=list)
    ssid: Optional[str] = None
    validated: bool = False

@dataclass
class UserConfig:
    """User account configuration"""
    username: str = "user"
    fullname: str = ""
    uid: int = 1000
    gid: int = 1000
    group_name: str = "users"
    groups: List[str] = field(default_factory=lambda: ["wheel"])
    sudoer: bool = True
    nopasswd: bool = False
    root_password_set: bool = False
    validated: bool = False

@dataclass
class DiskConfig:
    """Disk/partition configuration"""
    device: str = ""
    size: str = ""
    model: str = ""
    lvm: bool = False
    zfs: bool = False
    vg_name: str = "vg_root"
    lv_name: str = "lv_root"
    filesystem: str = "ext4"
    mountpoint: str = "/"
    validated: bool = False

@dataclass
class EnvironmentConfig:
    """Graphics environment configuration"""
    graphics: str = "wayland"
    desktop: str = "cosmic"
    description: str = ""
    validated: bool = False

@dataclass
class DesktopConfig:
    """Desktop packages configuration"""
    stack: List[str] = field(default_factory=list)
    custom_packages: List[str] = field(default_factory=list)
    validated: bool = False

@dataclass
class InstallConfig:
    """Complete installation configuration"""
    network: NetworkConfig = field(default_factory=NetworkConfig)
    user: UserConfig = field(default_factory=UserConfig)
    disks: List[DiskConfig] = field(default_factory=list)
    environment: EnvironmentConfig = field(default_factory=EnvironmentConfig)
    desktop: DesktopConfig = field(default_factory=DesktopConfig)
    current_phase: int = 0
    
    def to_json(self, path: str):
        """Save configuration to JSON file"""
        with open(path, 'w') as f:
            json.dump(asdict(self), f, indent=2)
    
    @classmethod
    def from_json(cls, path: str):
        """Load configuration from JSON file"""
        with open(path, 'r') as f:
            data = json.load(f)
        
        config = cls()
        config.network = NetworkConfig(**data['network'])
        config.user = UserConfig(**data['user'])
        config.disks = [DiskConfig(**d) for d in data['disks']]
        config.environment = EnvironmentConfig(**data['environment'])
        config.desktop = DesktopConfig(**data['desktop'])
        config.current_phase = data['current_phase']
        return config
    
    def validate_phase(self, phase_idx: int) -> Tuple[bool, str]:
        """Validate a specific phase"""
        if phase_idx == 0:  # Network
            if self.network.status != "online":
                return False, "Network must be online to continue"
            self.network.validated = True
            return True, ""
        
        elif phase_idx == 1:  # User
            if not self.user.username or len(self.user.username) < 3:
                return False, "Username must be at least 3 characters"
            if not self.user.fullname:
                return False, "Full name is required"
            self.user.validated = True
            return True, ""
        
        elif phase_idx == 2:  # Disk
            if not self.disks:
                return False, "At least one disk must be configured"
            if not any(d.mountpoint == "/" for d in self.disks):
                return False, "Root (/) mountpoint is required"
            for disk in self.disks:
                disk.validated = True
            return True, ""
        
        elif phase_idx == 3:  # Environment
            if not self.environment.desktop:
                return False, "Desktop environment is required"
            self.environment.validated = True
            return True, ""
        
        elif phase_idx == 4:  # Desktop
            self.desktop.validated = True
            return True, ""
        
        return True, ""
    
    def is_complete(self) -> bool:
        """Check if all required phases are validated"""
        return (
            self.network.validated and
            self.user.validated and
            len(self.disks) > 0 and
            all(d.validated for d in self.disks) and
            self.environment.validated and
            self.desktop.validated
        )

# ============================================================================
# LAYOUT MODES
# ============================================================================

def get_layout_mode(height: int) -> str:
    """Determine layout mode based on terminal height"""
    if height < 30:
        return 'compact'
    elif height < 45:
        return 'normal'
    else:
        return 'expanded'

def safe_addstr(stdscr, y: int, x: int, text: str, attr=curses.A_NORMAL):
    """Safely add string to screen with bounds checking"""
    try:
        height, width = stdscr.getmaxyx()
        if y < 0 or y >= height or x < 0 or x >= width:
            return
        # Truncate text if it would go beyond screen width
        max_len = width - x - 1
        if max_len > 0:
            stdscr.addstr(y, x, text[:max_len], attr)
    except curses.error:
        pass  # Silently ignore curses errors

# ============================================================================
# SYSTEM INFORMATION
# ============================================================================

def get_system_info() -> dict:
    """Gather system information for header"""
    info = {}
    
    # CPU
    try:
        with open('/proc/cpuinfo', 'r') as f:
            cpuinfo = f.read()
            model = re.search(r'model name\s*:\s*(.+)', cpuinfo)
            info['cpu'] = model.group(1).strip()[:50] if model else 'Unknown'
            info['cores'] = str(len(re.findall(r'processor\s*:', cpuinfo)))
    except:
        info['cpu'] = 'Unknown'
        info['cores'] = '?'
    
    # Memory
    try:
        with open('/proc/meminfo', 'r') as f:
            mem_total = re.search(r'MemTotal:\s+(\d+)', f.read())
            if mem_total:
                mem_gb = int(mem_total.group(1)) // 1024 // 1024
                info['memory'] = f"{mem_gb} GB"
            else:
                info['memory'] = 'Unknown'
    except:
        info['memory'] = 'Unknown'
    
    # Disks
    try:
        result = subprocess.run(['lsblk', '-d', '-n', '-o', 'NAME,SIZE', '-e', '7,11'],
                              capture_output=True, text=True, timeout=5)
        disks = [d.strip() for d in result.stdout.strip().split('\n') if d]
        info['disks'] = ', '.join([f"{d.split()[0]}({d.split()[1]})" for d in disks if len(d.split()) >= 2])
    except:
        info['disks'] = 'Unknown'
    
    # Network
    try:
        result = subprocess.run(['ip', '-4', 'addr', 'show'],
                              capture_output=True, text=True, timeout=5)
        ips = re.findall(r'inet\s+(\d+\.\d+\.\d+\.\d+)', result.stdout)
        ips = [ip for ip in ips if not ip.startswith('127.')]
        info['ip'] = ', '.join(ips) if ips else 'No network'
    except:
        info['ip'] = 'Unknown'
    
    # Gateway
    try:
        result = subprocess.run(['ip', 'route', 'show', 'default'],
                              capture_output=True, text=True, timeout=5)
        gateway_match = re.search(r'default via (\d+\.\d+\.\d+\.\d+)', result.stdout)
        info['gateway'] = gateway_match.group(1) if gateway_match else 'N/A'
    except:
        info['gateway'] = 'N/A'
    
    # GPU
    try:
        result = subprocess.run(['lspci'], capture_output=True, text=True, timeout=5)
        gpu_match = re.search(r'VGA.*?:\s*(.+)', result.stdout)
        info['gpu'] = gpu_match.group(1).strip()[:50] if gpu_match else 'Unknown'
    except:
        info['gpu'] = 'Unknown'
    
    return info

def check_network_status() -> str:
    """Check if network is online"""
    try:
        result = subprocess.run(['ping', '-c', '1', '-W', '2', '8.8.8.8'],
                              capture_output=True, timeout=3)
        return "online" if result.returncode == 0 else "offline"
    except:
        return "offline"

# ============================================================================
# DRAWING FUNCTIONS - RESPONSIVE
# ============================================================================

def draw_header(stdscr, system_info: dict, mode: str):
    """Draw system information header (responsive)"""
    height, width = stdscr.getmaxyx()
    
    # Top border
    safe_addstr(stdscr, 0, 0, "╔" + "═" * (width - 2) + "╗")
    
    if mode == 'compact':
        # Compact: 1 line of info
        title = "NixOS Installer"
        safe_addstr(stdscr, 1, 2, title, curses.A_BOLD)
        
        # Single line with essential info
        info_line = f"CPU: {system_info.get('cpu', 'Unknown')[:20]} | {system_info.get('cores', '?')}c | {system_info.get('memory', '?')} | {system_info.get('ip', 'No net')}"
        safe_addstr(stdscr, 2, 2, info_line[:width-4])
        
        safe_addstr(stdscr, 3, 0, "╠" + "═" * (width - 2) + "╣")
        return 4
    
    elif mode == 'normal':
        # Normal: Current layout (7 lines)
        title = "NIXOS MULTI-PHASE INSTALLER"
        safe_addstr(stdscr, 1, (width - len(title)) // 2, title, curses.A_BOLD)
        
        info_lines = [
            f"CPU: {system_info.get('cpu', 'Unknown')} | Cores: {system_info.get('cores', '?')} | RAM: {system_info.get('memory', '?')}",
            f"GPU: {system_info.get('gpu', 'Unknown')}",
            f"Disks: {system_info.get('disks', 'Unknown')}",
            f"Network: {system_info.get('ip', 'Unknown')}"
        ]
        
        for i, line in enumerate(info_lines):
            safe_addstr(stdscr, 2 + i, 2, line[:width-4])
        
        safe_addstr(stdscr, 6, 0, "╠" + "═" * (width - 2) + "╣")
        return 7
    
    else:  # expanded
        # Expanded: More detailed info (10 lines)
        title = "NIXOS MULTI-PHASE INSTALLER"
        safe_addstr(stdscr, 1, (width - len(title)) // 2, title, curses.A_BOLD)
        
        subtitle = "Responsive Design with Framebuffer Support"
        safe_addstr(stdscr, 2, (width - len(subtitle)) // 2, subtitle, curses.A_DIM)
        
        info_lines = [
            "",
            f"CPU:     {system_info.get('cpu', 'Unknown')}",
            f"Cores:   {system_info.get('cores', '?')} | RAM: {system_info.get('memory', '?')}",
            f"GPU:     {system_info.get('gpu', 'Unknown')}",
            f"Disks:   {system_info.get('disks', 'Unknown')}",
            f"Network: {system_info.get('ip', 'Unknown')}",
            ""
        ]
        
        for i, line in enumerate(info_lines):
            if line:
                safe_addstr(stdscr, 3 + i, 2, line[:width-4])
        
        safe_addstr(stdscr, 10, 0, "╠" + "═" * (width - 2) + "╣")
        return 11

def draw_tabs(stdscr, row: int, phases: List[str], current_idx: int, config: InstallConfig, mode: str):
    """Draw phase tabs (responsive)"""
    height, width = stdscr.getmaxyx()
    
    if mode == 'compact':
        # Compact: Abbreviated tab names
        short_phases = ["Net", "User", "Disk", "Env", "Desk", "Rev"]
        tab_width = width // len(short_phases)
        col = 0
        
        for idx, phase in enumerate(short_phases):
            validated = False
            if idx == 0:
                validated = config.network.validated
            elif idx == 1:
                validated = config.user.validated
            elif idx == 2:
                validated = len(config.disks) > 0 and all(d.validated for d in config.disks)
            elif idx == 3:
                validated = config.environment.validated
            elif idx == 4:
                validated = config.desktop.validated
            elif idx == 5:
                validated = config.is_complete()
            
            status = "✓" if validated else "○"
            tab_text = f"{status}{phase}"
            
            attr = curses.A_REVERSE | curses.A_BOLD if idx == current_idx else curses.A_NORMAL
            
            if col + len(tab_text) + 1 < width:
                safe_addstr(stdscr, row, col, f" {tab_text}", attr)
            col += tab_width
    
    else:
        # Normal/Expanded: Full tab names
        tab_width = width // len(phases)
        col = 0
        
        for idx, phase in enumerate(phases):
            validated = False
            if idx == 0:
                validated = config.network.validated
            elif idx == 1:
                validated = config.user.validated
            elif idx == 2:
                validated = len(config.disks) > 0 and all(d.validated for d in config.disks)
            elif idx == 3:
                validated = config.environment.validated
            elif idx == 4:
                validated = config.desktop.validated
            elif idx == 5:
                validated = config.is_complete()
            
            status = "✓" if validated else "○"
            tab_text = f" {status} {phase} "
            
            attr = curses.A_REVERSE | curses.A_BOLD if idx == current_idx else curses.A_NORMAL
            
            if col + len(tab_text) < width:
                safe_addstr(stdscr, row, col, tab_text, attr)
            col += tab_width
    
    safe_addstr(stdscr, row + 1, 0, "╠" + "═" * (width - 2) + "╣")
    return row + 2

def draw_footer(stdscr, can_go_back: bool, can_go_next: bool, can_finish: bool, mode: str):
    """Draw footer with action buttons (responsive)"""
    height, width = stdscr.getmaxyx()
    
    # Ensure we have enough space
    if height < 5 or width < 20:
        return
    
    try:
        safe_addstr(stdscr, height - 4, 0, "╠" + "═" * (width - 2) + "╣")
        
        if mode == 'compact':
            # Compact: Shorter help text
            help_text = "Ctrl+←/→:Tabs | ↑↓:Nav | Enter:Edit | Esc:Abort"
            safe_addstr(stdscr, height - 3, 2, help_text[:width-4], curses.A_DIM)
        else:
            # Normal/Expanded: Full help text
            help_text = "Ctrl+←/→: Switch tabs | ↑↓: Navigate | Enter: Edit | Esc: Abort"
            safe_addstr(stdscr, height - 3, 2, help_text[:width-4], curses.A_DIM)
        
        # Buttons
        buttons = []
        buttons.append(("[F10] Abort", curses.A_DIM))
        
        if can_go_back:
            buttons.append(("[F2] Back", curses.A_NORMAL))
        
        if can_go_next:
            buttons.append(("[F3] Next", curses.A_BOLD))
        
        if can_finish:
            buttons.append(("[F4] Finish", curses.A_BOLD))
        
        button_text = "  ".join([b[0] for b in buttons])
        start_col = max(0, (width - len(button_text)) // 2)
        
        col = start_col
        for text, attr in buttons:
            if col + len(text) < width - 2:
                safe_addstr(stdscr, height - 2, col, text, attr)
                col += len(text) + 2
        
        safe_addstr(stdscr, height - 1, 0, "╚" + "═" * (width - 2) + "╝")
    except Exception:
        pass  # Silently handle any drawing errors

# ============================================================================
# PHASE IMPLEMENTATIONS (Same as before, but with scroll support)
# ============================================================================

def draw_network_phase(stdscr, start_row: int, config: InstallConfig, selected_line: int, mode: str):
    """Draw Network configuration phase"""
    height, width = stdscr.getmaxyx()
    row = start_row + 2
    
    stdscr.addstr(start_row, 2, "NETWORK CONFIGURATION", curses.A_BOLD)
    
    status = config.network.status
    status_color = curses.A_BOLD if status == "online" else curses.A_DIM
    
    lines = [
        f"Status: {status.upper()}",
        f"Interface: {config.network.interface or 'Not detected'}",
        f"IP Address: {config.network.ip or 'N/A'}",
        f"Gateway: {config.network.gateway or 'N/A'}",
        "",
        "Press 'c' to check network status",
        "Press 'n' to configure network manually (nmtui)"
    ]
    
    for idx, line in enumerate(lines):
        attr = curses.A_REVERSE if idx == selected_line else curses.A_NORMAL
        if row + idx < height - 5:
            stdscr.addstr(row + idx, 4, line[:width-8], attr)
    
    return len(lines)

def draw_user_phase(stdscr, start_row: int, config: InstallConfig, selected_line: int, mode: str):
    """Draw User configuration phase"""
    height, width = stdscr.getmaxyx()
    row = start_row + 2
    
    safe_addstr(stdscr, start_row, 2, "USER CONFIGURATION", curses.A_BOLD)
    
    # Format fields with proper alignment (left-aligned in brackets)
    lines = [
        f"Username:      [{config.user.username:<30s}]",
        f"Full Name:     [{config.user.fullname:<30s}]",
        f"UID:           [{str(config.user.uid):<30s}]",
        f"GID:           [{str(config.user.gid):<30s}]",
        f"Primary Group: [{config.user.group_name:<30s}]",
        f"Extra Groups:  [{', '.join(config.user.groups):<30s}]",
        f"Sudoer:        [{'YES' if config.user.sudoer else 'NO':<30s}]  <Space>",
        f"NOPASSWD:      [{'YES' if config.user.nopasswd else 'NO':<30s}]  <Space>",
        f"Root Password: [{'SET' if config.user.root_password_set else 'NOT SET':<30s}]  <Enter>",
    ]
    
    for idx, line in enumerate(lines):
        attr = curses.A_REVERSE if idx == selected_line else curses.A_NORMAL
        if row + idx < height - 5:
            safe_addstr(stdscr, row + idx, 4, line[:width-8], attr)
    
    if row + len(lines) + 2 < height - 5:
        safe_addstr(stdscr, row + len(lines) + 1, 4, "Enter: Edit | Space: Toggle YES/NO", curses.A_DIM)
        safe_addstr(stdscr, row + len(lines) + 2, 4, "Extra Groups: comma-separated (e.g., wheel,audio,video)", curses.A_DIM)
    
    return len(lines)

def draw_disk_phase(stdscr, start_row: int, config: InstallConfig, selected_line: int, mode: str):
    """Draw Disk configuration phase"""
    height, width = stdscr.getmaxyx()
    row = start_row + 2
    
    safe_addstr(stdscr, start_row, 2, "DISK CONFIGURATION", curses.A_BOLD)
    
    try:
        result = subprocess.run(['lsblk', '-d', '-n', '-o', 'NAME,SIZE,MODEL', '-e', '7,11'],
                              capture_output=True, text=True, timeout=5)
        available_disks = result.stdout.strip().split('\n')
    except:
        available_disks = []
    
    if not config.disks:
        safe_addstr(stdscr, row, 4, "Available Disks:", curses.A_BOLD)
        row += 1
        for idx, disk_line in enumerate(available_disks):
            parts = disk_line.split()
            if len(parts) >= 2:
                attr = curses.A_REVERSE if idx == selected_line else curses.A_NORMAL
                if row + idx < height - 5:
                    safe_addstr(stdscr, row + idx, 6, f"/dev/{parts[0]} - {parts[1]} - {' '.join(parts[2:]) if len(parts) > 2 else 'N/A'}"[:width-10], attr)
        
        if row + len(available_disks) + 1 < height - 5:
            safe_addstr(stdscr, row + len(available_disks) + 1, 4, "Press Enter to select disk", curses.A_DIM)
        return len(available_disks) + 2
    else:
        disk = config.disks[0]
        
        # Build lines with conditional display and proper formatting
        lines = []
        line_types = []  # Track what each line represents
        
        lines.append(f"Device:       {disk.device}")
        line_types.append('info')
        
        lines.append(f"Size:         {disk.size}")
        line_types.append('info')
        
        lines.append(f"LVM:          [{'YES' if disk.lvm else 'NO':<30s}]  <Space>")
        line_types.append('toggle')
        
        # LVM options (show in gray if LVM is disabled)
        if disk.lvm:
            lines.append(f"  VG Name:    [{disk.vg_name:<30s}]")
            line_types.append('edit')
            lines.append(f"  LV Name:    [{disk.lv_name:<30s}]")
            line_types.append('edit')
            lines.append(f"  ZFS:        [{'YES' if disk.zfs else 'NO':<30s}]  <Space>")
            line_types.append('toggle')
        else:
            lines.append(f"  VG Name:    [{disk.vg_name:<30s}]")
            line_types.append('disabled')
            lines.append(f"  LV Name:    [{disk.lv_name:<30s}]")
            line_types.append('disabled')
            lines.append(f"  ZFS:        [{'YES' if disk.zfs else 'NO':<30s}]")
            line_types.append('disabled')
        
        # Filesystem (conditional on ZFS)
        if disk.zfs:
            lines.append(f"Filesystem:   [ZFS (automatic)]")
            line_types.append('info')
        else:
            lines.append(f"Filesystem:   [{disk.filesystem:<30s}]")
            line_types.append('edit')
        
        lines.append(f"Mountpoint:   [{disk.mountpoint:<30s}]")
        line_types.append('edit')
        
        # Draw lines with appropriate attributes
        for idx, (line, line_type) in enumerate(zip(lines, line_types)):
            if idx == selected_line:
                attr = curses.A_REVERSE
            elif line_type == 'disabled':
                attr = curses.A_DIM  # Gray out disabled options
            else:
                attr = curses.A_NORMAL
            
            if row + idx < height - 5:
                safe_addstr(stdscr, row + idx, 4, line[:width-8], attr)
        
        if row + len(lines) + 2 < height - 5:
            safe_addstr(stdscr, row + len(lines) + 1, 4, "Enter: Edit | Space: Toggle | 'd': Change disk", curses.A_DIM)
            safe_addstr(stdscr, row + len(lines) + 2, 4, "LVM options shown in gray when LVM is disabled", curses.A_DIM)
        
        return len(lines)

def draw_environment_phase(stdscr, start_row: int, config: InstallConfig, selected_line: int, mode: str):
    """Draw Environment configuration phase"""
    height, width = stdscr.getmaxyx()
    row = start_row + 2
    
    stdscr.addstr(start_row, 2, "ENVIRONMENT CONFIGURATION", curses.A_BOLD)
    
    graphics_options = ["wayland", "xorg", "text"]
    desktop_options = {
        "wayland": ["cosmic", "hyprland", "gnome", "plasma", "sway"],
        "xorg": ["xfce", "mate", "i3", "awesome", "gnome"],
        "text": ["none"]
    }
    
    stdscr.addstr(row, 4, "Graphics:", curses.A_BOLD)
    row += 1
    for idx, opt in enumerate(graphics_options):
        selected = opt == config.environment.graphics
        attr = curses.A_REVERSE if idx == selected_line and selected_line < 3 else curses.A_NORMAL
        if selected:
            attr |= curses.A_BOLD
        if row < height - 5:
            stdscr.addstr(row, 6 + idx * 12, f"[{opt:8s}]", attr)
    
    row += 2
    
    stdscr.addstr(row, 4, "Desktop:", curses.A_BOLD)
    row += 1
    available_desktops = desktop_options.get(config.environment.graphics, [])
    for idx, opt in enumerate(available_desktops):
        selected = opt == config.environment.desktop
        line_idx = 3 + idx
        attr = curses.A_REVERSE if line_idx == selected_line else curses.A_NORMAL
        if selected:
            attr |= curses.A_BOLD
        if row + idx < height - 5:
            stdscr.addstr(row + idx, 6, f"[{opt:12s}]", attr)
    
    return 3 + len(available_desktops)

def draw_desktop_phase(stdscr, start_row: int, config: InstallConfig, selected_line: int, mode: str):
    """Draw Desktop packages phase"""
    height, width = stdscr.getmaxyx()
    row = start_row + 2
    
    stdscr.addstr(start_row, 2, "DESKTOP PACKAGES", curses.A_BOLD)
    
    default_stacks = {
        "cosmic": ["firefox", "kitty", "nautilus"],
        "gnome": ["firefox", "gnome-terminal", "nautilus"],
        "xfce": ["firefox", "xfce4-terminal", "thunar"],
        "hyprland": ["firefox", "kitty", "dolphin"],
    }
    
    stack = default_stacks.get(config.environment.desktop, ["firefox", "terminal"])
    
    stdscr.addstr(row, 4, "Default Stack:", curses.A_BOLD)
    row += 1
    for pkg in stack:
        if row < height - 5:
            stdscr.addstr(row, 6, f"• {pkg}")
            row += 1
    
    row += 1
    if row < height - 5:
        stdscr.addstr(row, 4, f"Custom Packages: [{', '.join(config.desktop.custom_packages) if config.desktop.custom_packages else 'None'}]")
        row += 1
    
    if row + 1 < height - 5:
        stdscr.addstr(row + 1, 4, "Press 'a' to add custom packages", curses.A_DIM)
    
    return 10

def draw_review_phase(stdscr, start_row: int, config: InstallConfig, selected_line: int, mode: str):
    """Draw Review phase"""
    height, width = stdscr.getmaxyx()
    row = start_row + 2
    
    stdscr.addstr(start_row, 2, "INSTALLATION REVIEW", curses.A_BOLD)
    
    lines = [
        "═" * (width - 8),
        "NETWORK",
        f"  Status: {config.network.status}",
        f"  IP: {config.network.ip or 'N/A'}",
        "",
        "USER",
        f"  Username: {config.user.username}",
        f"  Full Name: {config.user.fullname}",
        f"  Sudoer: {'Yes' if config.user.sudoer else 'No'}",
        "",
        "DISK",
    ]
    
    for disk in config.disks:
        lines.extend([
            f"  Device: {disk.device} ({disk.size})",
            f"  Filesystem: {disk.filesystem}",
            f"  Mountpoint: {disk.mountpoint}",
            f"  LVM: {'Yes' if disk.lvm else 'No'}",
        ])
    
    lines.extend([
        "",
        "ENVIRONMENT",
        f"  Graphics: {config.environment.graphics}",
        f"  Desktop: {config.environment.desktop}",
        "",
        "═" * (width - 8),
        "",
        "Press F4 to start installation" if config.is_complete() else "Complete all phases to continue"
    ])
    
    for idx, line in enumerate(lines):
        if row + idx < height - 5:
            stdscr.addstr(row + idx, 4, line[:width-8])
    
    return len(lines)

# ============================================================================
# WELCOME SCREEN
# ============================================================================

def show_welcome_screen(stdscr):
    """Show welcome screen with framebuffer recommendation"""
    height, width = stdscr.getmaxyx()
    mode = get_layout_mode(height)
    
    if mode == 'compact':
        stdscr.clear()
        stdscr.addstr(0, 0, "╔" + "═" * (width - 2) + "╗")
        stdscr.addstr(1, (width - 30) // 2, "NIXOS INSTALLER v1.0", curses.A_BOLD)
        stdscr.addstr(2, 0, "╠" + "═" * (width - 2) + "╣")
        
        stdscr.addstr(4, 2, f"Terminal: {height} lines × {width} columns")
        stdscr.addstr(6, 2, "⚠ RECOMMENDATION:", curses.A_BOLD)
        stdscr.addstr(8, 2, "For better experience, enable")
        stdscr.addstr(9, 2, "framebuffer console:")
        stdscr.addstr(11, 4, "1. Reboot")
        stdscr.addstr(12, 4, "2. Press 'e' at GRUB")
        stdscr.addstr(13, 4, "3. Add: vga=791")
        stdscr.addstr(14, 4, "4. Press F10")
        stdscr.addstr(16, 2, "This gives 40-50 lines!")
        
        stdscr.addstr(height - 4, 0, "╠" + "═" * (width - 2) + "╣")
        stdscr.addstr(height - 3, 2, "[Enter] Continue  [Esc] Exit")
        stdscr.addstr(height - 1, 0, "╚" + "═" * (width - 2) + "╝")
        
        stdscr.refresh()
        
        while True:
            key = stdscr.getch()
            if key in [10, 13, curses.KEY_ENTER]:
                return True
            elif key == 27:
                return False
    
    return True

# ============================================================================
# MAIN TUI CLASS
# ============================================================================

class MultiPhaseInstaller:
    def __init__(self):
        self.config = InstallConfig()
        self.phases = ["Network", "User", "Disk", "Environment", "Desktop", "Review"]
        self.current_phase = 0
        self.selected_line = 0
        self.system_info = get_system_info()
        self.layout_mode = 'normal'
        
        # Check initial network status
        self.config.network.status = check_network_status()
        if self.config.network.status == "online":
            self.config.network.validated = True
            try:
                result = subprocess.run(['ip', 'route', 'get', '8.8.8.8'],
                                      capture_output=True, text=True, timeout=5)
                interface_match = re.search(r'dev\s+(\S+)', result.stdout)
                if interface_match:
                    self.config.network.interface = interface_match.group(1)
                
                result = subprocess.run(['ip', '-4', 'addr', 'show', self.config.network.interface],
                                      capture_output=True, text=True, timeout=5)
                ip_match = re.search(r'inet\s+(\d+\.\d+\.\d+\.\d+)', result.stdout)
                if ip_match:
                    self.config.network.ip = ip_match.group(1)
                
                # Get gateway
                result = subprocess.run(['ip', 'route', 'show', 'default'],
                                      capture_output=True, text=True, timeout=5)
                gateway_match = re.search(r'default via (\d+\.\d+\.\d+\.\d+)', result.stdout)
                if gateway_match:
                    self.config.network.gateway = gateway_match.group(1)
            except:
                pass
    
    def run(self, stdscr):
        """Main TUI loop"""
        curses.curs_set(0)
        
        if curses.has_colors():
            curses.start_color()
            curses.use_default_colors()
        
        # Detect layout mode
        height, width = stdscr.getmaxyx()
        self.layout_mode = get_layout_mode(height)
        
        # Show welcome screen if compact
        if self.layout_mode == 'compact':
            if not show_welcome_screen(stdscr):
                return None
        
        while True:
            stdscr.clear()
            height, width = stdscr.getmaxyx()
            
            # Update layout mode dynamically
            self.layout_mode = get_layout_mode(height)
            
            # Draw header
            content_start = draw_header(stdscr, self.system_info, self.layout_mode)
            
            # Draw tabs
            phase_start = draw_tabs(stdscr, content_start, self.phases, self.current_phase, self.config, self.layout_mode)
            
            # Draw current phase
            if self.current_phase == 0:
                num_lines = draw_network_phase(stdscr, phase_start, self.config, self.selected_line, self.layout_mode)
            elif self.current_phase == 1:
                num_lines = draw_user_phase(stdscr, phase_start, self.config, self.selected_line, self.layout_mode)
            elif self.current_phase == 2:
                num_lines = draw_disk_phase(stdscr, phase_start, self.config, self.selected_line, self.layout_mode)
            elif self.current_phase == 3:
                num_lines = draw_environment_phase(stdscr, phase_start, self.config, self.selected_line, self.layout_mode)
            elif self.current_phase == 4:
                num_lines = draw_desktop_phase(stdscr, phase_start, self.config, self.selected_line, self.layout_mode)
            elif self.current_phase == 5:
                num_lines = draw_review_phase(stdscr, phase_start, self.config, self.selected_line, self.layout_mode)
            
            # Draw footer
            can_back = self.current_phase > 0
            can_next = self.current_phase < len(self.phases) - 1
            can_finish = self.current_phase == len(self.phases) - 1 and self.config.is_complete()
            draw_footer(stdscr, can_back, can_next, can_finish, self.layout_mode)
            
            stdscr.refresh()
            
            # Handle input
            key = stdscr.getch()
            
            if key == curses.KEY_F10 or key == 27:
                return None
            
            elif key == curses.KEY_F2:
                if self.current_phase > 0:
                    self.current_phase -= 1
                    self.selected_line = 0
            
            elif key == curses.KEY_F3:
                if self.current_phase < len(self.phases) - 1:
                    valid, msg = self.config.validate_phase(self.current_phase)
                    if valid or self.current_phase >= 4:
                        self.current_phase += 1
                        self.selected_line = 0
            
            elif key == curses.KEY_F4:
                if can_finish:
                    return self.config
            
            elif key == 560:  # Ctrl+Left
                if self.current_phase > 0:
                    self.current_phase -= 1
                    self.selected_line = 0
            
            elif key == 545:  # Ctrl+Right
                if self.current_phase < len(self.phases) - 1:
                    self.current_phase += 1
                    self.selected_line = 0
            
            elif key == curses.KEY_UP:
                self.selected_line = max(0, self.selected_line - 1)
            
            elif key == curses.KEY_DOWN:
                self.selected_line = min(num_lines - 1, self.selected_line + 1)
            
            elif key in [10, 13, curses.KEY_ENTER]:
                self.handle_enter(stdscr)
            
            elif key == ord(' '):  # Space key for toggles
                if self.current_phase == 1:  # User phase
                    if self.selected_line in [6, 7]:  # Sudoer or NOPASSWD
                        self.edit_user_field(stdscr)
                elif self.current_phase == 2 and self.config.disks:  # Disk phase
                    disk = self.config.disks[0]
                    if self.selected_line == 2:  # LVM toggle
                        self.edit_disk_field(stdscr)
                    elif self.selected_line == 5 and disk.lvm:  # ZFS toggle
                        self.edit_disk_field(stdscr)
            
            elif key == ord('c') and self.current_phase == 0:
                self.config.network.status = check_network_status()
                if self.config.network.status == "online":
                    self.config.network.validated = True
                    try:
                        # Update IP and gateway
                        result = subprocess.run(['ip', 'route', 'get', '8.8.8.8'],
                                              capture_output=True, text=True, timeout=5)
                        interface_match = re.search(r'dev\s+(\S+)', result.stdout)
                        if interface_match:
                            self.config.network.interface = interface_match.group(1)
                        
                        result = subprocess.run(['ip', '-4', 'addr', 'show', self.config.network.interface],
                                              capture_output=True, text=True, timeout=5)
                        ip_match = re.search(r'inet\s+(\d+\.\d+\.\d+\.\d+)', result.stdout)
                        if ip_match:
                            self.config.network.ip = ip_match.group(1)
                        
                        result = subprocess.run(['ip', 'route', 'show', 'default'],
                                              capture_output=True, text=True, timeout=5)
                        gateway_match = re.search(r'default via (\d+\.\d+\.\d+\.\d+)', result.stdout)
                        if gateway_match:
                            self.config.network.gateway = gateway_match.group(1)
                    except:
                        pass
            
            elif key == ord('n') and self.current_phase == 0:
                curses.endwin()
                subprocess.run(['nmtui'])
                stdscr = curses.initscr()
                self.config.network.status = check_network_status()
    
    def handle_enter(self, stdscr):
        """Handle Enter key press"""
        if self.current_phase == 1:
            self.edit_user_field(stdscr)
        elif self.current_phase == 2:
            self.edit_disk_field(stdscr)
        elif self.current_phase == 3:
            self.edit_environment_field()
    
    def edit_user_field(self, stdscr):
        """Edit user configuration field with proper alignment"""
        height, width = stdscr.getmaxyx()
        
        # Calculate the position of the bracket content
        # Format: "Label:  [content]"
        # The bracket starts at column 20 (4 indent + 16 label width)
        bracket_col = 20
        field_width = 30
        
        # Determine which row to edit based on layout
        layout_mode = get_layout_mode(height)
        if layout_mode == 'compact':
            base_row = 6  # 4 (header) + 2 (tabs)
        elif layout_mode == 'normal':
            base_row = 9  # 7 (header) + 2 (tabs)
        else:  # expanded
            base_row = 13  # 11 (header) + 2 (tabs)
        
        edit_row = base_row + self.selected_line
        
        if self.selected_line == 0:  # Username
            curses.echo()
            curses.curs_set(1)
            safe_addstr(stdscr, edit_row, bracket_col, " " * field_width)
            stdscr.refresh()
            try:
                value = stdscr.getstr(edit_row, bracket_col, field_width).decode('utf-8').strip()
                if value:
                    self.config.user.username = value
            except:
                pass
            curses.noecho()
            curses.curs_set(0)
        
        elif self.selected_line == 1:  # Full Name
            curses.echo()
            curses.curs_set(1)
            safe_addstr(stdscr, edit_row, bracket_col, " " * field_width)
            stdscr.refresh()
            try:
                value = stdscr.getstr(edit_row, bracket_col, field_width).decode('utf-8').strip()
                if value:
                    self.config.user.fullname = value
            except:
                pass
            curses.noecho()
            curses.curs_set(0)
        
        elif self.selected_line == 2:  # UID
            curses.echo()
            curses.curs_set(1)
            safe_addstr(stdscr, edit_row, bracket_col, " " * field_width)
            stdscr.refresh()
            try:
                value = stdscr.getstr(edit_row, bracket_col, field_width).decode('utf-8').strip()
                if value.isdigit():
                    self.config.user.uid = int(value)
            except:
                pass
            curses.noecho()
            curses.curs_set(0)
        
        elif self.selected_line == 3:  # GID
            curses.echo()
            curses.curs_set(1)
            safe_addstr(stdscr, edit_row, bracket_col, " " * field_width)
            stdscr.refresh()
            try:
                value = stdscr.getstr(edit_row, bracket_col, field_width).decode('utf-8').strip()
                if value.isdigit():
                    self.config.user.gid = int(value)
            except:
                pass
            curses.noecho()
            curses.curs_set(0)
        
        elif self.selected_line == 4:  # Primary Group
            curses.echo()
            curses.curs_set(1)
            safe_addstr(stdscr, edit_row, bracket_col, " " * field_width)
            stdscr.refresh()
            try:
                value = stdscr.getstr(edit_row, bracket_col, field_width).decode('utf-8').strip()
                if value:
                    self.config.user.group_name = value
            except:
                pass
            curses.noecho()
            curses.curs_set(0)
        
        elif self.selected_line == 5:  # Extra Groups
            curses.echo()
            curses.curs_set(1)
            safe_addstr(stdscr, edit_row, bracket_col, " " * field_width)
            stdscr.refresh()
            try:
                value = stdscr.getstr(edit_row, bracket_col, field_width).decode('utf-8').strip()
                if value:
                    # Parse comma-separated groups
                    groups = [g.strip() for g in value.split(',') if g.strip()]
                    self.config.user.groups = groups
            except:
                pass
            curses.noecho()
            curses.curs_set(0)
        
        elif self.selected_line == 6:  # Sudoer (toggle)
            self.config.user.sudoer = not self.config.user.sudoer
        
        elif self.selected_line == 7:  # NOPASSWD (toggle)
            self.config.user.nopasswd = not self.config.user.nopasswd
        
        elif self.selected_line == 8:  # Root Password
            import time
            curses.noecho()  # Disable echo for password
            curses.curs_set(1)
            
            # Show password input dialog
            dialog_height = 7
            dialog_width = 50
            dialog_y = (height - dialog_height) // 2
            dialog_x = (width - dialog_width) // 2
            
            # Draw dialog box
            for i in range(dialog_height):
                safe_addstr(stdscr, dialog_y + i, dialog_x, " " * dialog_width, curses.A_REVERSE)
            
            safe_addstr(stdscr, dialog_y + 1, dialog_x + 2, "Set Root Password", curses.A_REVERSE | curses.A_BOLD)
            safe_addstr(stdscr, dialog_y + 3, dialog_x + 2, "Password: ", curses.A_REVERSE)
            safe_addstr(stdscr, dialog_y + 4, dialog_x + 2, "Confirm:  ", curses.A_REVERSE)
            safe_addstr(stdscr, dialog_y + 6, dialog_x + 2, "Enter to save, Esc to cancel", curses.A_REVERSE | curses.A_DIM)
            
            stdscr.refresh()
            
            try:
                # Get password (without echo)
                password1 = stdscr.getstr(dialog_y + 3, dialog_x + 12, 30).decode('utf-8')
                password2 = stdscr.getstr(dialog_y + 4, dialog_x + 12, 30).decode('utf-8')
                
                if password1 and password1 == password2:
                    self.config.user.root_password_set = True
                    # In real implementation, store hashed password
                else:
                    # Show error briefly
                    safe_addstr(stdscr, dialog_y + 5, dialog_x + 2, "Passwords don't match!", curses.A_REVERSE | curses.A_BOLD)
                    stdscr.refresh()
                    time.sleep(1)
            except:
                pass
            
            curses.curs_set(0)
    
    def edit_disk_field(self, stdscr):
        """Edit disk configuration with toggles and conditional editing"""
        if not self.config.disks:
            # Selecting initial disk
            try:
                result = subprocess.run(['lsblk', '-d', '-n', '-o', 'NAME,SIZE,MODEL', '-e', '7,11'],
                                      capture_output=True, text=True, timeout=5)
                disks = result.stdout.strip().split('\n')
                if self.selected_line < len(disks):
                    parts = disks[self.selected_line].split()
                    if len(parts) >= 2:
                        disk = DiskConfig(
                            device=f"/dev/{parts[0]}",
                            size=parts[1],
                            model=' '.join(parts[2:]) if len(parts) > 2 else 'N/A'
                        )
                        self.config.disks.append(disk)
                        self.selected_line = 0
            except:
                pass
        else:
            # Editing disk configuration
            disk = self.config.disks[0]
            height, width = stdscr.getmaxyx()
            
            # Map selected_line to actual field
            # 0: Device (info)
            # 1: Size (info)
            # 2: LVM (toggle)
            # 3: VG Name (edit if LVM)
            # 4: LV Name (edit if LVM)
            # 5: ZFS (toggle if LVM)
            # 6: Filesystem (edit if not ZFS)
            # 7: Mountpoint (edit)
            
            if self.selected_line == 2:  # LVM toggle
                disk.lvm = not disk.lvm
                if not disk.lvm:
                    disk.zfs = False  # Disable ZFS if LVM is disabled
            
            elif self.selected_line == 3 and disk.lvm:  # VG Name
                bracket_col = 20
                field_width = 30
                layout_mode = get_layout_mode(height)
                if layout_mode == 'compact':
                    base_row = 6
                elif layout_mode == 'normal':
                    base_row = 9
                else:
                    base_row = 13
                edit_row = base_row + self.selected_line
                
                curses.echo()
                curses.curs_set(1)
                safe_addstr(stdscr, edit_row, bracket_col, " " * field_width)
                stdscr.refresh()
                try:
                    value = stdscr.getstr(edit_row, bracket_col, field_width).decode('utf-8').strip()
                    if value:
                        disk.vg_name = value
                except:
                    pass
                curses.noecho()
                curses.curs_set(0)
            
            elif self.selected_line == 4 and disk.lvm:  # LV Name
                bracket_col = 20
                field_width = 30
                layout_mode = get_layout_mode(height)
                if layout_mode == 'compact':
                    base_row = 6
                elif layout_mode == 'normal':
                    base_row = 9
                else:
                    base_row = 13
                edit_row = base_row + self.selected_line
                
                curses.echo()
                curses.curs_set(1)
                safe_addstr(stdscr, edit_row, bracket_col, " " * field_width)
                stdscr.refresh()
                try:
                    value = stdscr.getstr(edit_row, bracket_col, field_width).decode('utf-8').strip()
                    if value:
                        disk.lv_name = value
                except:
                    pass
                curses.noecho()
                curses.curs_set(0)
            
            elif self.selected_line == 5 and disk.lvm:  # ZFS toggle
                disk.zfs = not disk.zfs
                if disk.zfs:
                    disk.filesystem = "zfs"  # Set filesystem to ZFS
            
            elif self.selected_line == 6 and not disk.zfs:  # Filesystem
                # Show filesystem selection menu
                fs_options = ["ext4", "xfs", "btrfs", "f2fs"]
                current_idx = fs_options.index(disk.filesystem) if disk.filesystem in fs_options else 0
                
                # Cycle through options
                current_idx = (current_idx + 1) % len(fs_options)
                disk.filesystem = fs_options[current_idx]
            
            elif self.selected_line == 7:  # Mountpoint
                bracket_col = 20
                field_width = 30
                layout_mode = get_layout_mode(height)
                if layout_mode == 'compact':
                    base_row = 6
                elif layout_mode == 'normal':
                    base_row = 9
                else:
                    base_row = 13
                edit_row = base_row + self.selected_line
                
                curses.echo()
                curses.curs_set(1)
                safe_addstr(stdscr, edit_row, bracket_col, " " * field_width)
                stdscr.refresh()
                try:
                    value = stdscr.getstr(edit_row, bracket_col, field_width).decode('utf-8').strip()
                    if value:
                        disk.mountpoint = value
                except:
                    pass
                curses.noecho()
                curses.curs_set(0)
    
    def edit_environment_field(self):
        """Edit environment configuration"""
        if self.selected_line < 3:
            graphics_options = ["wayland", "xorg", "text"]
            self.config.environment.graphics = graphics_options[self.selected_line]
            self.config.environment.desktop = ""
        else:
            desktop_options = {
                "wayland": ["cosmic", "hyprland", "gnome", "plasma", "sway"],
                "xorg": ["xfce", "mate", "i3", "awesome", "gnome"],
                "text": ["none"]
            }
            available = desktop_options.get(self.config.environment.graphics, [])
            desktop_idx = self.selected_line - 3
            if desktop_idx < len(available):
                self.config.environment.desktop = available[desktop_idx]

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

def main():
    """Main entry point"""
    try:
        installer = MultiPhaseInstaller()
        result = curses.wrapper(installer.run)
        
        if result:
            config_path = '/tmp/nixos_install_config.json'
            result.to_json(config_path)
            
            print("\n" + "=" * 70)
            print("INSTALLATION CONFIGURATION SAVED")
            print("=" * 70)
            print(f"\nConfiguration saved to: {config_path}")
            print("\nSummary:")
            print(f"  Network:  {result.network.status}")
            print(f"  User:     {result.user.username} ({result.user.fullname})")
            print(f"  Disk:     {result.disks[0].device if result.disks else 'None'}")
            print(f"  Desktop:  {result.environment.desktop} on {result.environment.graphics}")
            print("=" * 70)
            
            print("\n# Shell variables:")
            print(f"hostname='{result.user.username}-nixos'")
            print(f"username='{result.user.username}'")
            print(f"fullname='{result.user.fullname}'")
            if result.disks:
                print(f"disk='{result.disks[0].device}'")
                print(f"filesystem='{result.disks[0].filesystem}'")
            print(f"graphics='{result.environment.graphics}'")
            print(f"desktop='{result.environment.desktop}'")
            
            return 0
        else:
            print("\nInstallation cancelled by user.")
            return 1
    
    except KeyboardInterrupt:
        print("\nInstallation cancelled.")
        return 1
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == '__main__':
    exit(main())
