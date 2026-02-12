# TUI Installer - Robust Architecture Proposal

## Vision: "Calamares" Text Mode

Create a professional, multi-phase TUI installer similar to Calamares but entirely text-based, with:

- **Multi-tab interface**: Network → User → Disk → Environment → Desktop → Review
- **System info header**: Always visible (CPU, RAM, disks, network, GPU)
- **Tab navigation**: Ctrl+Left/Right to switch tabs
- **Form navigation**: Ctrl+Up (top), Ctrl+Down (bottom/buttons)
- **Action buttons**: [Abort] [Back] [Next] [Finish]
- **Persistent state**: Configuration saved across tabs
- **Validation**: Real-time validation per phase
- **Review phase**: Complete overview before installation

---

## Architecture Options Analysis

### Option 1: SQLite3 Database (Your Suggestion)

**Concept**: Use SQLite to store configuration state

```python
import sqlite3

# Schema
CREATE TABLE config (
    key TEXT PRIMARY KEY,
    value TEXT,
    phase TEXT,
    validated BOOLEAN
);

CREATE TABLE disks (
    id INTEGER PRIMARY KEY,
    device TEXT,
    size TEXT,
    lvm BOOLEAN,
    zfs BOOLEAN,
    vg_name TEXT,
    lv_name TEXT,
    filesystem TEXT,
    mountpoint TEXT
);

CREATE TABLE packages (
    id INTEGER PRIMARY KEY,
    name TEXT,
    category TEXT,
    platform TEXT  -- wayland, xorg, both
);
```

**Pros**:
- ✅ Structured data storage
- ✅ Complex queries possible
- ✅ ACID transactions
- ✅ Easy to persist state to disk
- ✅ Can save/load installation profiles
- ✅ Rollback capability
- ✅ Multiple disk configurations easy to manage

**Cons**:
- ⚠️ Adds dependency (but sqlite3 is Python stdlib)
- ⚠️ Overkill for simple key-value storage
- ⚠️ More complex code
- ⚠️ Need to manage database lifecycle

**Best For**: Complex installations with profiles, multiple disks, package management

---

### Option 2: JSON Configuration File

**Concept**: Use JSON for structured configuration

```python
import json

config = {
    "network": {
        "status": "online",
        "interface": "eth0",
        "ip": "192.168.1.100",
        "validated": True
    },
    "user": {
        "username": "julas",
        "fullname": "Julas Silva",
        "uid": 1000,
        "groups": ["wheel", "docker"],
        "sudoer": True,
        "nopasswd": False,
        "validated": True
    },
    "disks": [
        {
            "device": "/dev/nvme0n1",
            "lvm": True,
            "vg_name": "vg_root",
            "lv_name": "lv_root",
            "filesystem": "ext4",
            "mountpoint": "/"
        }
    ],
    "environment": {
        "type": "wayland",
        "de": "cosmic",
        "validated": True
    },
    "desktop": {
        "stack": ["firefox", "kitty", "nautilus"],
        "custom": ["neovim", "tmux"]
    }
}

# Save
with open('/tmp/nixos_install_config.json', 'w') as f:
    json.dump(config, f, indent=2)

# Load
with open('/tmp/nixos_install_config.json', 'r') as f:
    config = json.load(f)
```

**Pros**:
- ✅ Simple and readable
- ✅ Python stdlib (no external deps)
- ✅ Easy to serialize/deserialize
- ✅ Human-readable for debugging
- ✅ Can save/load profiles
- ✅ Easy to validate structure

**Cons**:
- ⚠️ No built-in validation
- ⚠️ No transactions
- ⚠️ Need to load entire file for changes

**Best For**: Moderate complexity, profile support, human-readable configs

---

### Option 3: Python Dataclasses + Pickle

**Concept**: Use Python dataclasses for type safety

