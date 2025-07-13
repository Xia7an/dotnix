{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    plugins = [];
  };
  home.file.".config/nvim" = {
    source = ../../config/nvim;
    recursive = true;
  };
}

