{ config, pkgs, ... }:

let
  # Override papirus-icon-theme to use a custom color
  papirus-icon-teal = pkgs.papirus-icon-theme.override {
    color = "teal"; # Change this to whatever color you want
  };
in
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
    papirus-icon-teal
    matcha-gtk-theme
    apple-cursor

    # utils
    nemo
    baobab
    meld
    kitty # terminal

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
