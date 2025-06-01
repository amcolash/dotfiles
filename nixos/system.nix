{ pkgs, ... }:

{
  # Bootloader
  boot = {
    loader = {
      timeout = 2;

      #systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        configurationLimit = 15;
        efiSupport = true;
        device = "nodev";
        font = "${pkgs.nerd-fonts.sauce-code-pro}/share/fonts/truetype/NerdFonts/SauceCodePro/SauceCodeProNerdFontMono-Regular.ttf";
        fontSize = 28;
      };
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
    networkmanager = {
      enable = true;
    };

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];

    # KDE connect
    firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

  #fileSystems."/mnt/nas" = {
  #  device = "amcolash@192.168.1.101:~";
  #  fsType = "sshfs";
  #  options = [
  #    "nodev"
  #    "noatime"
  #    "allow_other"
  #    "reconnect"              # handle connection drops
  #    "ServerAliveInterval=15" # keep connections alive
  #    "IdentityFile=/home/amcolash/.ssh/id_ed25519"
  #  ];
  #};

  environment.etc."rclone-mnt.conf".text = ''
    [nas]
    type = sftp
    host = 192.168.1.101
    user = amcolash
    key_file = /root/.ssh/id_ed25519
  '';

  fileSystems."/mnt/nas" = {
    device = "nas:~/";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      #"x-systemd.automount"  # mount on demand
      #"reconnect"              # handle connection drops
      #"ServerAliveInterval=15" # keep connections alive
      "config=/etc/rclone-mnt.conf"
    ];
  };

  # longer timeout (minutes) for sudo
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=20
  '';

  # set up suspend then hibernate
  #systemd.sleep.extraConfig = ''
  #  AllowSuspendThenHibernate=yes
  #  HibernateDelaySec=60min
  #  SuspendState=mem
  #'';

  #services.logind = {
  #  lidSwitch = "suspend-then-hibernate";
  #  lidSwitchDocked = "suspend-then-hibernate";
  #  lidSwitchExternalPower = "suspend-then-hibernate";
  #};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.amcolash = {
    isNormalUser = true;
    description = "Andrew McOlash";
    extraGroups = [ "networkmanager" "plugdev" "wheel" "video" ];
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

    # Run garbage collection on a daily basis to avoid filling up disk
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 15d";
    };
  };
}
