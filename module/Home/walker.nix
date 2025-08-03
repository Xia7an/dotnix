{pkgs, ...} : {
  home.packages = with pkgs; [
    walker
  ];

  home.file.".config/walker" = {
    source = ../../config/walker;
    recursive = true;
  };
}
