{ config, pkgs, ... }:

# Enable the X11 windowing system.
{

  hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];
  services.xserver = {
    enable = true;

    layout = "gb";
    xkbVariant = "mac";
    xkbOptions = "caps:swapescape, numpad:mac";
    #videoDrivers = [ "intel" "nouveau" "vesa" ];

    multitouch.enable = true;
    synaptics = {
      enable = true;
      dev = "/dev/input/event*";
      twoFingerScroll = true;
      accelFactor = "0.001";
      buttonsMap = [ 1 3 2 ];
    };

    config = ''
    Section "Device"
      Identifier "Intel Graphics"
      Driver "intel"
      Option "TearFree" "true"
    EndSection
    '';

    desktopManager.default = "none";
    desktopManager.xterm.enable = false;
    
    windowManager.default = "xmonad";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;

    displayManager = {
      slim = {
        enable = true;
        defaultUser = "ben";
        # needs to be to tar.gz, not pkg
        #theme = pkgs.slimThemes.archlinuxSimple;
      };
      sessionCommands = ''
        ${pkgs.xlibs.xrdb}/bin/xrdb -merge ~/.Xresources
        ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr #sets cursor
        /bin/sh /home/ben/.screenlayout/wallpaper.sh
        #${pkgs.dropbox}/bin/dropbox &
        ${pkgs.xcape}/bin/xcape -e "Shift_L=parenleft;Shift_R=parenright"

        ${pkgs.xlibs.xmodmap}/bin/xmodmap -e 'keycode   9 = Multi_key'
        ${pkgs.xlibs.xmodmap}/bin/xmodmap -e 'clear Lock'

        ${pkgs.xlibs.xmodmap}/bin/xmodmap -e 'keycode 108 = Alt_R Meta_R Alt_R Meta_R'
        ${pkgs.xlibs.xmodmap}/bin/xmodmap -e 'keycode 12 = 3 numbersign 3 numbersign sterling numbersign sterling numbersign'
        ${pkgs.xlibs.xmodmap}/bin/xmodmap -e 'keycode  49 = grave asciitilde grave asciitilde bar brokenbar bar'

        '';
    };
  };

  fonts = {
    enableFontDir = true;
    enableCoreFonts = true;
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
      fantasque-sans-mono
      fira-code
      fira
      gentium
      gyre-fonts
      hack-font
      hasklig
      iosevka
      inconsolata
    #  ipafont
      liberation_ttf
      libertine
      powerline-fonts
      terminus_font
      noto-fonts
      source-code-pro
      vistafonts
      ubuntu_font_family
    ];
    fontconfig.ultimate.enable = true;
    fontconfig.ultimate.preset = "osx";
  };

  environment.shellInit = ''
    #to find GTK themes
    export GTK_DATA_PREFIX=${config.system.path}
    export GTK_PATH=$GTK_PATH:${pkgs.gtk-engine-murrine}/lib/gtk-2.0:${pkgs.pkgsi686Linux.gtk-engine-murrine}/lib/gtk-2.0
    '';

  environment.pathsToLink = [ "/share/themes" "/share/mime" "/lib/gtk-2.0"];

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip pkgs.gutenprint ];
  };
}
