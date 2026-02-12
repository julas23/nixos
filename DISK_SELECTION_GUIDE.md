# Interactive Disk Selection - User Guide

## Overview

The NixOS installation script now features an **interactive disk selection menu** that displays all available disks with detailed information, allowing users to select by number instead of manually typing device paths.

## Features

### 1. Automatic Disk Detection

The script automatically detects all available disks on the system, excluding:
- Loop devices (virtual loop mounts)
- ROM devices (CD/DVD drives)

### 2. Detailed Disk Information Table

Displays comprehensive information for each disk:

```
Available Disks:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
No.  Device          Size       Type     Model
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1    /dev/sda        500G       disk     Samsung SSD 860
2    /dev/nvme0n1    1T         disk     Samsung 970 EVO Plus
3    /dev/sdb        2T         disk     WDC WD20EZRZ-00Z
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Information Displayed**:
- **No.**: Selection number (1, 2, 3, ...)
- **Device**: Full device path (e.g., /dev/sda, /dev/nvme0n1)
- **Size**: Disk capacity in human-readable format
- **Type**: Device type (usually "disk")
- **Model**: Disk model name (manufacturer and model number)

### 3. Numeric Selection

Users select disks by entering the corresponding number:

```
Select disk number for installation (1-3): 2
```

**Benefits**:
- No need to remember device paths
- No risk of typos in device names
- Clear visual selection
- Validation prevents invalid choices

### 4. Input Validation

The script validates user input:
- Must be a number
- Must be within the valid range (1 to number of available disks)
- Invalid input prompts for re-entry with error message

**Example**:
```
Select disk number for installation (1-3): 5
[ERROR] Invalid selection! Please enter a number between 1 and 3.
Select disk number for installation (1-3):
```

### 5. Confirmation with Details

After selection, the script displays the chosen disk details and requires explicit confirmation:

```
Selected Disk:
  Device: /dev/nvme0n1
  Size:   1T
  Model:  Samsung 970 EVO Plus

[WARNING] ALL DATA ON THIS DISK WILL BE PERMANENTLY ERASED!

Are you absolutely sure you want to continue? (yes/no):
```

**Safety Features**:
- Clear warning about data loss
- Requires typing "yes" or "no" (not just y/n)
- Case-insensitive acceptance (yes, YES, Yes all work)
- Typing "no" safely exits without changes

## User Experience Flow

### Step 1: View Available Disks

The script automatically displays all detected disks in a formatted table.

### Step 2: Select Disk by Number

Enter the number corresponding to your desired installation disk.

### Step 3: Review Selection

The script shows the selected disk's details for verification.

### Step 4: Confirm or Cancel

- Type **"yes"** to proceed with installation
- Type **"no"** to cancel and exit safely

### Step 5: Installation Proceeds

After confirmation, the disk is partitioned and installation begins.

## Technical Implementation

### Disk Detection

```bash
# Get list of disks (excluding loop and rom devices)
mapfile -t DISK_NAMES < <(lsblk -d -n -o NAME -e 7,11)
mapfile -t DISK_SIZES < <(lsblk -d -n -o SIZE -e 7,11)
mapfile -t DISK_TYPES < <(lsblk -d -n -o TYPE -e 7,11)
mapfile -t DISK_MODELS < <(lsblk -d -n -o MODEL -e 7,11)
```

**Explanation**:
- `lsblk`: Lists block devices
- `-d`: Shows only disks (not partitions)
- `-n`: No headers
- `-o NAME,SIZE,TYPE,MODEL`: Specific columns
- `-e 7,11`: Exclude device types 7 (loop) and 11 (rom)
- `mapfile -t`: Stores output in arrays

### Table Display

```bash
printf "%-4s %-15s %-10s %-8s %-30s\n" "No." "Device" "Size" "Type" "Model"
```

Uses `printf` for aligned columns with fixed widths.

### Input Validation

```bash
if [[ "$DISK_NUM" =~ ^[0-9]+$ ]] && [ "$DISK_NUM" -ge 1 ] && [ "$DISK_NUM" -le "${#DISK_NAMES[@]}" ]; then
    # Valid input
else
    # Invalid input - prompt again
fi
```

**Checks**:
1. Input is numeric (`^[0-9]+$` regex)
2. Input is >= 1
3. Input is <= number of available disks

### Partition Naming

The script handles different disk types correctly:

```bash
if [[ $DISK == *"nvme"* ]] || [[ $DISK == *"mmcblk"* ]]; then
    BOOT_PART="${DISK}p1"
    ROOT_PART="${DISK}p2"
else
    BOOT_PART="${DISK}1"
    ROOT_PART="${DISK}2"
