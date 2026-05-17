# Desktop environment and window manager modules
# Linux/Wayland モジュールは macOS ではスキップする
{ ... }: {
  imports = [
    ./niri.nix
    # ./hyprland.nix
    ./hyprlock.nix
    # ./sway.nix
    ./waybar.nix
    # ./wofi.nix
    ./rofi.nix
    ./wlogout.nix
    ./swaync.nix
    # ./anyrun
    ./logi.nix
    # ./walker.nix
    ./swww.nix
    ./noctalia.nix
  ];
}