```python
from dataclasses import dataclass, field
from typing import List, Optional
import pickle

@dataclass
class NetworkConfig:
    status: str = "offline"
    interface: Optional[str] = None
    ip: Optional[str] = None
    validated: bool = False

@dataclass
class UserConfig:
    username: str = "user"
    fullname: str = ""
    uid: int = 1000
    gid: int = 1000
    groups: List[str] = field(default_factory=list)
    sudoer: bool = True
    nopasswd: bool = False
    validated: bool = False

@dataclass
class DiskConfig:
    device: str
    size: str
    lvm: bool = False
    zfs: bool = False
    vg_name: str = ""
    lv_name: str = ""
    filesystem: str = "ext4"
    mountpoint: str = ""

@dataclass
class InstallConfig:
    network: NetworkConfig = field(default_factory=NetworkConfig)
    user: UserConfig = field(default_factory=UserConfig)
    disks: List[DiskConfig] = field(default_factory=list)
    environment: dict = field(default_factory=dict)
    desktop: dict = field(default_factory=dict)
    
    def save(self, path: str):
        with open(path, 'wb') as f:
            pickle.dump(self, f)
    
    @classmethod
    def load(cls, path: str):
        with open(path, 'rb') as f:
            return pickle.load(f)

# Usage
config = InstallConfig()
config.user.username = "julas"
config.disks.append(DiskConfig(device="/dev/sda", size="500G"))
config.save('/tmp/nixos_config.pkl')
```

**Pros**:
- ✅ Type safety with type hints
- ✅ IDE autocomplete support
- ✅ Built-in validation via types
- ✅ Clean, Pythonic code
- ✅ Easy to extend
- ✅ No external dependencies

**Cons**:
- ⚠️ Pickle not human-readable
- ⚠️ Pickle security concerns (but we control the file)
- ⚠️ Need to define all structures upfront

**Best For**: Type-safe, maintainable code with IDE support

---

### Option 4: Python Dict + YAML (Hybrid)

**Concept**: Use dicts internally, YAML for persistence

```python
import yaml

config = {
    "network": {...},
    "user": {...},
    "disks": [...]
}

# Save (human-readable)
with open('/tmp/nixos_config.yaml', 'w') as f:
    yaml.dump(config, f, default_flow_style=False)

# Load
with open('/tmp/nixos_config.yaml', 'r') as f:
    config = yaml.safe_load(f)
```

**Pros**:
- ✅ Most human-readable format
- ✅ Easy to edit manually
- ✅ Comments supported
- ✅ Can be version controlled

**Cons**:
- ❌ Requires PyYAML (external dependency)
- ❌ Not in NixOS ISO by default
- ❌ Need to install during boot

**Best For**: If you're willing to add dependencies

---

## Recommendation: Hybrid Approach

### **Primary: Dataclasses + JSON**

Combine the best of both worlds:

```python
from dataclasses import dataclass, field, asdict
from typing import List, Optional
import json

@dataclass
class NetworkConfig:
    status: str = "offline"
    interface: Optional[str] = None
    ip: Optional[str] = None
    gateway: Optional[str] = None
    dns: List[str] = field(default_factory=list)
    validated: bool = False

@dataclass
class UserConfig:
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
    device: str
    size: str
    model: str
    lvm: bool = False
    zfs: bool = False
    vg_name: str = "vg_root"
    lv_name: str = "lv_root"
    filesystem: str = "ext4"
    mountpoint: str = "/"
    validated: bool = False

@dataclass
class EnvironmentConfig:
    graphics: str = "wayland"  # wayland, xorg, text
    desktop: str = "cosmic"
    description: str = ""
    validated: bool = False

@dataclass
class DesktopConfig:
    stack: List[str] = field(default_factory=list)
    custom_packages: List[str] = field(default_factory=list)
    validated: bool = False

@dataclass
class InstallConfig:
    network: NetworkConfig = field(default_factory=NetworkConfig)
    user: UserConfig = field(default_factory=UserConfig)
    disks: List[DiskConfig] = field(default_factory=list)
    environment: EnvironmentConfig = field(default_factory=EnvironmentConfig)
    desktop: DesktopConfig = field(default_factory=DesktopConfig)
    current_phase: str = "network"
    
    def to_json(self, path: str):
        """Save to JSON file"""
        with open(path, 'w') as f:
            json.dump(asdict(self), f, indent=2)
    
    @classmethod
    def from_json(cls, path: str):
        """Load from JSON file"""
        with open(path, 'r') as f:
            data = json.load(f)
        
        # Reconstruct dataclasses
        config = cls()
        config.network = NetworkConfig(**data['network'])
        config.user = UserConfig(**data['user'])
        config.disks = [DiskConfig(**d) for d in data['disks']]
        config.environment = EnvironmentConfig(**data['environment'])
        config.desktop = DesktopConfig(**data['desktop'])
        config.current_phase = data['current_phase']
        return config
    
    def validate_phase(self, phase: str) -> tuple[bool, str]:
        """Validate a specific phase"""
        if phase == "network":
            if self.network.status != "online":
                return False, "Network must be online"
            self.network.validated = True
            return True, ""
        
        elif phase == "user":
            if not self.user.username:
                return False, "Username is required"
            if len(self.user.username) < 3:
                return False, "Username must be at least 3 characters"
            self.user.validated = True
            return True, ""
        
        elif phase == "disk":
            if not self.disks:
                return False, "At least one disk must be configured"
            for disk in self.disks:
                if not disk.mountpoint:
                    return False, f"Mountpoint required for {disk.device}"
            # Check if we have a root mountpoint
            if not any(d.mountpoint == "/" for d in self.disks):
                return False, "Root (/) mountpoint is required"
            self.disks[0].validated = True
            return True, ""
        
        elif phase == "environment":
            if not self.environment.desktop:
                return False, "Desktop environment is required"
            self.environment.validated = True
            return True, ""
        
        elif phase == "desktop":
            self.desktop.validated = True
            return True, ""
        
        return False, "Unknown phase"
    
    def is_complete(self) -> bool:
        """Check if all phases are validated"""
        return (
            self.network.validated and
            self.user.validated and
            any(d.validated for d in self.disks) and
            self.environment.validated and
            self.desktop.validated
        )
```

