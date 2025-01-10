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
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    #gfxmodeEfi = "1440x960";
    #font = "${pkgs.fira-code}/share/fonts/truetype/FiraCode-VF.ttf";
    #fontSize = 24;
    theme = (
      pkgs.sleek-grub-theme.override {
        withBanner = "Hi Ben";
        withStyle = "bigSur";
      }
    );
  };
  boot.plymouth = {
    enable = true;
    #theme = "cuts";
    #themePackages = with pkgs; [
    #  (adi1090x-plymouth-themes.override { selected_themes = [ "" ]; })
    #];
  };

  # Enable "Silent Boot"
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    #"initcall_blacklist=simpledrm_platform_driver_init"
  ];
  # Hide the OS choice for bootloaders.
  # It's still possible to open the bootloader list by pressing any key
  # It will just not appear on screen unless a key is pressed
  boot.loader.timeout = 5;

  boot.initrd.luks.devices."luks-d1e77924-0945-457d-b924-fe614e87069a".device =
    "/dev/disk/by-uuid/d1e77924-0945-457d-b924-fe614e87069a";
  networking.hostName = "fenixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
  ];
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
  ];
  services.resolved.enable = true;

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
      "libvirtd"
      "audio"
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
  nixpkgs.config.permittedInsecurePackages = [ "electron-27.3.11" ];
  nixpkgs.config.rocmSupport = true;
  nixpkgs.config.firefox.speechSynthesisSupport = true;
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
      trusted-users = root ben
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
    delta
    inputs.agenix.packages."${system}".default

    # basic survival
    git
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
    fzf
    btop
    htop
    python3
    jdk
    bc
    playerctl
    evince
    unzip
    tree
    #killall # useless on nixos?
    wget
    jq
    gh
    devenv
    eza # better ls
    expect
    hyprland-pkgs.zed-editor
    ispell
    mosh
    mob

    # core gui tools
    vlc
    ((emacsPackagesFor hyprland-pkgs.emacs30-pgtk).emacsWithPackages (epkgs: [
      epkgs.vterm
      epkgs.tree-sitter-langs
      epkgs.treesit-grammars.with-all-grammars
    ]))
    # use later version
    logseq
    discord
    hyprland-pkgs.keepassxc
    hyprland-pkgs.mplayer
    hyprland-pkgs.mpv
    hyprland-pkgs.slack
    hyprland-pkgs.spotify
    hyprland-pkgs.todoist-electron
    xfce.thunar
    hyprland-pkgs.mesa-demos
    hyprland-pkgs.chromium

    # programming tools
    clojure
    clojure-lsp
    go
    gopls
    nixd
    fennel
    fennel-ls
    opentofu
    terraform-ls

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
    hyprland-pkgs.ardour
    piper-tts
    speechd
    hyprland-pkgs.aider-chat
    vscode-fhs
    shotwell

    # miracast
    #gnome-network-displays

    # fun
    hyprland-pkgs.zeroad

    qemu_full
    hyprland-pkgs.quickemu
    #hyprland-pkgs.quickgui
    distrobox

    hyprland-pkgs.lmstudio
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.firefox.enable = true;

  programs.chromium.enable = true; # not enough, need to add package too
  programs.command-not-found.enable = false;

  programs.direnv.enable = true;
  programs.autojump.enable = true;
  programs.geary.enable = true;
  programs.steam.enable = true;
  #programs.steam.package = pkgs.hyprland-pkgs.steam;
  programs.steam.gamescopeSession.enable = true;
  #programs.gamescope.enable = true;
  programs.gamescope.package = pkgs.hyprland-pkgs.gamescope;
  programs.gamescope.capSysNice = true;

  programs.nm-applet.enable = true;

  # List services that you want to enable:

  # ability to flash firmware updates
  services.fwupd.enable = true;

  services.fprintd.enable = true;
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = username;
    dataDir = "/home/${username}/";
  };
  services.netbird.enable = true;

  age.secrets.searx_password.file = ../secrets/searx_password.age;

  services.searx = {
    enable = true;
    environmentFile = config.age.secrets.searx_password.path;
    settings.server = {
      bind_address = "0.0.0.0";
      port = 8584;
    };
    settings.search = {
      formats = [
        "html"
        "json"
      ];
    };
  };

  age.identityPaths = [ "/home/ben/.ssh/id_ed25519" ];

  # see https://github.com/NixOS/nixpkgs/issues/171136
  security.pam.services.login.fprintAuth = false;
  security.pam.services.swaylock.fprintAuth = false;
  security.pam.services.swaylock.allowNullPassword = true;

  # a bit useless
  #security.pam.services.gdm = {
  #  text = ''
  #    auth       required                    pam_shells.so
  #    auth       requisite                   pam_nologin.so
  #    auth       requisite                   pam_faillock.so      preauth
  #    auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
  #    auth       optional                    pam_permit.so
  #    auth       required                    pam_env.so
  #    auth       [success=ok default=1]      ${pkgs.gnome.gdm}/lib/security/pam_gdm.so
  #    auth       optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so

  #    account    include                     login

  #    password   required                    pam_deny.so

  #    session    include                     login
  #    session    optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
  #  '';
  #};

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
  services.ollama = {
    enable = true;
    package = pkgs.hyprland-pkgs.ollama;
    acceleration = "rocm";
    environmentVariables = {
      # `nix run nixpkgs#rocmPackages.rocminfo | grep gfx` to get latest
      HCC_AMDGPU_TARGET = "gfx1103";
      HSA_OVERRIDE_GFX_VERSION = "11.0.3";
      # switch from using system direct memory access to 'blit' kernels
      # trade-off - use up some compute kernels in order for it to not
      # think that there's only 4G RAM, which is what the chip reports
      # (integrated graphics goes variably up to half the system memory
      # depending on usage, i.e. 32G in this case)
      HSA_ENABLE_SDMA = "0";
    };
    # will only be available in nixos > 24.05 unfortunately
    #rocmOverrideGfx = "11.0.3";
  };
  services.open-webui = {
    # ollama gui
    enable = true;
    port = 10203;
    host = "0.0.0.0";
    package = pkgs.hyprland-pkgs.open-webui;
  };

  # tweak mouse dpi etc
  services.ratbagd.enable = true;

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
  virtualisation.podman.dockerCompat = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_full;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
      };
    };
  };

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
