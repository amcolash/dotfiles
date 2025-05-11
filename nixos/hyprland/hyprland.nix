{ config, pkgs, ... }:

{
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # hyprland, waybar, wofi
    waybar	# status bar
    dunst	# notifications
    libnotify
    hyprpaper   # wallpaper
    wofi        # launcher

    # hyprland helpers
    hyprlock    # screen locker
    hyprshot    # take screenshots
    hyprpaper   # wallpaper manager
    hypridle    # idling tool

    # indicators
    indicator-sound-switcher
    networkmanagerapplet

    # styling tools
    unstable.nwg-look # (unstable) set/view gtk themes, cursors, icons
    font-manager

    # utils
    pavucontrol # sound control
    gnome-system-monitor
  ];
}