{ config, pkgs, lib, ... }:


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

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./xps13.nix
    ];

    #environment.ld-linux = true;
    environment.systemPackages = with pkgs; [
      kitty
      wofi
      dbus
      dbus-sway-environment
      configure-gtk
      wayland
      xdg-utils # for opening default programs when clicking links
      glib # gsettings
      dracula-theme # gtk theme
      gnome3.adwaita-icon-theme  # default gnome cursors
      swaylock
      swayidle
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      mako # notification system developed by swaywm maintainer
      wdisplays # tool to configure displays

    ];

  hardware = {
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };

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
        livingRoom = { model="DCP-1610W"; ip = "192.168.178.62"; };
      };
    };
  };

  #uncomment this line for protection on VPN
  # n.b. need ipv6 for CIDER jack in to work
  networking.enableIPv6=true;
  networking.hostName = "benixos"; # Define your hostname.
  # the /etc/hosts
  networking.extraHosts =
  ''
    #put your favourite hosts file stuff here
    192.168.178.57 rpi
  '';
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];
  networking.firewall.allowedTCPPortRanges = [
    { from = 8000; to = 8100; }
  ];


  # no atime because it's to prevent so many USB drive writes
  fileSystems."/".options = ["defaults" "noatime"];
  fileSystems."/home".options = ["defaults" "noatime"];

  time.timeZone = "Europe/Berlin";

  location = {
    #Berlin
    latitude = 52.31;
    longitude = 13.22;
  };

  # List services that you want to enable:
  services = {
    # pitch app requires this
    gnome.gnome-keyring.enable=true;

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

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals [ pkgs.xdg-desktop-portal-gtk ];
    };

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
      user = "ben";
      #group = "users";
      dataDir = "/home/ben/.syncthing";
    };

    blueman.enable = true;

    tlp.enable = true;
    thermald.enable = true;
    fstrim.enable = true;
  };
  powerManagement.enable = true;

  #systemd.user.services.pulseaudio.environment = {
  #  JACK_PROMISCUOUS_SERVER = "jackaudio";
  #};


  security.sudo.enable = true;
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];#"/etc/ssl/certs/prod01_intermediate_ca.pem" "/etc/ssl/certs/prod01_root_ca.pem"];

  programs.adb.enable = true;
  programs.autojump.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.mosh.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.ben = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/ben";
    shell = "${pkgs.zsh}/bin/zsh";
    description = "Ben Lovell";
    extraGroups = ["wheel" "video" "audio" "vboxusers" "tty" "docker" "scanner" "sync" "lp" "adbusers" "jackaudio"];
  };

  users.users.root.extraGroups = ["grsecurity" "audio" "syncthing"];

  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    GOROOT = "${pkgs.go.out}/share/go";
    GDK_SCALE="2";
    GDK_DPI_SCALE="0.5";
  };


  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;
  #virtualisation.anbox.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "21.11";
  nix = {
    package = pkgs.nixUnstable;
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
  nixpkgs.config.allowUnfree = true;
}
