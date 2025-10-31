{pkgs, ...} : {
  home.file.".config/niri" = {
    source = ../../../config/niri;
    recursive = true;
  };
}