**Why This Approach?**

1. ✅ **Type Safety**: Dataclasses provide structure and validation
2. ✅ **Human Readable**: JSON is easy to read/debug
3. ✅ **No External Deps**: Both json and dataclasses are stdlib
4. ✅ **IDE Support**: Full autocomplete and type checking
5. ✅ **Profile Support**: Easy to save/load configurations
6. ✅ **Validation**: Built-in per-phase validation
7. ✅ **Extensible**: Easy to add new fields
8. ✅ **Maintainable**: Clear structure

---

## Multi-Phase Architecture

### Phase Structure

```python
class Phase:
    """Base class for installation phases"""
    def __init__(self, name: str, title: str):
        self.name = name
        self.title = title
    
    def draw(self, stdscr, config: InstallConfig):
        """Draw the phase interface"""
        raise NotImplementedError
    
    def handle_input(self, key: int, config: InstallConfig) -> bool:
        """Handle keyboard input, return True if phase is complete"""
        raise NotImplementedError
    
    def validate(self, config: InstallConfig) -> tuple[bool, str]:
        """Validate phase configuration"""
        raise NotImplementedError

class NetworkPhase(Phase):
    def __init__(self):
        super().__init__("network", "Network Configuration")
    
    def draw(self, stdscr, config: InstallConfig):
        # Draw network configuration interface
        pass
    
    def handle_input(self, key: int, config: InstallConfig) -> bool:
        # Handle network configuration input
        pass
    
    def validate(self, config: InstallConfig) -> tuple[bool, str]:
        return config.validate_phase("network")

# Similar for UserPhase, DiskPhase, EnvironmentPhase, DesktopPhase, ReviewPhase
```

### Main TUI Loop

```python
class MultiPhaseInstaller:
    def __init__(self):
        self.config = InstallConfig()
        self.phases = [
            NetworkPhase(),
            UserPhase(),
            DiskPhase(),
            EnvironmentPhase(),
            DesktopPhase(),
            ReviewPhase()
        ]
        self.current_phase_idx = 0
    
    def run(self, stdscr):
        while True:
            # Draw header (system info)
            self.draw_header(stdscr)
            
            # Draw tab bar
            self.draw_tabs(stdscr)
            
            # Draw current phase
            current_phase = self.phases[self.current_phase_idx]
            current_phase.draw(stdscr, self.config)
            
            # Draw footer (buttons)
            self.draw_footer(stdscr)
            
            stdscr.refresh()
            
            # Handle input
            key = stdscr.getch()
            
            if key == curses.KEY_F10:  # Abort
                return None
            
            elif key == 545:  # Ctrl+Right
                if self.current_phase_idx < len(self.phases) - 1:
                    self.current_phase_idx += 1
            
            elif key == 560:  # Ctrl+Left
                if self.current_phase_idx > 0:
                    self.current_phase_idx -= 1
            
            elif key == 566:  # Ctrl+Up
                # Jump to top of form
                pass
            
            elif key == 525:  # Ctrl+Down
                # Jump to buttons
                pass
            
            else:
                # Pass to current phase
                current_phase.handle_input(key, self.config)
```

