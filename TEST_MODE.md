# Test Mode Documentation

## Overview

The NixOS installer now supports a **test/check mode** that validates your configuration without actually installing the system. This is useful for:

- Testing configuration changes before reinstalling
- Validating NixOS files in CI/CD pipelines
- Debugging configuration errors
- Learning NixOS configuration without risk

## Usage

### Basic Test Mode

```bash
./install.sh --check
```

or

```bash
./install.sh --test
```

Both flags do the same thing.

### What Happens in Test Mode

1. ✅ **All configuration steps run normally**:
   - Disk selection (but no actual partitioning)
   - Repository cloning
   - Hardware configuration generation
   - Interactive configurator wizard
   - Volume UUID detection

2. ✅ **Validation runs** (instead of installation):
   - **Step 1/3**: Syntax check with `nix-instantiate`
   - **Step 2/3**: Dry-build with `nixos-rebuild dry-build`
   - **Step 3/3**: Check for common issues (undefined variables, deprecated options)

3. ✅ **Results**:
   - If valid: Shows success message
   - If invalid: Shows detailed error messages
   - No actual installation happens
   - No passwords are set
   - No reboot occurs

### Example Output

**Success:**
```
[INFO] === VALIDATION MODE ===

[INFO] Validating NixOS configuration...

[INFO] Step 1/3: Checking syntax with nix-instantiate...
[SUCCESS] Syntax check passed

[INFO] Step 2/3: Dry-building configuration...
[SUCCESS] Dry-build completed successfully

[INFO] Step 3/3: Checking for common issues...

[SUCCESS] Configuration validation completed!
[INFO] All checks passed. Configuration is ready for installation.

[SUCCESS] ✅ Configuration is valid and ready for installation!
[INFO] To install, run the script without --check flag
```

**Failure:**
```
[ERROR] ❌ Configuration validation failed
[INFO] Please fix the errors above and try again
```

## Use Cases

### 1. Testing Before Reinstall

```bash
# Make changes to modules/
nano modules/desktop/gnome.nix

# Test the changes
./install.sh --check

# If valid, install
./install.sh
```

### 2. CI/CD Pipeline

```yaml
# .github/workflows/validate.yml
name: Validate NixOS Config
on: [push, pull_request]
jobs:
  validate:
    runs-on: nixos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Validate configuration
        run: ./install.sh --check
```

### 3. Learning NixOS

```bash
# Try different configurations without risk
./install.sh --check  # Test GNOME
# Change to KDE in wizard
./install.sh --check  # Test KDE
# etc.
```

## What Gets Validated

### ✅ Checked

- **Syntax errors** in .nix files
- **Undefined variables** and options
- **Deprecated options** (warnings)
- **Module imports** and dependencies
- **Package availability** in nixpkgs
- **Service conflicts**
- **Hardware compatibility** (basic)

### ❌ NOT Checked

- **Actual hardware** (disk space, RAM, etc.)
- **Network connectivity** during build
- **Boot configuration** (GRUB/systemd-boot)
- **Partition layout** (not actually created)
- **User passwords** (not set)

## Limitations

1. **Requires live environment**: Must run from NixOS installer ISO
2. **Disk operations still run**: Partitioning is selected but not executed
3. **No rollback**: If you modify files, they stay modified
4. **Dry-build limitations**: Some issues only appear during real installation

## Tips

- Use `--check` frequently when developing configurations
- Check the log file `/tmp/nixos-dryrun.log` for details
- Test mode is fast (no actual package downloads)
- Combine with version control (git) for safe experimentation

## Help

```bash
./install.sh --help
```

Shows usage information and available flags.
