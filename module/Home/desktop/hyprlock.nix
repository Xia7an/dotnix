{pkgs, inputs, ...} : {
  programs.hyprlock = {
    enable = true;
  };
  home.file.".config/hypr/hyprlock.conf" = {
    source = ../../../config/hypr/hyprlock.conf;
  };
  home.file.".config/hypr/hyprlock.png" = {
    source = ../../../config/hypr/hyprlock.png;
  };
  home.file.".config/hypr/vivek.png" = {
    source = ../../../config/hypr/vivek.png;
  };
  home.file.".config/hypr/Scripts" = {
    source = ../../../config/hypr/Scripts;
    recursive = true;
  };
  
}
