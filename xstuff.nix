{ config, pkgs, ... }:

# Enable the X11 windowing system.
{

  hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];
  services.xserver = {
    enable = true;
    exportConfiguration = true; #for sanity debugging reasons

    layout = "gb";
    xkbVariant = "mac";
    xkbOptions = "caps:swapescape, numpad:mac";
    videoDrivers = ["modesetting"];# "vesa" "intel" "nouveau"];

    #multitouch.enable = true;
    dpi = 330;
    libinput = {
      #https://github.com/NixOS/nixpkgs/blob/release-16.09/nixos/modules/services/x11/hardware/libinput.nix
      enable = true;
      #buttonMapping = "1 3 2";
      tapping = true;
      clickMethod = "clickfinger";
      accelProfile = "flat";
      accelSpeed = "0.5";
    };
    #synaptics = {
    #  enable = true;
    #  dev = "/dev/input/event15";
    #  twoFingerScroll = true;
    #  #accelFactor = "0.001";
    #  buttonsMap = [ 1 3 2 ];
    #};

    config = ''
    Section "Device"
      Identifier "Intel Graphics"
      Driver "intel"
      Option "TearFree" "true"
      #Option "NoAccel" "true"
      Option "backlight" "intel_backlight"
    EndSection
    '';

    displayManager = {
      #lightdm.enable = true;
      #lightdm.greeters.gtk.extraConfig = "xft-dpi=221";
      sddm = {
        enable = true;
        enableHidpi = true;
      };
      defaultSession = "xfce+xmonad";
    };
    desktopManager = {
      #default = "xfce";
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager = {
      #default = "xmonad";
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages : [
          haskellPackages.xmonad-contrib
          haskellPackages.xmonad-extras
          haskellPackages.xmonad
        ];
      };
    };

    displayManager = {
      sessionCommands = ''
        PATH=$HOME/ben/bin:$PATH
        ${pkgs.xlibs.xrdb}/bin/xrdb -merge ~/.Xresources
        #${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr #sets cursor
        #/bin/sh /home/ben/.screenlayout/wallpaper.sh
        ${pkgs.xcape}/bin/xcape -e "Shift_L=parenleft;Shift_R=parenright"


        # doing initial xmodmap key swaps
        ${pkgs.xlibs.xmodmap}/xmodmap -e 'remove mod1 = Alt_L'
        ${pkgs.xlibs.xmodmap}/xmodmap -e 'remove mod4 = Super_L'


        # alt + super swapped
        ${pkgs.xlibs.xmodmap}/modmap -e 'keycode 133 = Alt_L Meta_L Alt_L Meta_L'
        ${pkgs.xlibs.xmodmap}/modmap -e 'keycode 64 = Super_L'
        ${pkgs.xlibs.xmodmap}/modmap -e 'keycode 108 = Super_L'

        ${pkgs.xlibs.xmodmap}/xmodmap -e 'add mod1 = Alt_L'
        ${pkgs.xlibs.xmodmap}/xmodmap -e 'add mod4 = Super_L'

        # old escape key now compose key
        ${pkgs.xlibs.xmodmap}/bin/xmodmap -e 'keycode   9 = Multi_key'
        ${pkgs.xlibs.xmodmap}/bin/xmodmap -e 'clear Lock'

        # US style
        ${pkgs.xlibs.xmodmap}/bin/xmodmap -e 'keycode 12 = 3 numbersign 3 numbersign sterling numbersign sterling numbersign'
        ${pkgs.xlibs.xmodmap}/bin/xmodmap -e 'keycode  49 = grave asciitilde grave asciitilde bar brokenbar bar'
      '';
    };
  };

  i18n.inputMethod = {
    enabled = "ibus";
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      anonymousPro
      aurulent-sans
      bakoma_ttf
      caladea
      cantarell_fonts
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
      font-awesome-ttf
      gentium
      gyre-fonts
      hack-font
      hasklig
      helvetica-neue-lt-std
      iosevka
      inconsolata
    #  ipafont
      liberation_ttf
      libertine
      powerline-fonts
      terminus_font
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk
      source-code-pro
      source-sans-pro
      #vistafonts
      ubuntu_font_family
      twemoji-color-font
    ];
    # removed from nixos and freetype in general... in cleartype we trust. Pity I hate MS' rendering
    # https://github.com/NixOS/nixpkgs/commit/65592837b6e62fb555d6e8c891f347428886c4f2
    #fontconfig.ultimate.enable = true;
    #fontconfig.ultimate.preset = "osx";
  };

  environment.shellInit = ''
    #to find GTK themes
    export GTK_DATA_PREFIX=${config.system.path}
    export GTK_PATH=$GTK_PATH:${pkgs.gtk-engine-murrine}/lib/gtk-2.0:${pkgs.pkgsi686Linux.gtk-engine-murrine}/lib/gtk-2.0
    export QT_IM_MODULE="xim"
    #export GTK_IM_MODULE="xim"
    '';

  environment.pathsToLink = [ "/share" "/share/icons" "/share/themes" "/share/mime" "/lib/gtk-2.0" "/etc/gconf" "/lib/gtk-3.0"];

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip pkgs.gutenprint pkgs.epson-escpr ];
  };
}
