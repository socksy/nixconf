{ config, pkgs, emacs, ... }:

{
  # TODO radically reduce this and make different nix profiles for different things
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # X/GUI stuff
    xorg.xmodmap
    arandr
    #audacity
    autorandr
    blueman
    cachix
    conky
    compton
    dmenu
    dzen2
    evtest
    gnome2.gnome_icon_theme
    # 16.09
    #gnome.gnomeicontheme
    gtk2
    gnome.adwaita-icon-theme
    gtk3
    simple-scan
    #haskellPackages.xmonad
    haskellPackages.yeganesh
    libnotify
    lxappearance
    numix-gtk-theme
    numix-icon-theme-circle
    #ocenaudio #audacity alternative
    pulseaudio # for pactl backwards compatibility until i port scripts
    rofi #better dmenu
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
    #p7zip
    pciutils
    powertop
    smartmontools
    tarsnap
    #udev #breaks config with list->string type errors now?
    udisks2
    usbutils

    # cli utils
    asciinema
    aspell
    aspellDicts.en
    awscli2
    bc
    binutils
    byzanz
    #chrpath
    cowsay
    direnv #better dmenu
    encfs
    elinks
    feh
    #ffmpeg-full
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
    mpv
    #ngrok
    nmap
    openssl
    openvpn
    pandoc
    pavucontrol
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
    midori
    #luakit

    # gui utils
    alacritty
    anki
    baobab
    blender
    #calibre
    #dropbox
    evince
    evtest
    #discord
    dpkg
    gimp
    gparted
    gpicview
    gnome.cheese
    gnome.gnome-font-viewer
    helm
    inkscape
    #kdenlive
    keepassxc
    libreoffice
    peek # gif screengrabs
    pinta
    #qbittorrent
    qjackctl
    signal-desktop
    shotwell
    #skype
    slack
    spotify
    vlc
    wire-desktop
    wpa_supplicant_gui
    xdotool
    xfce.thunar
    xfce.terminal
    gnome.nautilus
    gnome.sushi
    xournal
    xsane
    #zoom-us

    # dev
    androidenv.androidPkgs_9_0.platform-tools
    aws
    cargo
    #clj-kondo
    clojure
    clojure-lsp
    cmake
    compass
    ctop
    docker-edge
    docker_compose
    docker-gc
    #emacs
    emacsGit
    elixir
    gcc
    #ghc
    git
    gitAndTools.gitflow
    gitAndTools.delta
    go
    gocode
    gnumake
    # not cached rn so commenting out so as not to build from scratch
    #graalvm8
    #j
    jdk
    jekyll
    leiningen
    #lumo
    lua
    neovim
    nodejs-12_x
    patchelf
    protobuf
    python3
    python38Packages.pip
    python38Packages.virtualenv
    python38Packages.virtualenvwrapper
    R
    racket
    ruby
    rustc
    sqlite
    vimHugeX
    zeal

    # misc
    mplayer
    pulseaudio-ctl
    # lol flashplayer is broken and no-one noticed
    #flashplayer
    #gstreamer
    #hal-flash #DRM for flashplayer
    #wineUnstable
    #winetricks
    #pypyPackages.wxPython30

    #games
    scummvm
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
    chromium = {
      #enablePepperFlash = true;
      #enablePepperPDF = true;
      #       enableWideVine = true;
    };
    packageOverrides = pkgs: import ./mypackages {
      inherit pkgs;
    };
  };
  nixpkgs.overlays = [ emacs.overlay ];
  #nixpkgs.overlays = [
  #  (import (builtins.fetchTarball {
  #    #url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
  #    url = https://github.com/nix-community/emacs-overlay/archive/fe1b51ee407a6c61162477ecac84c061bc15a600.tar.gz;
  #    #url = https://github.com/nix-community/emacs-overlay/archive/fa641d34da805361a033c4682ce116f0965533f4.tar.gz;
  #  }))
  #];
}
