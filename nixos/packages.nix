{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # services
    #upower

    # terminal tools
    vim
    wget
    git
    stow
    wev         # wayland event helper
    dos2unix
    tldr
    nix-search-cli

    # styling
    papirus-icon-theme
    papirus-folders
    matcha-gtk-theme
    apple-cursor

    # utils
    nemo
    baobab
    meld
    pavucontrol
    gnome-system-monitor

    # core programs
    google-chrome
    vscode

    # code
    nodejs_22

    # media + large tools
    gimp
    inkscape
    audacity
    vlc
    darktable
    libreoffice
    transmission_4
  ];

  fonts.packages = with pkgs; [
    corefonts
    font-awesome
    liberation_ttf
    nerdfonts
    noto-fonts
    noto-fonts-emoji
    vistafonts
  ];
}