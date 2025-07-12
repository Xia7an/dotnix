{ inputs, pkgs, ... }: {
  programs.kitty.enable = true; # required for the default Hyprland config
  wayland.windowManager.hyprland.enable = true; # enable Hyprland
  home.file.".config/hypr" = {
    source = ../../config/hypr;
    recursive = true;
  };
  home.file.".config/waybar" = {
    source = ../../config/waybar;
    recursive = true;
  };
  home.file.".config/rofi" = {
    source = ../../config/rofi;
    recursive = true;
  };
}