---

## Comparison: SQLite vs Dataclasses+JSON

| Aspect | SQLite | Dataclasses+JSON |
|--------|--------|------------------|
| **Complexity** | High | Medium |
| **Dependencies** | stdlib | stdlib |
| **Type Safety** | No | Yes |
| **Human Readable** | No | Yes |
| **Query Capability** | Excellent | Manual |
| **Transactions** | Yes | No |
| **IDE Support** | No | Yes |
| **Learning Curve** | Steeper | Gentler |
| **Overkill for this?** | Yes | No |
| **Profile Support** | Excellent | Good |
| **Validation** | Manual | Built-in |

---

## My Recommendation

### **Use Dataclasses + JSON**

**Reasons**:

1. **Right Level of Complexity**: Not too simple (plain dict), not too complex (SQLite)
2. **Type Safety**: Catches errors at development time
3. **Maintainable**: Clear structure, easy to understand
4. **No Overkill**: Perfect for this use case
5. **Human Readable**: JSON is easy to debug
6. **Profile Support**: Easy to save/load installation profiles
7. **Validation**: Built-in per-phase validation
8. **Zero Dependencies**: Everything in Python stdlib

**When to Use SQLite Instead**:

- If you need complex queries (e.g., "show all packages for wayland")
- If you need transactions and rollback
- If you're building a package database
- If you need to store hundreds of configurations
- If you need relational data with foreign keys

**For this installer**: Dataclasses + JSON is the sweet spot.

---

## Implementation Roadmap

### Phase 1: Core Architecture (4-6 hours)
- ✅ Define dataclass structure
- ✅ Implement InstallConfig with validation
- ✅ Create Phase base class
- ✅ Implement tab navigation
- ✅ JSON save/load

### Phase 2: Individual Phases (8-12 hours)
- NetworkPhase: Interface detection, SSID scanning, manual config
- UserPhase: User creation, groups, sudo, root password
- DiskPhase: Disk selection, LVM/ZFS, partitioning, mountpoints
- EnvironmentPhase: Graphics selection, DE/WM with descriptions
- DesktopPhase: Package stack, platform validation
- ReviewPhase: Complete overview, edit capability

### Phase 3: Integration (4-6 hours)
- System info header
- Tab bar with highlighting
- Footer buttons
- Keyboard shortcuts
- Validation flow

### Phase 4: Advanced Features (6-8 hours)
- Network configuration (nmcli integration)
- SSID scanning and WiFi setup
- LVM/ZFS configuration
- Package platform validation
- Installation progress tracking

**Total Estimated Time**: 22-32 hours for complete implementation

---

## Next Steps

1. **Agree on Architecture**: Dataclasses+JSON vs SQLite
2. **Define Complete Schema**: All fields for all phases
3. **Create Mockups**: Visual layout for each phase
4. **Implement Core**: Config classes and validation
5. **Build Phases**: One phase at a time
6. **Test**: In NixOS Live USB
7. **Iterate**: Based on feedback

---

## Questions to Consider

1. **Profile Support**: Do you want to save/load installation profiles?
2. **Network Config**: Should we integrate with nmcli/nmtui?
3. **Disk Partitioning**: Manual partitioning or guided only?
4. **Package Database**: Pre-defined package lists or dynamic?
5. **Validation Level**: Strict (block navigation) or permissive (warnings)?
6. **Installation Progress**: Real-time progress bar during install?

---

## Conclusion

**My Strong Recommendation: Dataclasses + JSON**

It's the perfect balance of:
- Structure (dataclasses)
- Flexibility (JSON)
- Type safety (Python type hints)
- Simplicity (no external deps)
- Maintainability (clear code)
- Debuggability (human-readable files)

SQLite would be overkill unless you're building a much more complex system with package databases, multiple profiles, and complex queries.

Let me know your thoughts, and we can start implementing the chosen architecture!
