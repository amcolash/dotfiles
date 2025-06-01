{ pkgs, ... }:

{
  # fingerprint reader
  services.fprintd.enable = true;

  boot = {
    # latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # use amd igpu
    initrd.kernelModules = [ "amdgpu" ];
  };

  # automatic ac/battery power profiles
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
  '';

  # enable graphics acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      rocmPackages.clr.icd
    ];
  };

  # enable rocm/HIP (like amd cuda)
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # enable gpu for X
  services.xserver.videoDrivers = [ "amdgpu" ];

  # add lact (amd controller)
  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
