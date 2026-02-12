# NixOS Configuration Index System

## Overview

The NixOS configuration now uses a **centralized configuration index** in `base.nix` that serves as both a declaration of all system settings and a single source of truth for the entire system configuration.

## Architecture

### The `install.system` Block

Located in `modules/base.nix`, this block contains all system configuration variables:

```nix
install.system = {
  # System Identity
  hostname = "nixos";
  
  # User Configuration
  user = "user";
  username = "user";
  
  # Hardware Configuration
  video = "amdgpu";
  
  # Graphics Configuration
  graphic = "wayland";
  desktop = "cosmic";
  
  # Locale and Regional Settings
  locale = "us";              # Legacy locale profile
  localeCode = "en_US.UTF-8"; # Full locale specification
  timezone = "America/Miami";
  
  # Keyboard Configuration
  keymap = "us";              # Console keymap
  xkbLayout = "us";           # X11/Wayland layout
  xkbVariant = "alt-intl";    # X11/Wayland variant
  
  # Optional Services
  ollama = "N";
  docker = "Y";
};
```

## Benefits

### 1. Single Source of Truth

All system configuration is declared in one place, making it easy to:
- Understand the current system configuration at a glance
- Audit what settings are applied
- Debug configuration issues
- Document the system state

### 2. Type Safety

The `vars.nix` module defines the schema with type checking:

```nix
options = {
  install.system = {
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "System hostname";
    };
    # ... more options
  };
};
```

This ensures:
- Invalid values are caught at build time
- Documentation is built-in
- IDE autocomplete works properly

### 3. Centralized Updates

The `install.sh` script updates all values in one location:

```bash
sed -i "s/hostname = \".*\";/hostname = \"$HOSTNAME\";/" "$BASE_FILE"
sed -i "s/username = \".*\";/username = \"$USERNAME\";/" "$BASE_FILE"
sed -i "s/video = \".*\";/video = \"$GPU\";/" "$BASE_FILE"
# ... etc
```

### 4. Configuration Reusability

Other modules can reference these values:

```nix
# In base.nix
time.timeZone = config.install.system.timezone;
networking.hostName = config.install.system.hostname;
console.keyMap = config.install.system.keymap;

# In activation scripts
chown -R ${config.install.system.username}:users /data
```

### 5. Conditional Module Activation

Modules use these values to determine if they should be active:

```nix
# amdgpu.nix
lib.mkIf (config.install.system.video == "amdgpu") { ... }

# cosmic.nix
lib.mkIf (config.install.system.desktop == "cosmic") { ... }

# Docker in base.nix
virtualisation.docker.enable = lib.mkIf (config.install.system.docker == "Y") true;
```

## Configuration Variables Reference

### System Identity

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `hostname` | string | "nixos" | System hostname |

### User Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `user` | enum | "user" | User profile to activate |
| `username` | string | "user" | Primary username |

### Hardware Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `host` | enum | "ryzen" | Host machine profile (ryzen, hp, think, server) |
| `video` | enum | "amdgpu" | GPU/Video driver (nvidia, amdgpu, intel, vm) |

### Graphics Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `graphic` | enum | "wayland" | Graphics server protocol (xorg, wayland) |
| `desktop` | enum | "cosmic" | Desktop environment (gnome, hyprland, i3, xfce, mate, cosmic, awesome) |

### Locale and Regional Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `locale` | enum | "us" | Legacy locale profile (us, br) - for module compatibility |
| `localeCode` | string | "en_US.UTF-8" | Full locale specification (e.g., en_US.UTF-8, pt_BR.UTF-8) |
| `timezone` | string | "America/Miami" | System timezone (e.g., America/Sao_Paulo, Europe/London) |

### Keyboard Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `keymap` | string | "us" | Console keyboard layout (us, br-abnt2, uk, de, fr, es) |
| `xkbLayout` | string | "us" | X11/Wayland keyboard layout (us, br, uk, de, fr, es) |
| `xkbVariant` | string | "alt-intl" | X11/Wayland keyboard variant |

### Storage Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enabledMounts` | list | [] | Additional filesystem mounts (nfs, usb, nvm, ssd) |

