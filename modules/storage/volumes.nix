# Volume Management Configuration
# Additional volume mounts and bind mounts for data directories

{ config, lib, ... }:

{
  # This module is reserved for user-specific volume configurations
  # See .old/volumes.nix for an example configuration
  # 
  # Example use cases:
  # - Mount external drives by UUID
  # - Bind mount development directories (/data/docker, /data/python, etc.)
  # - Mount /home on a separate partition
  #
  # To use: uncomment the import in configuration.nix and customize this file
}
