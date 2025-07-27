{
  pkgs,
  config,
  lib,
  username,
  ...
}:
{
  options.graphicsStuff = {
    enable = lib.mkEnableOption "graphicsStuff";
    pkgs = lib.mkOption {
      type = lib.types.pkgs;
      default = pkgs;
    };
  };
  config = lib.mkIf config.graphicsStuff.enable {
    i18n.inputMethod.enable = true;
    i18n.inputMethod.type = "ibus";
    security.polkit.enable = true;

    environment.systemPackages = with config.graphicsStuff.pkgs; [
      morewaita-icon-theme
      adwaita-icon-theme
      qogir-icon-theme
      papirus-icon-theme

      baobab

      gnome-boxes

      wl-gammactl
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      wl-clipboard-x11 # legacy support for tools expecting x11
      wl-clip-persist # wayland only keeps things in clipboard while the app that put it there is open

      swaylock

      grim # wayshot
      slurp

      pavucontrol
      brightnessctl
      playerctl

      swww
      swaybg

      kitty

      darktile
      wdisplays # tool to configure displays
      amdgpu_top
      libva-utils # to analyse with vainfo
      opencl-headers
      qt6.qtwayland
      qt5.qtwayland
      cliphist # clipboard history manager

      # I don't know if I should have these twice since they're already in
      # the mesa extra packages, but I can't e.g. access clinfo there
      rocmPackages.clr
      rocmPackages.clr.icd
      rocmPackages.rocminfo
      rocmPackages.rocm-runtime
    ];

    services = {
      # I have no idea if, or why this should be necessary, but I
      # saw someone else do this for wayland so let's give it a shot
      xserver.videoDrivers = [ "amdgpu" ];

      xremap = {
        withWlroots = true;
        userName = username;
        serviceMode = "user";
        watch = true;
        config = {
          modmap = [
            {
              name = "Global";
              remap = {
                "Capslock" = {
                  "held" = "Control_R";
                  "alone" = "Esc";
                  #"skip_key_event" = true;
                };
                "Esc" = {
                  # don't be fooled, this actually assigns it to the menu key...
                  # reassigning _that_ using xkboptions to compose:menu should
                  # actually give you the compose key
                  "alone" = "Compose";
                  "held" = "RightAlt";
                  #"skip_key_event" = true;
                };
              };
            }
            {
              name = "lisp-shiftkeys";
              application.not = "blender";

              remap = {
                "LeftShift" = {
                  "held" = "LeftShift";
                  "alone" = "KPLeftParen";
                };
                "RightShift" = {
                  "held" = "RightShift";
                  "alone" = "KPRightParen";
                };
              };
            }
            {
              name = "apple-keyboard";
              device.only = "Apple Inc. Magic Keyboard";
              remap = {
                #"LeftMeta" = "LeftAlt";
                #"LeftAlt" = "LeftMeta";
                #"RightAlt" = "RightMeta";
                #"RightMeta" = "RightAlt";
              };
            }
            {
              name = "xps-keyboard";
              device.only = "AT Translated Set 2 keyboard";
              remap = {
                "LeftMeta" = "LeftAlt";
                "LeftAlt" = "LeftMeta";
                "RightAlt" = "RightMeta";
              };
            }
          ];
          keymap = [
            {
              name = "Global";
              remap = {
                #"RightAlt-Enter" = "Super-Enter";
              };
            }
            {
              name = "Emacsy";
              remap = {
                "Super-a" = "C-a";
                "Super-z" = "C-z";
                "Super-x" = "C-x";
                "Super-c" = "C-c";
                "Super-Shift-c" = "Super-Shift-c";
                "Super-v" = "C-v";
                "Super-w" = "C-w";
                "Super-r" = "C-r";
                "Super-h" = "C-h";
                "Super-j" = "C-j";
                "Super-k" = "C-k";
                "Super-l" = "C-l";
                # very annoyingly have to always override the combos
                # if you just override one value
                "Super-Ctrl-h" = "Super-Ctrl-h";
                "Super-Ctrl-j" = "Super-Ctrl-j";
                "Super-Ctrl-k" = "Super-Ctrl-k";
                "Super-Ctrl-l" = "Super-Ctrl-l";
                "Super-Shift-h" = "Super-Shift-h";
                "Super-Shift-j" = "Super-Shift-j";
                "Super-Shift-k" = "Super-Shift-k";
                "Super-Shift-l" = "Super-Shift-l";
                "Super-LeftAlt-h" = "Super-LeftAlt-h";
                "Super-LeftAlt-j" = "Super-LeftAlt-j";
                "Super-LeftAlt-k" = "Super-LeftAlt-k";
                "Super-LeftAlt-l" = "Super-LeftAlt-l";
                "Super-LeftBrace" = "C-LeftBrace";
                "Super-RightBrace" = "C-RightBrace";
                "Super-Equal" = "C-Equal";
                "Super-Minus" = "C-Minus";
                "Super-t" = "C-t";
                "C-a" = "home";
                "C-e" = "end";
                "C-w" = [
                  "C-Shift-left"
                  "delete"
                ];
              };
              application.not = [
                "kitty"
                "qemu"
                "quickemu"
                "virt-manager"
                "qemu_x86_64"
                ".qemu-system-x86_64-wrapped"
              ];
            }
          ];
        };
      };
    };

    fonts = {
      fontDir.enable = true;
      enableGhostscriptFonts = true;
      packages = with config.graphicsStuff.pkgs; [
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
        fira
        fira-code
        fira-math
        font-awesome
        gentium
        google-fonts
        gyre-fonts
        hack-font
        hasklig
        helvetica-neue-lt-std
        inconsolata
        inter
        iosevka
        ipaexfont
        jetbrains-mono
        joypixels
        kochi-substitute
        liberation_ttf
        libertine
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        powerline-fonts
        roboto-mono
        source-code-pro
        source-sans-pro
        symbola
        terminus_font
        ubuntu_font_family

        nerd-fonts.caskaydia-cove
        nerd-fonts.fira-code
        nerd-fonts.recursive-mono
        nerd-fonts.roboto-mono
        nerd-fonts.zed-mono
      ];

      fontconfig.defaultFonts.emoji = [
        "JoyPixels"
        "Noto Color Emoji"
      ];
      fontconfig.hinting.enable = true;
      fontconfig.hinting.style = "full";
      fontconfig.subpixel.rgba = "rgb";
    };

    # if using alternative pkgs, needs to be done elsewhere as
    # it's referring to different nixpkgs
    # e.g. with hyprland-pkgs, doing it in the overlay defined
    # in the flake
    nixpkgs.config.joypixels.acceptLicense = true;
    nixpkgs.config.allowUnfree = true;

    hardware.graphics = {
      package = config.graphicsStuff.pkgs.mesa;
      package32 = config.graphicsStuff.pkgs.pkgsi686Linux.mesa;
      extraPackages = with config.graphicsStuff.pkgs; [
        rocmPackages.clr
        rocmPackages.clr.icd
        rocmPackages.rocminfo
        rocmPackages.rocm-runtime
        vaapiVdpau
        libvdpau-va-gl
        #amdvlk
      ];
    };

    # trying to force radeon, and things to use wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    environment.sessionVariables.VDPAU_DRIVER = "radeonsi";
    environment.sessionVariables.LIBVA_DRIVER_NAME = "radeonsi";
    environment.sessionVariables.ROC_ENABLE_PRE_VEGA = "1";
    environment.sessionVariables.MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
    environment.sessionVariables.SDL_VIDEODRIVER = "wayland";
    environment.sessionVariables.CLUTTER_BACKEND = "wayland";
    environment.sessionVariables.GDK_BACKEND = "wayland,x11,*";
    environment.sessionVariables.QT_QPA_PLATFORM = "wayland;xcb";

    # hidpi forcing/detection
    environment.variables.QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    environment.variables.QT_ENABLE_HIGHDPI_SCALING = "1";
    environment.sessionVariables.QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
    environment.sessionVariables.AQ_DRM_DEVICES = "/dev/dri/card1";
  };
}
