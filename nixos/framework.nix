{ pkgs, ... }:

{
  #boot.resumeDevice = "/dev/disk/by-uuid/83c2d287-6496-4f0a-9307-086be53ca47d";
  boot.resumeDevice = "/dev/nvme0n1p4";

  # add lact (amd controller)
  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
