{ pkgs, ... }:

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

    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # enable gpu for X
  services.xserver.videoDrivers = [ "amdgpu" ];

  # add lact (amd controller) + mesa
  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
