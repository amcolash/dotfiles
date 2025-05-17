{ config, ... }:

{
  # Use cinnamon as the desktop environment
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.cinnamon.enable = true;
  };
}
