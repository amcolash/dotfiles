{ pkgs, ... }:

{
  services.udev.extraRules = ''
    # sayo mini 4x2 keyboard
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="8089", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="8089", MODE="0666"

    # keychron
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="02a0", MODE="0666"

    # Arduino UNO WiFi Rev2
    SUBSYSTEMS=="tty", ENV{ID_REVISION}=="03eb", ENV{ID_MODEL_ID}=="2145", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2145", MODE:="0666"

    # Arduino Nano Every
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0058", MODE:="0666"

    # ESP8266 / HL-340 Serial
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE:="0666"

    # automatic power profile switching when going to/from battery/ac
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
  '';
}