fi
```

**Examples**:
- `/dev/sda` → `/dev/sda1`, `/dev/sda2`
- `/dev/nvme0n1` → `/dev/nvme0n1p1`, `/dev/nvme0n1p2`
- `/dev/mmcblk0` → `/dev/mmcblk0p1`, `/dev/mmcblk0p2`

## Supported Disk Types

The interactive selection works with all common disk types:

### Traditional SATA/SCSI Disks
- `/dev/sda`, `/dev/sdb`, etc.
- Partitions: `/dev/sda1`, `/dev/sda2`

### NVMe SSDs
- `/dev/nvme0n1`, `/dev/nvme1n1`, etc.
- Partitions: `/dev/nvme0n1p1`, `/dev/nvme0n1p2`

### eMMC Storage
- `/dev/mmcblk0`, `/dev/mmcblk1`, etc.
- Partitions: `/dev/mmcblk0p1`, `/dev/mmcblk0p2`

### Virtual Disks (VMs)
- `/dev/vda`, `/dev/vdb`, etc.
- Partitions: `/dev/vda1`, `/dev/vda2`

## Safety Features

### 1. Explicit Confirmation Required

The script requires typing "yes" in full, not just "y":

```bash
while true; do
    read -p "Are you absolutely sure you want to continue? (yes/no): " CONFIRM_DISK
    case "$CONFIRM_DISK" in
        yes|YES)
            break
            ;;
        no|NO)
            log_error "Installation cancelled by user."
            exit 1
            ;;
        *)
            log_error "Please type 'yes' or 'no'."
            ;;
    esac
done
```

This prevents accidental confirmations.

### 2. Clear Warning Message

```
[WARNING] ALL DATA ON THIS DISK WILL BE PERMANENTLY ERASED!
```

Displayed in yellow color for high visibility.

### 3. Detailed Disk Information

Shows device path, size, and model to ensure correct disk is selected.

### 4. Safe Exit

Typing "no" or pressing Ctrl+C exits cleanly without making any changes.

## Configuration Summary

After installation, the selected disk information is included in the summary:

```
╔════════════════════════════════════════════════╗
║          SYSTEM CONFIGURATION SUMMARY          ║
╠════════════════════════════════════════════════╣
║ Disk:        /dev/nvme0n1 (1T)
║ Hostname:    myserver
║ Username:    julas
║ ...
╚════════════════════════════════════════════════╝
```

## Comparison: Old vs New

### Old Method (Manual Entry)

```
Detecting disks...
sda      500G  Samsung SSD 860
nvme0n1  1T    Samsung 970 EVO Plus
sdb      2T    WDC WD20EZRZ-00Z

Enter the disk path for installation (e.g., /dev/sda or /dev/nvme0n1): _
```

**Problems**:
- User must type full device path
- Risk of typos (e.g., `/dev/nvme0n` instead of `/dev/nvme0n1`)
- No clear visual separation of options
- Easy to select wrong disk

### New Method (Interactive Menu)

```
Available Disks:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
No.  Device          Size       Type     Model
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1    /dev/sda        500G       disk     Samsung SSD 860
2    /dev/nvme0n1    1T         disk     Samsung 970 EVO Plus
3    /dev/sdb        2T         disk     WDC WD20EZRZ-00Z
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Select disk number for installation (1-3): _
```

**Benefits**:
- Simple numeric selection
- No typing errors possible
- Clear table format
- Model information helps identification
- Input validation prevents mistakes

## Troubleshooting

### No Disks Detected

**Problem**: Script shows "No disks found!"

**Possible Causes**:
1. No physical disks connected
2. Disks not recognized by kernel
3. Running in unusual environment

**Solution**:
- Check physical connections
- Run `lsblk` manually to verify disk visibility
- Check kernel messages: `dmesg | grep -i disk`

### Disk Not Listed

**Problem**: Expected disk doesn't appear in the list

**Possible Causes**:
1. Disk is a loop or rom device (intentionally excluded)
2. Disk has issues and isn't detected
3. Disk is already mounted

**Solution**:
- Run `lsblk -a` to see all devices including excluded ones
- Check `dmesg` for disk errors
- Unmount any mounted partitions

### Wrong Partition Names

**Problem**: Partitions created with wrong naming

**Possible Causes**:
1. Unusual disk naming scheme
2. Script doesn't recognize disk type

**Solution**:
- The script handles nvme and mmcblk automatically
- For other types, partitions use standard naming (e.g., sda1, sda2)
- Check partition names after creation: `lsblk $DISK`

## Best Practices

### 1. Verify Disk Model

Always check the model name to ensure you're selecting the correct disk:
- Match the model with your physical hardware
- Check disk size to confirm
- If unsure, cancel and verify physically

### 2. Backup Important Data

Before running the installer:
- Backup all important data from the target disk
- Verify backups are complete and accessible
- Remember: ALL DATA WILL BE ERASED

### 3. Disconnect Unnecessary Disks

To avoid confusion:
- Disconnect external USB drives
- Disconnect secondary internal drives if not needed
- This reduces the risk of selecting the wrong disk

### 4. Use Live USB for Testing

Before actual installation:
- Boot the NixOS Live USB
- Run the script to see disk detection
- Cancel before confirmation to test without changes

## Future Enhancements

Potential improvements to disk selection:

1. **Partition Table Display**: Show existing partitions on each disk
2. **Disk Health Information**: Display SMART status if available
3. **Usage Status**: Indicate if disk is currently in use
4. **Color Coding**: Highlight recommended disks (e.g., SSDs in green)
5. **Advanced Options**: Support for custom partitioning schemes
6. **LVM/LUKS Support**: Options for encrypted or logical volumes

## Conclusion

The interactive disk selection feature significantly improves the installation experience:

✅ **Safer**: Clear confirmation required  
✅ **Easier**: Simple numeric selection  
✅ **Clearer**: Detailed disk information  
✅ **More Professional**: Formatted table display  
✅ **Less Error-Prone**: Input validation and verification  

This enhancement makes the NixOS installation process more user-friendly and reduces the risk of accidentally selecting the wrong disk.
