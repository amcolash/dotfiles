{ pkgs, ... }:

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
    tlrc # tldr rust client
    bat
    unzip
    atuin # better history
    blesh # bash line editor
    xclip
    btop
    fd
    dust
    ripgrep

    # terminal utils
    nix-search-cli
    usbutils # lsusb
    pciutils # lspci
    lshw
    lm_sensors
    minicom

    # styling
    nwg-look # change themes for everything
    (papirus-icon-theme.override { color = "teal"; })
    matcha-gtk-theme
    apple-cursor

    # extra DE programs
    baobab
    font-manager
    gparted
    gnome-system-monitor
    gnome-power-manager
    jstest-gtk
    cheese

    # utils
    meld
    filezilla
    rpi-imager
    solaar
    mqtt-explorer
    gnome-boxes # alternative to virtualbox

    # terminal
    kitty
    starship

    # browsers
    firefox
    google-chrome

    # languages and tools for code
    nodejs_22
    python313
    vscode
    arduino-ide

    # media
    gimp
    inkscape
    audacity
    vlc
    darktable
    spotify
    handbrake
    mkvtoolnix

    # misc
    cura-appimage
    discord
    libreoffice
    transmission_4
    rustdesk-flutter
  ];

  # fonts
  fonts.packages = with pkgs; [
    corefonts
    liberation_ttf
    nerd-fonts.sauce-code-pro
    nerd-fonts.ubuntu-mono
    noto-fonts
    noto-fonts-emoji
    vistafonts
  ];

  # docker
  virtualisation.docker.enable = true;
  users.users.amcolash.extraGroups = [ "docker" ];

  # steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
}
