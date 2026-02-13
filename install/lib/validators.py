#!/usr/bin/env python3
"""
Validation Library
Validates user input and configuration choices
"""

import re
from typing import Tuple, Optional


def validate_hostname(hostname: str) -> Tuple[bool, Optional[str]]:
    """
    Validate hostname according to RFC 1123
    
    Returns:
        (is_valid, error_message)
    """
    if not hostname:
        return False, "Hostname cannot be empty"
    
    if len(hostname) > 63:
        return False, "Hostname must be 63 characters or less"
    
    # Hostname regex: alphanumeric and hyphens, cannot start/end with hyphen
    pattern = r'^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$'
    if not re.match(pattern, hostname, re.IGNORECASE):
        return False, "Hostname must contain only letters, numbers, and hyphens (cannot start/end with hyphen)"
    
    return True, None


def validate_username(username: str) -> Tuple[bool, Optional[str]]:
    """
    Validate Unix username
    
    Returns:
        (is_valid, error_message)
    """
    if not username:
        return False, "Username cannot be empty"
    
    if len(username) > 32:
        return False, "Username must be 32 characters or less"
    
    # Username regex: lowercase letters, numbers, underscore, hyphen
    # Must start with lowercase letter or underscore
    pattern = r'^[a-z_][a-z0-9_-]*$'
    if not re.match(pattern, username):
        return False, "Username must start with letter/underscore and contain only lowercase letters, numbers, underscore, hyphen"
    
    # Reserved usernames
    reserved = ["root", "bin", "daemon", "sys", "sync", "games", "man", "lp", "mail", "news", "uucp", "proxy", "www-data", "backup", "list", "irc", "gnats", "nobody", "systemd-network", "systemd-resolve", "systemd-timesync", "messagebus", "sshd", "nixbld"]
    if username in reserved:
        return False, f"Username '{username}' is reserved by the system"
    
    return True, None


def validate_fullname(fullname: str) -> Tuple[bool, Optional[str]]:
    """
    Validate full name
    
    Returns:
        (is_valid, error_message)
    """
    if not fullname:
        return False, "Full name cannot be empty"
    
    if len(fullname) > 128:
        return False, "Full name must be 128 characters or less"
    
    return True, None


def validate_uid_gid(value: int, name: str = "UID/GID") -> Tuple[bool, Optional[str]]:
    """
    Validate UID/GID
    
    Returns:
        (is_valid, error_message)
    """
    if value < 1000:
        return False, f"{name} must be 1000 or greater (0-999 reserved for system)"
    
    if value > 65535:
        return False, f"{name} must be 65535 or less"
    
    return True, None


def validate_disk_path(path: str) -> Tuple[bool, Optional[str]]:
    """
    Validate disk device path
    
    Returns:
        (is_valid, error_message)
    """
    if not path:
        return False, "Disk path cannot be empty"
    
    # Valid patterns: /dev/sda, /dev/nvme0n1, /dev/mmcblk0, /dev/vda
    pattern = r'^/dev/(sd[a-z]|nvme\d+n\d+|mmcblk\d+|vd[a-z]|hd[a-z])$'
    if not re.match(pattern, path):
        return False, "Invalid disk path (e.g., /dev/sda, /dev/nvme0n1)"
    
    return True, None


def validate_vg_name(name: str) -> Tuple[bool, Optional[str]]:
    """
    Validate LVM volume group name
    
    Returns:
        (is_valid, error_message)
    """
    if not name:
        return False, "Volume group name cannot be empty"
    
    if len(name) > 128:
        return False, "Volume group name must be 128 characters or less"
    
    # LVM name restrictions
    pattern = r'^[a-zA-Z0-9+_.-]+$'
    if not re.match(pattern, name):
        return False, "Volume group name can only contain letters, numbers, +, _, ., -"
    
    if name.startswith('-'):
        return False, "Volume group name cannot start with hyphen"
    
    return True, None


def validate_lv_name(name: str) -> Tuple[bool, Optional[str]]:
    """
    Validate LVM logical volume name
    
    Returns:
        (is_valid, error_message)
    """
    # Same rules as VG name
    return validate_vg_name(name)


def validate_zfs_pool_name(name: str) -> Tuple[bool, Optional[str]]:
    """
    Validate ZFS pool name
    
    Returns:
        (is_valid, error_message)
    """
    if not name:
        return False, "Pool name cannot be empty"
    
    if len(name) > 256:
        return False, "Pool name must be 256 characters or less"
    
    # ZFS pool name restrictions
    pattern = r'^[a-zA-Z][a-zA-Z0-9_.-]*$'
    if not re.match(pattern, name):
        return False, "Pool name must start with letter and contain only letters, numbers, _, ., -"
    
    # Reserved names
    reserved = ["mirror", "raidz", "raidz1", "raidz2", "raidz3", "spare", "log", "cache"]
    if name in reserved:
        return False, f"Pool name '{name}' is reserved by ZFS"
    
    return True, None


def validate_password(password: str, confirm: str = None) -> Tuple[bool, Optional[str]]:
    """
    Validate password strength
    
    Returns:
        (is_valid, error_message)
    """
    if not password:
        return False, "Password cannot be empty"
    
    if len(password) < 8:
        return False, "Password must be at least 8 characters"
    
    if confirm is not None and password != confirm:
        return False, "Passwords do not match"
    
    return True, None


if __name__ == "__main__":
    # Test validators
    tests = [
        ("hostname", validate_hostname, ["my-server", "nixos", "test123", "-invalid", "a" * 64]),
        ("username", validate_username, ["julas", "user123", "root", "Invalid", "123user"]),
        ("disk", validate_disk_path, ["/dev/sda", "/dev/nvme0n1", "/dev/invalid", "sda"]),
    ]
    
    for name, validator, values in tests:
        print(f"\nTesting {name}:")
        for value in values:
            valid, msg = validator(value)
            status = "✓" if valid else "✗"
            print(f"  {status} {value}: {msg or 'OK'}")
