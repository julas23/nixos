# Lsyncd Service Configuration
# Live Syncing Daemon - Automated file synchronization between volumes

{ config, lib, ... }:

{
  # This module is reserved for user-specific lsyncd configurations
  # See .old/lsyncd.nix for a complete example configuration
  #
  # Lsyncd provides live file synchronization between directories/volumes
  # using rsync. Useful for:
  # - Backup automation
  # - Mirror directories across drives
  # - Sync between local and network storage
  #
  # To use: uncomment the import in configuration.nix and customize this file
}
