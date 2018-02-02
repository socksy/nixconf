{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # X/GUI stuff
    xorg.xmodmap
    arandr
    autorandr
    conky
    compton
    dmenu
    dzen2
    evtest
    gnome2.gnome_icon_theme
    # 16.09
    #gnome.gnomeicontheme
    gnome2.gtk
    gnome3.gtk
    haskellPackages.xmonad
    haskellPackages.yeganesh
    libnotify
    lxappearance
    numix-gtk-theme
    numix-icon-theme-circle
    xcape
    xclip
    xcompmgr
    xfce.xfce4notifyd
    xfontsel
    xlsfonts
    xorg.xbacklight
    xorg.xbitmaps
    xorg.xev
    xorg.xineramaproto

    #printing
    gutenprint
    hplip

    # core system stuffs
    acpi
    dmidecode
    exfat
    fftw
    glxinfo
    gnupg1
    hdparm
    intel-gpu-tools
    jack2Full
    pciutils
    powertop
    smartmontools
    tarsnap
    #udev #breaks config with list->string type errors now?
    udisks2
    usbutils

    # cli utils
    aspell
    aspellDicts.en
    awscli
    bc
    binutils
    bluez
    #chrpath
    cowsay
    encfs
    feh
    ffmpeg-full
    graphicsmagick
    gst_all_1.gst-libav
    htop
    httpie
    iotop
    keychain
    lsof
    manpages
    openvpn
    pavucontrol
    python27Packages.pkgconfig
    psmisc
    rlwrap
    scrot
    shared_mime_info
    silver-searcher
    sshfsFuse
    telnet
    tmux
    tree
    unzip
    wget
    which
    whois
    zip
    zsh

    # web
    chromium
    #dwb
    firefox-wrapper
    google-chrome
    tdesktop

    # gui utils
    baobab
    #calibre
    #dropbox
    evince
    evtest
    gimp
    gparted
    gpicview
    gnome3.cheese
    gnome3.gnome-font-viewer
    keepass
    pinta
    qbittorrent
    qjackctl
    shotwell
    skype
    slack
    spotify
    vlc
    wpa_supplicant_gui
    xdotool
    xfce.thunar
    xfce.terminal

    # dev
    boot
    cargo
    cmake
    compass
    ctop
    docker-edge
    docker_compose
    docker-gc
    dust #from pixie
    emacs
    gcc
    #ghc
    git
    gitAndTools.gitflow
    gnumake
    jdk
    jekyll
    leiningen
    #lumo
    mariadb
    neovim
    nodejs
    pixie
    python
    python27Packages.boto
    R
    ruby
    rustc
    sqlite
    vagrant
    vimHugeX

    # misc
    mplayer
    #flashplayer
    gstreamer
    hal-flash #DRM for flashplayer
    #wineUnstable
    #winetricks
    #pypyPackages.wxPython30

    #games
    #openlierox
    #xonotic
    steam
  ];

  nixpkgs.config = {
    allowUnfree = true;
    firefox = {
      enableGoogleTalkPlugin = true;
      #enableAdobeFlash = true;
    };
    chromium = {
      #enablePepperFlash = true;
      enablePepperPDF = true;
      #       enableWideVine = true;
    };
    packageOverrides = pkgs: import ./mypackages {
      inherit pkgs;
      # don't know if i can do this actually
      #bluez = pkgs.bluez5;
    };
  };
}
