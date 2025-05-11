{ config, pkgs, ... }:

{
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # bluetooth
  services.blueman.enable = true;

  # login screen
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd Hyprland";
      };
    };
  };

  # PATH helper for nixos (use things like /bin/bash w/ symlink)
  services.envfs.enable = true;

  # file system + trash
  services.gvfs.enable = true;

  # power profiles (low, perf, etc)
  services.power-profiles-daemon.enable = true;

  # enable audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
}