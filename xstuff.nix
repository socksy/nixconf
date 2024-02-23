{ config, pkgs, ... }:

# Enable the X11 windowing system.
{

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl intel-media-driver ];
  services.xserver = {
    enable = true;
    exportConfiguration = true; #for sanity debugging reasons

    layout = "gb";
    xkbVariant = "mac";
    xkbOptions = "caps:swapescape;numpad:mac;ctrl:nocaps";
    videoDrivers = ["modesetting"];# "vesa" "intel" "nouveau"];

    #multitouch.enable = true;
    dpi = 330;
    libinput = {
      #https://github.com/NixOS/nixpkgs/blob/release-16.09/nixos/modules/services/x11/hardware/libinput.nix
      enable = true;
      #buttonMapping = "1 3 2";
      touchpad = {
        tapping = true;
        clickMethod = "clickfinger";
        calibrationMatrix = "8 0 0 0 8 0 0 0 1";
        accelSpeed = "0.5";
        accelProfile = "flat";
      };
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
      #sddm = {
      #  enable = true;
      #  enableHidpi = true;
      #};
      gdm.enable = true;
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
        ${pkgs.xorg.xrdb}/bin/xrdb -merge ~/.Xresources
        #${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr #sets cursor
        #/bin/sh /home/ben/.screenlayout/wallpaper.sh
        ${pkgs.xcape}/bin/xcape -e "Shift_L=parenleft;Shift_R=parenright;Control_L=Escape"


        # doing initial xmodmap key swaps
        ${pkgs.xorg.xmodmap}/xmodmap -e 'remove mod1 = Alt_L'
        ${pkgs.xorg.xmodmap}/xmodmap -e 'remove mod4 = Super_L'


        # alt + super swapped
        ${pkgs.xorg.xmodmap}/modmap -e 'keycode 133 = Alt_L Meta_L Alt_L Meta_L'
        ${pkgs.xorg.xmodmap}/modmap -e 'keycode 64 = Super_L'
        ${pkgs.xorg.xmodmap}/modmap -e 'keycode 108 = Super_L'

        ${pkgs.xorg.xmodmap}/xmodmap -e 'add mod1 = Alt_L'
        ${pkgs.xorg.xmodmap}/xmodmap -e 'add mod4 = Super_L'

        # N.B. the escape key is already swapped with the caps_lock due to
        #xkb option caps:swapescape
        # old escape key now compose key
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e 'keycode   9 = Multi_key'
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e 'clear Lock'

        # US style
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e 'keycode 12 = 3 numbersign 3 numbersign sterling numbersign sterling numbersign'
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e 'keycode  49 = grave asciitilde grave asciitilde bar brokenbar bar'
      '';
    };
  };

  i18n.inputMethod = {
    enabled = "ibus";
  };

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
      source-code-pro
      source-sans-pro
      symbola
      #vistafonts
      ubuntu_font_family
      twemoji-color-font
    ];
    fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" ];
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
