# Desktop environment and window manager modules
{pkgs, lib, ...}:{
  imports = [
    ./niri.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./sway.nix
    ./waybar.nix
    ./wofi.nix
    ./wlogout.nix
    ./anyrun
    ./walker.nix
    ./swww.nix
  ];
}