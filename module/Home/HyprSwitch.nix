{ pkgs, lib, ... }:
{
  home.packages = [
    pkgs.hyprswitch
  ];

  wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
    "$mainMod, Tab, exec, hyprswitch"
  ];
}
