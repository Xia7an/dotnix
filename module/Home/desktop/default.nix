# Desktop environment and window manager modules
# Linux/Wayland モジュールは macOS ではスキップする
{ pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    (lib.mkIf isLinux ./niri.nix)
    # (lib.mkIf isLinux ./hyprland.nix)
    (lib.mkIf isLinux ./hyprlock.nix)
    # (lib.mkIf isLinux ./sway.nix)
    (lib.mkIf isLinux ./waybar.nix)
    # (lib.mkIf isLinux ./wofi.nix)
    (lib.mkIf isLinux ./rofi.nix)
    (lib.mkIf isLinux ./wlogout.nix)
    # (lib.mkIf isLinux ./anyrun)
    (lib.mkIf isLinux ./logi.nix)
    # (lib.mkIf isLinux ./walker.nix)
    (lib.mkIf isLinux ./swww.nix)
    (lib.mkIf isLinux ./noctalia.nix)
  ];
}