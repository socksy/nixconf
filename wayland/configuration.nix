{ config, pkgs, system, user, lib, inputs, ... }:

let
  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
  hyprland-flake = inputs.hyprland.packages.${pkgs.system}.hyprland;
  hyprland-nixpkgs =
    inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.system};

in {
  imports = [ # Include the results of the hardware scan.
    ../hardware-configuration.nix
    ./xps13.nix
  ];

  #environment.ld-linux = true;
  environment.systemPackages = with pkgs; [
    #dbus-sway-environment
    swaylock
    swayidle
    swaybg
    #swaymonad.defaultPackage.${system} # autotiler
    #eww-wayland
    kitty

    wofi
    rofi-wayland
    dbus
    configure-gtk
    wayland
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    dracula-theme # gtk theme
    gnome3.adwaita-icon-theme # default gnome cursors
    papirus-icon-theme
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wl-clipboard-x11 # legacy support for tools expecting x11
    wl-clip-persist # wayland only keeps things in clipboard while the app that put it there is open(!)
    cliphist # clipboard history manager
    mako # notification system developed by swaywm maintainer
    wdisplays # tool to configure displays
    wallutils # dynamic wallpapers and more

    # basic survival
    vim
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

    # core gui tools
    pavucontrol
    blueman
    vlc
    emacs29-pgtk
    # use later version
    #logseq
    mplayer
    xfce.thunar
    keepassxc

    # nice to haves
    anki-bin
    acpi
    baobab
    ncdu
    inkscape
    libreoffice
    pinta

  ];

  hardware = {
    pulseaudio.enable = false;
    opengl = {
      driSupport = true;
      driSupport32Bit = true;

      # matching mesa versions, see https://github.com/hyprwm/Hyprland/issues/5148

      package = hyprland-nixpkgs.mesa.drivers;
      package32 = hyprland-nixpkgs.pkgsi686Linux.mesa.drivers;

      # taking this from xps13.nix, not sure if it's really still necessary to
      # specify the drivers like this?
      #package = (hyprland-nixpkgs.mesa.override {
      #  galliumDrivers = ["nouveau" "virgl" "swrast" "iris" ];
      #}).drivers;
      #package32 = (hyprland-nixpkgs.pkgsi686Linux.mesa.override {
      #  galliumDrivers = ["nouveau" "virgl" "swrast" "iris" ];
      #}).drivers;
      # omg mesa compiling takes forever, giving up on this, hope it's ok
    };

    bluetooth = {
      enable = true;
      settings = {
        Policy = { AutoEnable = true; };
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

  #uncomment this line for protection on VPN
  # n.b. need ipv6 for CIDER jack in to work
  networking.enableIPv6 = true;
  networking.hostName = "benixos"; # Define your hostname.
  # the /etc/hosts
  networking.extraHosts = ''
    #put your favourite hosts file stuff here
    192.168.178.57 rpi
  '';
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.firewall.allowedTCPPortRanges = [{
    from = 8000;
    to = 8100;
  }];
  networking.networkmanager.enable = true;

  # no atime because it's to prevent so many USB drive writes
  fileSystems."/".options = [ "defaults" "noatime" ];
  fileSystems."/home".options = [ "defaults" "noatime" ];

  time.timeZone = "Europe/Berlin";

  location = {
    #Berlin
    latitude = 52.31;
    longitude = 13.22;
  };

  #programs.regreet.enable = true;
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${hyprland-flake}/bin/Hyprland";
        user = user;
      };
      default_session = initial_session;
    };
  };
  services = {
    #XSERVER.desktopManager.gnome.enable = true;
    #xserver.displayManager.gdm.enable = true;
    # pitch app requires this
    gnome.gnome-keyring.enable = true;

    # mainly for BIOS updates
    fwupd.enable = true;

    illum.enable = true;
    #nylas-mail.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;
    printing.drivers = [ pkgs.brlaser ];

    # run updatedb every night so locate works
    locate.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    dbus.packages = [ pkgs.gnome2.GConf.out ];
    dbus.enable = true;

    acpid.enable = true;
    udev.packages = [ pkgs.android-udev-rules ];

    redshift = {
      enable = true;
      package = pkgs.gammastep;

      temperature.day = 6500;
      #temperature.day = 2500;
    };

    avahi.enable = true;
    avahi.ipv6 = true;
    #enable if you want local networking printing. Disable if you want work VPN to work. :\
    avahi.nssmdns = true;
    #avahi.nssmdns = false;

    syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = user;
      #group = "users";
      dataDir = "/home/${user}/.syncthing";
    };

    blueman.enable = true;

    tlp.enable = true;
    thermald.enable = true;
    fstrim.enable = true;

    #interception-tools = {
    #  enable = true;
    #  # seems to be unneeded due to breakage https://github.com/NixOS/nixpkgs/issues/126681#issuecomment-860071968
    #  #plugins = [ unstable-pkgs.interception-tools-plugins.caps2esc ];
    #  udevmonConfig = ''
    #- JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
    #DEVICE:
    #  EVENTS:
    #    EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    #'';
    #};
    xremap = {
      withWlroots = true;
      userName = user;
      serviceMode = "user";
      config = {
        modmap = [
          {
            name = "Global";
            remap = {
              "Capslock" = {
                "held" = "Control_R";
                "alone" = "Esc";
                #"skip_key_event" = true;
              };
              "Esc" = {
                # don't be fooled, this actually assigns it to the menu key...
                # reassigning _that_ using xkboptions to compose:menu should
                # actually give you the compose key
                "alone" = "Compose";
                "held" = "RightAlt";
                #"skip_key_event" = true;
              };
            };
          }
          {
            name = "lisp-shiftkeys";
            application.not = "blender";

            remap = {
              "LeftShift" = {
                "held" = "LeftShift";
                "alone" = "KPLeftParen";
              };
              "RightShift" = {
                "held" = "RightShift";
                "alone" = "KPRightParen";
              };
            };
          }
          {
            name = "apple-keyboard";
            device.only = "Apple Inc. Magic Keyboard";
            remap = {
              "LeftMeta" = "LeftAlt";
              "LeftAlt" = "LeftMeta";
              "RightAlt" = "RightMeta";
              "RightMeta" = "RightAlt";
            };
          }
          {
            name = "xps-keyboard";
            device.only = "AT Translated Set 2 keyboard";
            remap = {
              "LeftMeta" = "LeftAlt";
              "LeftAlt" = "LeftMeta";
              "RightAlt" = "RightMeta";
            };
          }
        ];
        keymap = [
          {
            name = "Global";
            remap = {
              #"RightAlt-Enter" = "Super-Enter";
            };
          }
          {
            name = "Emacsy";
            remap = {
              "Super-a" = "C-a";
              "Super-z" = "C-z";
              "Super-x" = "C-x";
              "Super-c" = "C-c";
              "Super-Shift-c" = "Super-Shift-c";
              "Super-v" = "C-v";
              "Super-w" = "C-w";
              "Super-r" = "C-r";
              "Super-h" = "C-h";
              "Super-j" = "C-j";
              "Super-k" = "C-k";
              "Super-l" = "C-l";
              # very annoyingly have to always override the combos
              # if you just override one value
              "Super-Ctrl-h" = "Super-Ctrl-h";
              "Super-Ctrl-j" = "Super-Ctrl-j";
              "Super-Ctrl-k" = "Super-Ctrl-k";
              "Super-Ctrl-l" = "Super-Ctrl-l";
              "Super-Shift-h" = "Super-Shift-h";
              "Super-Shift-j" = "Super-Shift-j";
              "Super-Shift-k" = "Super-Shift-k";
              "Super-Shift-l" = "Super-Shift-l";
              "Super-LeftAlt-h" = "Super-LeftAlt-h";
              "Super-LeftAlt-j" = "Super-LeftAlt-j";
              "Super-LeftAlt-k" = "Super-LeftAlt-k";
              "Super-LeftAlt-l" = "Super-LeftAlt-l";
              "Super-LeftBrace" = "C-LeftBrace";
              "Super-RightBrace" = "C-RightBrace";
              "Super-Equal" = "C-Equal";
              "Super-Minus" = "C-Minus";
              "Super-t" = "C-t";
              "C-a" = "home";
              "C-e" = "end";
              "C-w" = [ "C-Shift-left" "delete" ];
            };
            application.not = [ "kitty" ];
          }
        ];
      };
    };

  };
  powerManagement.enable = true;

  #systemd.user.services.pulseaudio.environment = {
  #  JACK_PROMISCUOUS_SERVER = "jackaudio";
  #};

  security.sudo.enable = true;
  security.pki.certificateFiles = [
    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  ]; # "/etc/ssl/certs/prod01_intermediate_ca.pem" "/etc/ssl/certs/prod01_root_ca.pem"];

  # this would happen by default with programs.sway.enable
  security.pam.services.swaylock = { };

  programs.adb.enable = true;
  programs.autojump.enable = true;
  programs.direnv.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.light.enable = true;
  programs.mosh.enable = true;
  #programs.sway = {
  #  enable = true;
  #  wrapperFeatures.gtk = true;
  #};
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
  programs.waybar.enable = true;
  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.command-not-found.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.${user} = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/ben";
    shell = "${pkgs.zsh}/bin/zsh";
    description = "Ben Lovell";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "vboxusers"
      "tty"
      "docker"
      "scanner"
      "sync"
      "lp"
      "adbusers"
      "jackaudio"
      "input"
      "uinput"
      "networkmanager"
    ];
  };

  users.users.root.extraGroups = [ "grsecurity" "audio" "syncthing" ];

  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    GOROOT = "${pkgs.go.out}/share/go";
    GDK_SCALE = "2";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  #virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;
  #virtualisation.anbox.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "21.11";
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

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  i18n.inputMethod.enabled = "ibus";
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      anonymousPro
      aurulent-sans
      bakoma_ttf
      caladea
      cantarell-fonts
      carlito
      comfortaa
      corefonts
      crimson
      culmus
      dejavu_fonts
      dina-font
      eb-garamond
      emacs-all-the-icons-fonts
      etBook
      fantasque-sans-mono
      fira-code
      fira
      font-awesome
      gentium
      gyre-fonts
      hack-font
      hasklig
      helvetica-neue-lt-std
      iosevka
      inconsolata
      inter
      jetbrains-mono
      #  ipafont
      liberation_ttf
      libertine
      powerline-fonts
      terminus_font
      nerdfonts
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk
      ipaexfont
      kochi-substitute
      roboto
      source-code-pro
      source-sans-pro
      symbola
      #vistafonts
      ubuntu_font_family
      twemoji-color-font
    ];
    fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" ];
  };

  nix.settings = {
    substituters =
      [ "https://nix-community.cachix.org" "https://hyprland.cachix.org" ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8ZY7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
  nixpkgs.config.allowUnfree = true;
}
