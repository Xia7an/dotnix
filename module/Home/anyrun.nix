{pkgs, inputs, ...} : {
  programs.anyrun = {
    enable = true;
  };
  home.file.".config/anyrun/" = {
    source = ../../config/anyrun;
    recursive = true;
  };

}
