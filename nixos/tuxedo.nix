{ config, ... }:

{
  # tuxedo drivers
  hardware.tuxedo-drivers.enable = true;

  # auto backlight off
  services.upower.enable = true;
  services.tp-auto-kbbl.enable = true;
}