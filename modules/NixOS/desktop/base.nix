{ pkgs, ... }:
{
  programs.ydotool.enable = true;

  # Wayland desktop essentials shared across hosts.
  environment.systemPackages = with pkgs; [
    gobject-introspection
    gtk3
    python3
    python3Packages.pygobject3
  ];

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };
}
