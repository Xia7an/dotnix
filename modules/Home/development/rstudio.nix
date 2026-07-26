{ pkgs, ... }: {
  home.packages = with pkgs.unstable; [ rstudio ];
}