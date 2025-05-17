{ pkgs, ... }:

{
    # Include services specific to a better Hyprland experience
  imports = [
    ./services.nix
  ];

  # Enable hyprland with XWayland support
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # portal for programs to talk to each other
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Packages to install alongside Hyprland
  environment.systemPackages = with pkgs; [
    # hyprland, waybar, wofi
    waybar	# status bar
    dunst	# notifications
    libnotify
    hyprpaper   # wallpaper
    wofi        # launcher
    wev         # wayland event helper

    # hyprland helpers
    hyprlock    # screen locker
    hyprshot    # take screenshots
    hyprpaper   # wallpaper manager
    hypridle    # idling tool

    # indicators
    indicator-sound-switcher
    networkmanagerapplet

    # utils
    pavucontrol # sound control
    nemo
  ];
}
