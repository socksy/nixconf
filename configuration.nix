# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages.nix
      ./xps13.nix
      ./xstuff.nix
#      ./stable-packages.nix
    ];


  hardware = {
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };
    # i wonder if i'll regret this
    pulseaudio = {
      enable = true;
    #  systemWide = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
    };
    bluetooth = {
      enable = true;
    #  extraConfig = ''
    #    [general]
    #    Enable=Source,Sink,Media,Socket
    #  '';
    };

    # enable scanning firmware
    sane.enable = true;
  };

  networking.hostName = "benixos"; # Define your hostname.
  networking.extraHosts =
  ''
  10.1.76.140 git.ge
  '';
  #networking.enableB43Firmware = true;
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.


  # no atime because it's to prevent so many USB drive writes
  fileSystems."/".options = ["defaults" "noatime"];
  fileSystems."/home".options = ["defaults" "noatime"];

  time.timeZone = "Europe/Berlin";


  # List services that you want to enable:
  services = {
    illum.enable = true;
    #nylas-mail.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # run updatedb every night so locate works
    locate.enable = true;

    dbus.packages = [ pkgs.gnome2.GConf.out ];

    # puts browser profiles into RAM, preventing a lot of read/write to USB
    psd.enable = true;
    psd.users = ["ben"];

    acpid.enable = true;
    #udev.extraRules = ''
    #  KERNEL=="card0", SUBSYSTEM=="drm", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/ben/.Xauthority", RUN+="${pkgs.stdenv.shell} -c '/home/ben/.screenlayout/auto.sh'"
    #  ''
    #  ;

    redshift = {
      enable = true;

      #Berlin
      latitude = "52.31";
      longitude = "13.22";
      temperature.day = 6500;
      #temperature.day = 2500;
    };

    avahi.enable = true;
    avahi.ipv6 = true;
    #enable if you want local networking printing. Disable if you want work VPN to work. :\
    #avahi.nssmdns = true;
    avahi.nssmdns = false;

    syncthing = {
      enable = true;
      openDefaultPorts = true;
      useInotify = true;
      user = "ben";
      #group = "users";
      dataDir = "/home/ben/.syncthing";
    };
  };




  security.sudo.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.ben = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/ben";
    shell = "${pkgs.zsh}/bin/zsh";
    description = "Ben Lovell";
    extraGroups = ["wheel" "video" "audio" "vboxusers" "tty" "docker" "scanner" "sync" "lp"];
  };

  users.users.root.extraGroups = ["grsecurity" "audio" "syncthing"];

  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    GOROOT = "${pkgs.go.out}/share/go";
  };


  #virtualisation.virtualbox.guest.enable = true;
  #virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.09";
}
