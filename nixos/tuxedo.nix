{ lib, ... }:

{
  # keyboard layout
  services.xserver.xkb = {
    variant = lib.mkForce "altgr-intl";
  };

  # tuxedo drivers
  hardware.tuxedo-drivers.enable = true;
}
