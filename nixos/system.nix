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

  # longer timeout (minutes) for sudo
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
