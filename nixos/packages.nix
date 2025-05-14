{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # terminal tools
    vim
    wget
    git
    stow
    dos2unix
    tldr
    bat
    unzip
    atuin # better history
    blesh # bash line editor
    xclip
    btop

    # utils
    nix-search-cli
    usbutils # lsusb
    pciutils # lspci
    lshw

    # styling
    (papirus-icon-theme.override { color = "teal"; })
    matcha-gtk-theme
    apple-cursor

    # utils
    baobab
    meld
    font-manager
    gparted
    gnome-system-monitor

    # terminal
    kitty
    starship

    # core programs
    firefox
    google-chrome
    vscode

    # code
    nodejs_22
    python313

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
    liberation_ttf
    (nerdfonts.override { fonts = [ "UbuntuMono" "SourceCodePro" ]; }) # note: may break in future versions of nix: https://nixos.wiki/wiki/Fonts
    noto-fonts
    noto-fonts-emoji
    vistafonts
  ];
}
