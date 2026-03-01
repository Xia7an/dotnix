{ pkgs, lib, ... }:
{
  home.packages = [
    pkgs.hyprshell
  ];

  wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
    "$mainMod, Tab, exec, hyprshell"
  ];

  wayland.windowManager.hyprland.settings.exec-once = lib.mkAfter [
    "hyprshell run"
  ];
}
