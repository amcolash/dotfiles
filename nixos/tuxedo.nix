{ config, lib, ... }:

{
  # keyboard layout
  services.xserver.xkb = {
    variant = lib.mkForce "altgr-intl";
  };

  # tuxedo drivers
  hardware.tuxedo-drivers.enable = true;

  # auto backlight off
  services.upower.enable = true;
  services.tp-auto-kbbl.enable = true;
}
