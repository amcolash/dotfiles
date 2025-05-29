{ pkgs, ... }:

{
  services.udev.extraRules = ''
    # sayo mini 4x2 keyboard
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="8089", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="8089", MODE="0666"

    # automatic power profile switching when going to/from battery/ac
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
  '';
}
