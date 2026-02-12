# NixOS Installation Script - Testing Checklist

## Pre-Installation Validation

### Script Syntax
- [x] Bash syntax validation passed
- [x] No shell script errors detected

### Configuration Files
- [x] `install.sh` - Updated with new features
- [x] `modules/base.nix` - Updated with timezone, locale, keymap
- [x] `modules/vars.nix` - Existing structure maintained
- [x] `modules/user.nix` - User configuration ready

## New Features Implemented

### 1. Root Password Configuration
- [x] Root password prompt added (with confirmation)
- [x] Password mismatch validation
- [x] Root password setup script creation
- [x] Password applied via `nixos-enter` after installation

### 2. Docker Conditional Installation
- [x] Docker enable/disable prompt added
- [x] Docker configuration commented out when disabled
- [x] Docker-related filesystems handled conditionally

### 3. Timezone Configuration
- [x] Timezone selection menu with common options
- [x] Custom timezone input support
- [x] Applied to `base.nix` via sed

### 4. Locale Configuration
- [x] Locale selection (en_US.UTF-8, pt_BR.UTF-8, Custom)
- [x] Custom locale input support
- [x] Applied to `base.nix` i18n settings

### 5. Keymap Configuration
- [x] Console keymap selection (us, br-abnt2, uk, de, fr, es, Custom)
- [x] X11 layout selection
- [x] X11 variant input (default: alt-intl)
- [x] Applied to both console.keyMap and services.xserver.xkb

## Installation Flow

1. **Internet Check** → Validates connectivity
2. **Disk Selection** → Lists available disks
3. **Partitioning** → Creates EFI + Root partitions
4. **Repository Clone** → Downloads nixos config from GitHub
5. **Hardware Config** → Generates hardware-configuration.nix
6. **User Input Collection**:
   - Root password (with confirmation)
   - Username, user password (with confirmation), full name
   - Hostname
   - Timezone selection
   - Locale selection
   - Keymap selection
   - X11 layout and variant
   - GPU driver selection
   - GUI type (Wayland/Xorg)
   - Desktop environment
   - Docker enable/disable
   - Ollama enable/disable
7. **Configuration Application** → Updates .nix files with sed
8. **NixOS Installation** → Runs nixos-install
9. **Root Password Setup** → Sets root password in new system
10. **Summary Display** → Shows configuration summary
11. **Reboot Prompt** → Optional immediate reboot

## Testing Recommendations

### Manual Testing (on actual NixOS Live USB)
1. Boot NixOS Live USB
2. Connect to internet via `nmtui`
3. Download and run the script:
   ```bash
   sudo curl -L https://raw.githubusercontent.com/julas23/nixos/main/install.sh -o install.sh
   chmod +x install.sh
   sudo ./install.sh
   ```
4. Test all input prompts:
   - Verify password confirmation works
   - Test custom timezone input
   - Test custom locale input
   - Test custom keymap input
   - Verify Docker disable option
5. After installation:
   - Verify root login works with set password
   - Verify user login works
   - Check `timedatectl` for correct timezone
   - Check `localectl` for correct locale and keymap
   - Verify Docker status matches selection

### Edge Cases to Test
- [ ] Mismatched passwords (should retry)
- [ ] Custom timezone entry
- [ ] Custom locale entry
- [ ] Custom keymap entry
- [ ] Docker disabled (check if services are commented)
- [ ] NVMe disk (partition naming)
- [ ] SATA disk (partition naming)

## Known Limitations

1. **Nix Syntax Validation**: Cannot be fully validated in non-NixOS environment
2. **Docker Commenting**: The sed commands for commenting Docker config need careful testing
3. **Locale Files**: The script modifies base.nix directly instead of using locale-br.nix/locale-us.nix modules

## Improvements Made

### Security
- Password confirmation for both root and user
- Secure password input (hidden with `-s` flag)

### User Experience
- Clear section headers with colors
- Selection menus for common options
- Custom input fallback for advanced users
- Configuration summary before reboot
- Optional reboot prompt

### Flexibility
- Support for custom timezone, locale, and keymap
- Conditional Docker installation
- Multiple X11 layout options

## Files Modified

1. **install.sh** (273 lines)
   - Added root password collection
   - Added timezone/locale/keymap configuration
   - Added Docker conditional logic
   - Added configuration summary
   - Improved user prompts and validation

2. **modules/base.nix** (268 lines)
   - Added direct timezone configuration
   - Added direct locale configuration
   - Added console keymap configuration
   - Added X11 keyboard configuration
   - Maintained Docker configuration structure
   - Kept lsyncd.nix and volumes.nix commented

## Next Steps

1. Push changes to GitHub repository
2. Test on actual NixOS Live USB
3. Verify all configurations apply correctly
4. Update README.md with new features
5. Consider creating a video tutorial
