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
    graphicsStuff.pkgs = pkgs.hyprland-pkgs;
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

    environment.systemPackages = with pkgs; [
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
      swaynotificationcenter # notification daemon + center (replaces mako)
      swayosd # on-screen display for volume/brightness
      wlogout # logout/power menu

      # mako # replaced by swaynotificationcenter
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
