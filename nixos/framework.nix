{ config, pkgs, ... }:

{
  # fingerprint reader
  services.fprintd.enable = true;

  # firmware updates
  services.fwupd.enable = true;

  boot = {
    # latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # use amd igpu
    kernelModules = [ "amdgpu" ];
  };

  # enable graphics acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    #package = unstable.mesa.drivers;
    #package32 = unstable.pkgsi686Linux.mesa.drivers;

    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # specify vaapi driver
  #services.frigate.vaapiDriver = "radeonsi";

  # enable gpu for X
  services.xserver.videoDrivers = [ "amdgpu" ];

  # force dri mode
  #services.xserver.config = ''
  #  Section "Device"
  #    Identifier "AMD Graphics"
  #    Driver "amdgpu"
  #    Option "DRI" "3" # Or try "2"
  ##  EndSection
  #'';

  # add lact (amd controller) + mesa
  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
