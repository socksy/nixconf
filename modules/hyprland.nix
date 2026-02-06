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
    paths = with hyprland-plugins; [
      hyprexpo
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
      yad # for calendar popup
      swaynotificationcenter # notification daemon + center (replaces mako)
      swayosd # on-screen display for volume/brightness
      wlogout # logout/power menu

      # mako # replaced by swaynotificationcenter
      polkit_gnome

      # Hyprland plugins
      hyprland-plugins.hyprexpo
    ];
    # to match opengl versions
    programs.firefox.package = hyprland-nixpkgs.firefox;

    systemd.user.services = {
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
            command = "${hyprland-package}/bin/start-hyprland";
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
