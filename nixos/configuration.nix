# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, ... }:

{
  imports = [
      # Include the results of the hardware scan - always use the local machine version
      /etc/nixos/hardware-configuration.nix

      # Base system config + services
      ./system.nix

      # System + user packages
      ./packages.nix

      # hyprland
      #./hyprland/hyprland.nix
      #./hyprland/services.nix

      # cinnamon
      ./cinnamon.nix

      # tuxedo
      # ./tuxedo.nix

      # framework
      ./framework.nix
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
