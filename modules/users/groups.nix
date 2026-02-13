# System Groups Configuration
# Defines common system groups

{ ... }:

{
  # Common system groups are already defined by NixOS
  # This file is reserved for custom group definitions
  
  users.groups = {
    # Example custom group:
    # developers = {
    #   gid = 2000;
    # };
  };
}
