{ inputs, pkgs, ... }: {
  programs.kitty.enable = true; # required for the default Hyprland config
  wayland.windowManager.hyprland.enable = true; # enable Hyprland
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "jp";
      kb_variant = "";
    };
  };

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
  home.file.".config/swaync" = {
    source = ../../config/swaync;
    recursive = true;
  };
  home.file.".config/environment.d" = {
    source = ../../config/environment.d;
    recursive = true;
  };

}