### Optional Services

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ollama` | enum | "N" | Enable Ollama AI service (Y, N) |
| `docker` | enum | "Y" | Enable Docker containerization (Y, N) |

## Usage Examples

### Querying Current Configuration

To see the current system configuration, simply read the `install.system` block in `base.nix`:

```bash
grep -A 20 "install.system = {" /etc/nixos/modules/base.nix
```

### Modifying Configuration

#### Method 1: Edit base.nix directly

```nix
install.system = {
  hostname = "myserver";
  username = "john";
  timezone = "Europe/Berlin";
  # ... other settings
};
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

#### Method 2: Use install.sh (for fresh installations)

The installation script automatically populates all values based on user input.

### Using Configuration Values in Custom Modules

```nix
{ config, lib, pkgs, ... }:

{
  # Example: Create a custom service that uses the username
  systemd.services.my-service = {
    description = "My Custom Service";
    serviceConfig = {
      User = config.install.system.username;
      ExecStart = "${pkgs.myapp}/bin/myapp";
    };
  };
  
  # Example: Conditional configuration based on GPU
  environment.systemPackages = lib.mkIf (config.install.system.video == "nvidia") [
    pkgs.cudatoolkit
  ];
}
```

## Migration from Old System

### Old Approach (Scattered Configuration)

Previously, configuration was scattered across multiple files:
- Username hardcoded as `@USERNAME@` placeholder
- Timezone in `locale-br.nix` and `locale-us.nix`
- Keymap hardcoded in locale files
- No centralized view of system state

### New Approach (Centralized Index)

Now everything is in one place:
- All values declared in `install.system` block
- Values referenced via `config.install.system.*`
- Single source of truth
- Easy to audit and modify

### Backward Compatibility

The system maintains backward compatibility:
- Legacy `locale` field ("us", "br") still works with existing modules
- New `localeCode` field provides full locale specification
- Both `@USERNAME@` placeholders and `config.install.system.username` work
- Existing modules continue to function without modification

## Best Practices

### 1. Always Update the Index

When adding new configuration options, update three places:
1. **vars.nix** - Add the option definition with type and default
2. **base.nix** - Add the value to `install.system` block
3. **install.sh** - Add sed command to update the value

### 2. Use Config References

Instead of hardcoding values, reference the config:

**Bad:**
```nix
chown -R myuser:users /data
```

**Good:**
```nix
chown -R ${config.install.system.username}:users /data
```

### 3. Document New Options

When adding new options to `vars.nix`, always include:
- Descriptive `description` field
- Appropriate `type` constraint
- Sensible `default` value

### 4. Keep Defaults Sensible

The default values in `install.system` should represent a common, working configuration.

## Troubleshooting

### Configuration Not Applied

If changes to `install.system` don't take effect:

1. Check if the module using the value is imported in `base.nix`
2. Verify the module uses `config.install.system.*` correctly
3. Rebuild with verbose output: `sudo nixos-rebuild switch --show-trace`

### Type Errors

If you get type errors:

1. Check `vars.nix` for the correct type definition
2. Ensure the value matches the enum options (if applicable)
3. Verify string values are properly quoted

### Module Not Activating

If a conditional module doesn't activate:

1. Check the `lib.mkIf` condition matches the value exactly
2. Verify the value in `install.system` is correct (case-sensitive)
3. Check if the module is imported in `base.nix`

## Future Enhancements

Potential improvements to the configuration system:

1. **Configuration Validation Script**: A script to validate the entire configuration before rebuild
2. **Configuration Diff Tool**: Show what changed between configurations
3. **Configuration Templates**: Pre-defined configurations for common use cases
4. **Interactive Configuration Editor**: TUI for editing configuration values
5. **Configuration Backup**: Automatic backup of configuration changes

## Conclusion

The centralized configuration index system provides:

✅ **Clarity**: All settings in one place  
✅ **Maintainability**: Easy to update and audit  
✅ **Type Safety**: Compile-time validation  
✅ **Flexibility**: Easy to extend with new options  
✅ **Documentation**: Self-documenting configuration  

This architecture makes the NixOS configuration more professional, maintainable, and easier to understand.
