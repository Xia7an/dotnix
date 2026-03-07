# Desktop environment and window manager modules
{pkgs, lib, ...}:{
  imports = [
    ./niri.nix
    # ./hyprland.nix
    ./hyprlock.nix
    ./sway.nix
    ./waybar.nix
    ./wofi.nix
    ./rofi.nix
    ./wlogout.nix
    ./anyrun
    ./logi.nix
    ./walker.nix
    ./swww.nix
    ./noctalia.nix
  ];
}