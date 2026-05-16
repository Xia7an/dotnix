{pkgs, config, ...}:{
  xdg.configFile."nvim" = { 
    source = ../../../config/nvchad; 
    recursive = true; 
  };
  programs.neovim = {
    enable = true;
  };
}
