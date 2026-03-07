{ inputs, pkgs, ... } : {
  home.packages = [
    inputs.quickshell.packages.${pkgs.system}.default
    pkgs.libsForQt5.qt5.qtgraphicaleffects
  ];


  home.file.".config/quickshell" = {
    source = ../../../config/quickshell/ii;
    recursive = true;
  };
}
