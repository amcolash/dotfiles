{ pkgs, ... }:

{
  # PATH helper for nixos (use things like /bin/bash w/ symlink)
  services.envfs.enable = true;

  # file system + trash
  services.gvfs.enable = true;

  # enable virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  services.qemuGuest.enable =true;
  services.spice-vdagentd.enable = true;

  # enable gnome keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # enable ssh agent
  programs.ssh.startAgent = true;

  # enable avahi
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # help resolve local network dns
  services.resolved.enable = true;

  # Automatically install system updates daily
  #system.autoUpgrade = {
  #  enable = true;
  #  allowReboot = true;
  #  dates = "18:00"; # UTC = 12pm PDT / 11am PST
  #};
}
