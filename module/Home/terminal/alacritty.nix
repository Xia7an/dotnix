{pkgs, ... } : {
  home.file.".config/alacritty" = {
    source = ../../../config/alacritty;
  };
}
