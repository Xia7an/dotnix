{ pkgs, ... }: {
  home.packages = with pkgs; [
    mpv
    ffmpeg
    imagemagick
    fontforge
    gnuplot
  ];
}