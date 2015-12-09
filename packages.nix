{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
   environment.systemPackages = with pkgs; [
     # X/GUI stuff
     #haskellPackages.xmonadContrib
     #haskellPackages.xmonadExtras
     #xmodmap
     #xmonad-with-packages
     arandr
     conky
     dmenu
     dzen2
     gnome.gnomeicontheme
     gtk
     haskellPackages.xmonad
     haskellPackages.yeganesh
     lxappearance
     numix-gtk-theme
     xcape
     xcompmgr
     xfontsel
     xlsfonts

     #printing
     gutenprint
     hplip

     # core system stuffs
     acpi
     dmidecode
     exfat
     pciutils
     usbutils
     #pommed-light

     # cli utils
     awscli
     bc
     binutils
     encfs
     feh
     htop
     manpages
     psmisc
     scrot
     shared_mime_info
     silver-searcher
     sshfsFuse
     sudo
     tree
     wget
     zsh

     # web
     chromium
     firefox-wrapper
     luakit

     # gui utils
     dropbox
     evince
     gimp
     hipchat
     keepass
     pinta
     vlc
     wpa_supplicant_gui
     xfce.thunar
     xfce.terminal

     # dev
     ansible
     boot
     emacs
     gcc
     ghc
     git
     gnumake
     leiningen
     python
     ruby
     vagrant
     vimHugeX

     # misc
     mplayer
     gstreamer

     #games
     openlierox
     xonotic
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
     packageOverrides = pkgs: {
       bluez = pkgs.bluez5;
     };
   };
}
