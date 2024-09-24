# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  system,
  username,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../modules/hyprland.nix
  ];
  hyprland.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-d1e77924-0945-457d-b924-fe614e87069a".device = "/dev/disk/by-uuid/d1e77924-0945-457d-b924-fe614e87069a";
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  location = {
    #Berlin
    latitude = 52.31;
    longitude = 13.22;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ben = {
    name = username;
    isNormalUser = true;
    description = "Benjamin Jame Lovell";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = "${pkgs.zsh}/bin/zsh";
    uid = 1000;
    packages = with pkgs; [
      inputs.bens-ags
      #  thunderbird
    ];
  };

  users.users.root.extraGroups = [
    "grsecurity"
    "audio"
    "syncthing"
  ];

  # Enable automatic login for the user.
  #services.displayManager.autoLogin.enable = true;
  #services.displayManager.autoLogin.user = "ben";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.rocmSupport = true;
  nix = {
    package = pkgs.nixVersions.latest;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
      experimental-features = nix-command flakes
    '';
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #glib # gsettings
    #dracula-theme # gtk theme
    #gnome3.adwaita-icon-theme # default gnome cursors
    papirus-icon-theme
    yadm
    nix-output-monitor
    nixfmt-rfc-style
    git
    delta

    # basic survival
    vim
    neovim
    starship
    keychain
    tarsnap
    lsof
    rlwrap
    which
    zip
    zsh
    ripgrep
    fd
    tldr
    btop
    htop
    python3
    jdk
    bc
    playerctl
    evince
    clojure
    clojure-lsp
    unzip
    tree
    #killall # useless on nixos?
    wget
    jq
    gh

    # core gui tools
    vlc
    ((emacsPackagesFor emacs29-pgtk).emacsWithPackages (epkgs: [ epkgs.vterm ]))
    #emacs29-pgtk
    # use later version
    #logseq
    discord
    keepassxc
    mplayer
    mpv
    slack
    spotify
    xfce.thunar
    mesa-demos

    # nice to haves
    anki-bin
    acpi
    baobab
    ncdu
    inkscape
    #libreoffice
    pinta
    signal-desktop
    telegram-desktop

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.command-not-found.enable = false;

  programs.direnv.enable = true;
  programs.autojump.enable = true;

  # List services that you want to enable:

  # ability to flash firmware updates
  services.fwupd.enable = true;
  # brightness keys
  services.illum.enable = true;
  # SSH server
  services.openssh.enable = true;
  services.blueman.enable = true;
  # cups and brother laser printer driver
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];
  # run updatedb every night so locate works
  services.locate.enable = true;
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };
  services.fstrim.enable = true;

  # AI stuff
  services.ollama.enable = true;
  services.ollama.package = pkgs.unstable.ollama;
  # ollama gui
  #services.open-webui.enable = true;
  #services.open-webui.port = 10203;

  hardware = {
    bluetooth = {
      enable = true;
      settings = {
        Policy = {
          AutoEnable = true;
        };
        General = {
          PairableTimeout = 0;
          DiscoverableTimeout = 0;
          RememberPowered = false;
          MultiProfile = "multiple";
        };
      };
    };

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    # enable scanning firmware
    sane = {
      enable = true;
      brscan4.enable = true;
      brscan4.netDevices = {
        livingRoom = {
          model = "DCP-1610W";
          ip = "192.168.178.62";
        };
      };
    };

    uinput.enable = true;
  };

  security.sudo.enable = true;
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];

  virtualisation.podman.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
