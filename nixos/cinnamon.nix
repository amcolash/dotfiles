{ pkgs, ... }:

{
  # install wallpaper for login/desktop
  environment.systemPackages = [
    (pkgs.stdenv.mkDerivation {
      name = "wallpaper";
      src = ./wallpaper.jpg;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share/backgrounds
        cp $src $out/share/backgrounds/wallpaper.jpg
      '';
    })
  ];

  # Use cinnamon as the desktop environment
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm = {
        enable = true;
        #greeters.slick.font.name = "Ubuntu 64";
        greeters.slick.extraConfig = ''
          background=/run/current-system/sw/share/backgrounds/wallpaper.jpg
          cursor-theme-name=macOS
          enable-hidpi=on
        '';
      };
    };
    desktopManager.cinnamon.enable = true;
  };
}
