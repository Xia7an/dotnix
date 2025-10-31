{pkgs, inputs, ...} : {
  programs.wlogout = {
    enable = true;
  };
  home.file.".config/wlogout" = {
    source = ../../../config/wlogout;
    recursive = true;
  };
}
