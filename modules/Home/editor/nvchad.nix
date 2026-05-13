{pkgs, ...}:{
  xdg.configFile."nvim" = {
    source = ../../../config/nvchad;
    recursive = true;
  };
}
