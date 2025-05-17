{ config, pkgs, ... }:

{
  # Bootloader
  boot = {
    loader = {
      timeout = 2;

      systemd-boot = {
        enable = true;
        configurationLimit = 15;
        consoleMode = "2";
      };

      efi.canTouchEfiVariables = true;

      #grub = {
      #  enable = true;
      #  efiSupport = true;
      #  device = "nodev";
      #  fontSize = 64;
      #};
    };
    kernelParams = [ "quiet" "splash" "mem_sleep_default=deep" ];

    # Hide boot text
    plymouth.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  # firmware updates
  services.fwupd.enable = true;

  # networking
  networking = {
    hostName = "nixos"; # Define your hostname.

    # Enable networking
    networkmanager.enable = true;

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # longer timeout for sudo
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=20
  '';

  # set up suspend then hibernate
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=60min
  '';

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.amcolash = {
    isNormalUser = true;
    description = "Andrew McOlash";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
    shell = pkgs.bash;
  };

  # set up env vars
  environment = {
    systemPackages = with pkgs; [
      # allow faster reboot by bypassing bios: https://ash64.eu/blog/2023/rebooting-via-kexec
      (writeShellScriptBin "reboot-kexec" (builtins.readFile ./reboot-kexec.sh))

      vim
      git
    ];
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  # enable virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  services.qemuGuest.enable =true;
  services.spice-vdagentd.enable = true;

  # enable gnome keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  services.dbus.packages = [ pkgs.seahorse ];

  # enable ssh agent
  programs.ssh.startAgent = true;

  # Automatically install system updates daily
  #system.autoUpgrade = {
  #  enable = true;
  #  allowReboot = true;
  #  dates = "18:00"; # UTC = 12pm PDT / 11am PST
  #};

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    # larger download buffer
    settings = {
      download-buffer-size = 500000000;
    };
    # Run garbage collection on a weekly basis to avoid filling up disk
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
