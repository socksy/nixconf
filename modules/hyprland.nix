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
  system = pkgs.stdenv.hostPlatform.system;
  hyprland-package = inputs.hyprland.packages.${system}.hyprland;
  hyprland-portals-package = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
  hyprland-nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
  hyprland-plugins = inputs.hyprland-plugins.packages.${system};
  hypr-plugin-dir = pkgs.symlinkJoin {
    name = "hyprland-plugins";
    paths = [
      inputs.Hyprspace.packages.${system}.Hyprspace
      # hyprexpo  # broken against hyprland 0.54+ as of 2026-04-27, see hyprland-plugins#640
    ];
  };
  mkGraphicalService =
    {
      description,
      exec,
      extraConfig ? { },
    }:
    {
      inherit description;
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = exec;
        Restart = "on-failure";
        RestartSec = 1;
      }
      // extraConfig;
    };
in
{
  options.hyprland = {
    enable = lib.mkEnableOption "Hyprland";
  };

  config = lib.mkIf config.hyprland.enable {
    graphicsStuff.pkgs = pkgs.hyprland-pkgs;

    # Set plugin directory for Hyprland plugins
    environment.sessionVariables.HYPR_PLUGIN_DIR = "${hypr-plugin-dir}";

    # uwsm finalize pushes UWSM_FINALIZE_VARNAMES into systemd --user env
    environment.etc."uwsm/env".text = ''
      export PATH=$HOME/bin:/run/wrappers/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH
      export UWSM_FINALIZE_VARNAMES="PATH XDG_DATA_DIRS XDG_CONFIG_DIRS NIX_PROFILES"
    '';
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    programs.hyprland = {
      enable = true;
      package = hyprland-package;
      portalPackage = hyprland-portals-package;
      xwayland.enable = true;
      withUWSM = true;
    };

    programs.xwayland.package = hyprland-nixpkgs.xwayland;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        hyprland-portals-package
        xdg-desktop-portal-gtk
      ];
      #wlr.enable = true;
      config.common.default = "*";
    };
    security = {
      #pam.services.ags = {};
      pam.services.swaylock = { };
    };

    environment.systemPackages = with hyprland-nixpkgs; [
      loupe
      nautilus
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
      xdg-utils
      swayidle

      # Launchers
      rofi # legacy, keeping for now
      vicinae # raycast-style launcher

      # Shell components (ashell replaces waybar/ags bar)
      ashell
      awww # wallpaper daemon (formerly swww)
      yad # for calendar popup
      swaynotificationcenter # notification daemon + center (replaces mako)
      swayosd # on-screen display for volume/brightness
      wlogout # logout/power menu

      # mako # replaced by swaynotificationcenter
      polkit_gnome

      # Hyprland plugins
      # hyprland-plugins.hyprexpo  # broken against hyprland 0.54+ as of 2026-04-27
      inputs.Hyprspace.packages.${system}.Hyprspace

    ];
    # to match opengl versions
    programs.firefox.package = hyprland-nixpkgs.firefox;

    systemd.user.services = {
      xremap = {
        wantedBy = lib.mkForce [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      polkit-gnome-authentication-agent-1 = mkGraphicalService {
        description = "Polkit authentication agent";
        exec = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        extraConfig.TimeoutStopSec = 10;
      };
      swayosd =
        mkGraphicalService {
          description = "SwayOSD volume/brightness OSD";
          exec = "${pkgs.swayosd}/bin/swayosd-server";
        }
        // {
          startLimitBurst = 0;
        }; # disable restart rate limit

      kanshi = mkGraphicalService {
        description = "Kanshi dynamic output configuration";
        exec = "${pkgs.kanshi}/bin/kanshi";
      };

      wl-clip-persist = mkGraphicalService {
        description = "Keep wayland clipboard contents after source app closes";
        exec = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular";
      };

      cliphist-store = mkGraphicalService {
        description = "Watch clipboard and append history to cliphist";
        exec = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      };

      ashell = mkGraphicalService {
        description = "ashell status bar";
        exec = "${hyprland-nixpkgs.ashell}/bin/ashell";
      };

      swaync = mkGraphicalService {
        description = "SwayNotificationCenter notification daemon";
        exec = "${hyprland-nixpkgs.swaynotificationcenter}/bin/swaync";
      };

      vicinae = mkGraphicalService {
        description = "Vicinae launcher server";
        exec = "${hyprland-nixpkgs.vicinae}/bin/vicinae server";
      };

      swayidle = mkGraphicalService {
        description = "Swayidle idle management daemon";
        exec = "${hyprland-nixpkgs.swayidle}/bin/swayidle";
      };

      awww-daemon = mkGraphicalService {
        description = "awww wallpaper daemon";
        exec = "${pkgs.awww}/bin/awww-daemon";
      };

      awww-wallpaper = {
        description = "Apply wallpaper from ~/.config/background";
        wantedBy = [ "awww-daemon.service" ];
        after = [ "awww-daemon.service" ];
        requires = [ "awww-daemon.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
          ExecStart = "${pkgs.awww}/bin/awww img %h/.config/background";
        };
      };
    };

    services = {
      gvfs.enable = true;
      devmon.enable = true;
      udisks2.enable = true;
      upower.enable = true;
      power-profiles-daemon.enable = true;
      accounts-daemon.enable = true;
      # illum.enable = true; # using swayosd instead
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

      #xserver.enable = true;
      #xserver.displayManager.startx.enable = true;
      #xserver.displayManager.lightdm.enable = true;
      #xserver.displayManager.defaultSession = "hyprland";
      #xserver.displayManager.sddm.wayland.enable = true;

      greetd = {
        enable = true;
        settings = rec {
          initial_session = {
            command = "${pkgs.uwsm}/bin/uwsm start -- hyprland-uwsm.desktop";
            user = username;
          };
          default_session = initial_session;
        };
      };

    };

    systemd.tmpfiles.rules = [ "d '/var/cache/greeter' - greeter greeter - -" ];
    nixpkgs.config.joypixels.acceptLicense = true;

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
