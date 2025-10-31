{pkgs, ... } : {
  home.file.".config/alactirry" = {
    source = ../../config/alacritty;
  };
}
