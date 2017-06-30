{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
   environment.systemPackages = with pkgs; [
     # X/GUI stuff
     #haskellPackages.xmonadContrib
     #haskellPackages.xmonadExtras
     xorg.xmodmap
     #xmonad-with-packages
     arandr
     autorandr
     conky
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
     pommed-light
     powertop
     smartmontools
  #   udev #breaks config with list->string type errors now?
     udisks2
     usbutils
     #pommed-light

     # cli utils
     aspell
     aspellDicts.en
     awscli
     bc
     binutils
     #chrpath
     cowsay
     encfs
     feh
     ffmpeg-full
     graphicsmagick
     gst_all_1.gst-libav
     htop
     iotop
     keychain
     lsof
     manpages
     openvpn
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
     luakit
     tdesktop

     # gui utils
     baobab
     calibre
     #dropbox
     evince
     evtest
     gimp
     gparted
     gpicview
     gnome3.cheese
     gnome3.gnome-font-viewer
     hipchat
     keepass
     pinta
     qbittorrent
     qjackctl
     shotwell
     skype
     spotify
     vlc
     wpa_supplicant_gui
     xdotool
     xfce.thunar
     xfce.terminal

     # dev
     ansible
     ansible2
     boot
     chromedriver
     cmake
     compass
     docker-edge
     docker_compose
     docker-gc
     dust #from pixie
     emacs
     gcc
     ghc
     git
     gitAndTools.gitflow
     gnumake
     jdk
     jekyll
     leiningen
     mariadb
     neovim
     nodejs
     nodePackages.npm2nix
     pixie
     python
     python27Packages.boto
     python27Packages.virtualenv
     python27Packages.virtualenvwrapper
     #pypyPackages.ipython
     R
     ruby
     sqlite
     vagrant
     vimHugeX

     # misc
     mplayer
     flashplayer
     gstreamer
     hal-flash #DRM for flashplayer
     #wineUnstable
     #winetricks
     #pypyPackages.wxPython30

     #games
     #openlierox
     #xonotic

     # unsorted
     # mysql-workbench
   ];

   nixpkgs.config = {
     allowUnfree = true;
     firefox = {
       enableGoogleTalkPlugin = true;
       enableAdobeFlash = true;
     };
     chromium = {
       enablePepperFlash = true;
       enablePepperPDF = true;
       enableWideVine = true;
     };
     packageOverrides = pkgs: import ./mypackages {
       inherit pkgs;
       # don't know if i can do this actually
       #bluez = pkgs.bluez5;
     };
   };
}
