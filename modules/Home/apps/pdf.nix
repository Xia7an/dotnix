{ pkgs, ... }: {
  home.packages = with pkgs; [
    poppler-utils
    qpdf
    typst
    tectonic
  ];
}