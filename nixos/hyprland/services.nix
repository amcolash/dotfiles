{ pkgs, ... }:

{
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