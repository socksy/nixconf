{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.gnome = {
    enable = lib.mkEnableOption "gnome";
  };
  config = lib.mkIf config.gnome.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    environment.systemPackages = with pkgs.gnomeExtensions; [
      paperwm
      xremap
    ];
  };
}
