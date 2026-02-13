# Timezone Configuration
# Handles system timezone settings

{ config, ... }:

let
  cfg = config.system.config.locale;
in

{
  # Set system timezone
  time.timeZone = cfg.timezone;

  # Enable automatic timezone detection (optional)
  # services.automatic-timezoned.enable = true;
}
