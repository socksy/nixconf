{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # X/GUI stuff
    xorg.xmodmap
    arandr
    autorandr
    blueman
    conky
    compton
    dmenu
    dzen2
    evtest
    gnome2.gnome_icon_theme
    # 16.09
    #gnome.gnomeicontheme
    gnome2.gtk
    gnome3.adwaita-icon-theme
    gnome3.gtk
    gnome3.simple-scan
    haskellPackages.xmonad
    haskellPackages.yeganesh
    libnotify
    lxappearance
    numix-gtk-theme
    numix-icon-theme-circle
    xbrightness
    xcalib
    xcape
    xclip
    xcompmgr
    xfce.xfce4notifyd
    xfontsel
    xlsfonts
    xorg.xbacklight
    xorg.xbitmaps
    xorg.xcursorthemes
    xorg.xev
    #xorg.xineramaproto

    #printing
    gutenprint
    #TODO fix hplip
    #hplip

    # core system stuffs
    acpi
    dmidecode
    exfat
    fftw
    glxinfo
    gnupg1
    hdparm
    hello
    intel-gpu-tools
    jmtpfs # for mtp access with phones
    lshw
    nfs-utils
    p7zip
    pciutils
    powertop
    rfkill
    smartmontools
    tarsnap
    #udev #breaks config with list->string type errors now?
    udisks2
    usbutils

    # cli utils
    asciinema
    aspell
    aspellDicts.en
    awscli
    bc
    binutils
    byzanz
    #chrpath
    cowsay
    direnv
    encfs
    elinks
    feh
    ffmpeg-full
    fzf
    graphicsmagick
    ghostscript
    gst_all_1.gst-libav
    htop
    httpie
    iotop
    keybase
    keychain
    lsof
    magic-wormhole
    manpages
    mosh
    #ngrok
    nmap
    openssl
    openvpn
    pandoc
    pavucontrol
    python27Packages.pkgconfig
    psmisc
    pv
    ripgrep
    rlwrap
    scrot
    shared_mime_info
    silver-searcher
    sshfsFuse
    telnet
    tldr
    tmux
    tree
    unzip
    wavemon
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

    # gui utils
    anki
    baobab
    #calibre
    #dropbox
    evince
    evtest
    dpkg
    gimp
    gparted
    gpicview
    gnome3.cheese
    gnome3.gnome-font-viewer
    inkscape
    keepassxc
    libreoffice
    pinta
    #qbittorrent
    qjackctl
    signal-desktop
    shotwell
    #skype
    slack
    spotify
    #temporarily disabled while the build is broken, shadowing with stable.tdesktop
    #tdesktop
    vlc
    wpa_supplicant_gui
    xdotool
    xfce.thunar
    xfce.terminal
    xournal
    xsane
    zoom-us

    # dev
    atom
    aws
    boot
    cargo
    clojure
    cmake
    compass
    ctop
    docker-edge
    docker_compose
    docker-gc
    dust #from pixie
    emacs
    elixir
    gcc
    #ghc
    git
    gitAndTools.gitflow
    go
    gocode
    gnumake
    j
    jdk
    jekyll
    leiningen
    #lumo
    lua
    #neovim
    nodejs-12_x
    patchelf
    pixie
    protobuf
    python
    python3
    python27Packages.boto
    python36Packages.pip
    python36Packages.pip
    python36Packages.virtualenv
    python36Packages.virtualenvwrapper
    R
    racket
    ruby
    rustc
    sqlite
    vimHugeX

    # misc
    mplayer
    # lol flashplayer is broken and no-one noticed
    #flashplayer
    gstreamer
    #hal-flash #DRM for flashplayer
    #wineUnstable
    #winetricks
    #pypyPackages.wxPython30

    #games
    #openlierox
    #xonotic
    #steam
  ];

  nixpkgs.config = {
    allowUnfree = true;
    firefox = {
      #enableGoogleTalkPlugin = true;
      #enableAdobeFlash = true;
    };
    emacs = {
      withXwidgets = true;
    };
    chromium = {
      #enablePepperFlash = true;
      #enablePepperPDF = true;
      #       enableWideVine = true;
    };
    packageOverrides = pkgs: import ./mypackages {
      inherit pkgs;
    };
  };
}
