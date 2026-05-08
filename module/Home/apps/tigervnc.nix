{ pkgs, ... }: {
  home.packages = with pkgs; [ tigervnc tigervnc-viewer ];
}