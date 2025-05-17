{ config, lib, pkgs, ... }:

let
  # load the device name from file (since the build can't read from system, copy before build w/ rebuild alias)
  device = lib.strings.trim(builtins.readFile ./device.txt);

  # choose either cinnamon or hyprland
  desktopEnvironment = "cinnamon";

in
{
  imports = [
    # Include the results of the hardware scan - always use the local machine version
    /etc/nixos/hardware-configuration.nix

    # Base system config
    ./system.nix

    # Localization settings
    ./localization.nix

    # System services
    ./services.nix

    # System + user packages
    ./packages.nix
  ]

  # conditionally load a DE configuration
  ++ lib.optionals (desktopEnvironment == "hyprland") [ ./hyprland/hyprland.nix ./hyprland/services.nix ]
  ++ lib.optionals (desktopEnvironment == "cinnamon") [ ./cinnamon.nix ]

  # conditionally import configurations for different devices
  ++ lib.optionals (device == "InfinityBook S 14 v5") [ ./tuxedo.nix ]
  ++ lib.optionals (device == "Laptop 13 (AMD Ryzen AI 300 Series)") [ ./framework.nix ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
