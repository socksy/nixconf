# hyprland with gnome things enabled to make more DE like
{
  pkgs,
  inputs,
  config,
  username,
  lib,
  ...
}:
let
  hyprland-package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  hyprland-portals-package = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  hyprland-nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.system};
in
{
  options.hyprland = {
    enable = lib.mkEnableOption "Hyprland";
  };

  config = lib.mkIf config.hyprland.enable {
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    programs.hyprland = {
      enable = true;
      package = hyprland-package;
      portalPackage = hyprland-portals-package;
      xwayland.enable = true;
    };
    programs.waybar.enable = true;
    programs.xwayland.package = hyprland-nixpkgs.xwayland;

    #xdg.portal = {
    #  enable = true;
    #  extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    #  wlr.enable = true;
    #  config.common.default = "*";
    #};
    i18n.inputMethod.enable = true;
    i18n.inputMethod.type = "ibus";

    security = {
      polkit.enable = true;
      #pam.services.ags = {};
      pam.services.swaylock = { };
    };

    environment.systemPackages = with pkgs; [
      morewaita-icon-theme
      adwaita-icon-theme
      qogir-icon-theme
      papirus-icon-theme
      loupe
      nautilus
      baobab
      gnome-text-editor
      gnome-calendar
      gnome-boxes
      gnome-system-monitor
      gnome-control-center
      gnome-weather
      gnome-calculator
      gnome-clocks
      gnome-software # for flatpak
      gnome-control-center
      wl-gammactl
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      wl-clipboard-x11 # legacy support for tools expecting x11
      wl-clip-persist # wayland only keeps things in clipboard while the app that put it there is open
      xdg-utils
      swaylock
      swayidle

      grim # wayshot
      slurp

      pavucontrol
      brightnessctl
      playerctl
      # TODO: switch from wallutils to sww
      swww
      wallutils
      swaybg

      rofi-wayland

      # so that it keeps in sync with hyprland's
      hyprland-nixpkgs.kitty
      #hyprland-nixpkgs.wezterm
      hyprland-nixpkgs.darktile
      xdg-utils
      hyprland-nixpkgs.wdisplays # tool to configure displays
      hyprland-nixpkgs.amdgpu_top
      hyprland-nixpkgs.libva-utils # to analyse with vainfo
      hyprland-nixpkgs.opencl-headers
      hyprland-nixpkgs.qt6.qtwayland
      hyprland-nixpkgs.qt5.qtwayland
      cliphist # clipboard history manager

      # I don't know if I should have these twice since they're already in
      # the mesa extra packages, but I can't e.g. access clinfo there
      hyprland-nixpkgs.rocmPackages.clr
      hyprland-nixpkgs.rocmPackages.clr.icd
      hyprland-nixpkgs.rocmPackages.rocminfo
      hyprland-nixpkgs.rocmPackages.rocm-runtime

      mako # notification system developed by swaywm maintainer
      polkit_gnome
    ];
    # to match opengl versions
    programs.firefox.package = hyprland-nixpkgs.firefox;

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
      #user.services.kanshi = {
      #  Unit = {
      #    PartOf
      #  };
      #};
    };

    services = {
      gvfs.enable = true;
      devmon.enable = true;
      udisks2.enable = true;
      upower.enable = true;
      power-profiles-daemon.enable = true;
      accounts-daemon.enable = true;
      illum.enable = true;
      tumbler.enable = true;
      gnome = {
        evolution-data-server.enable = true;
        glib-networking.enable = true;
        gnome-keyring.enable = true;
        gnome-online-accounts.enable = true;
        localsearch.enable = true;
        tinysparql.enable = true;
        sushi.enable = true;
      };
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

      #xserver.enable = true;
      #xserver.displayManager.startx.enable = true;
      #xserver.displayManager.lightdm.enable = true;
      #xserver.displayManager.defaultSession = "hyprland";
      #xserver.displayManager.sddm.wayland.enable = true;

      # I have no idea if, or why this should be necessary, but I
      # saw someone else do this for wayland so let's give it a shot
      xserver.videoDrivers = [ "amdgpu" ];

      greetd = {
        enable = true;
        settings = rec {
          initial_session = {
            command = "${hyprland-package}/bin/Hyprland";
            user = username;
          };
          default_session = initial_session;
        };
      };

    };

    systemd.tmpfiles.rules = [ "d '/var/cache/greeter' - greeter greeter - -" ];
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
        fira-code-nerdfont
        fira
        fira-math
        font-awesome
        gentium
        google-fonts
        gyre-fonts
        hack-font
        hasklig
        helvetica-neue-lt-std
        iosevka
        inconsolata
        inter
        jetbrains-mono
        #  ipafont
        liberation_ttf
        libertine
        powerline-fonts
        terminus_font
        #nerdfonts
        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk-sans
        ipaexfont
        kochi-substitute
        roboto
        source-code-pro
        source-sans-pro
        symbola
        #vistafonts
        ubuntu_font_family
        joypixels
      ];
      fontconfig.defaultFonts.emoji = [
        "JoyPixels"
        "Noto Color Emoji"
      ];
    };
    nixpkgs.config.joypixels.acceptLicense = true;

    hardware.graphics = {
      package = hyprland-nixpkgs.mesa.drivers;
      package32 = hyprland-nixpkgs.pkgsi686Linux.mesa.drivers;
      extraPackages = with hyprland-nixpkgs; [
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

    #system.activationScripts.wallpaper = let
    #  wp = pkgs.writeShellScript "wp" ''
    #    CACHE="/var/cache/greeter"
    #    OPTS="$CACHE/options.json"
    #    HOME="/home/ben"

    #    mkdir -p "$CACHE"
    #    chown greeter:greeter $CACHE

    #    if [[ -f "$HOME/.cache/ags/options.json" ]]; then
    #      cp $HOME/.cache/ags/options.json $OPTS
    #      chown greeter:greeter $OPTS
    #    fi

    #    if [[ -f "$HOME/.config/background" ]]; then
    #      cp "$HOME/.config/background" $CACHE/background
    #      chown greeter:greeter "$CACHE/background"
    #    fi
    #  '';
    #in
    #  builtins.readFile wp;
  };
}
