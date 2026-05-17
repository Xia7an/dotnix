{ pkgs, ... }: {
  home.packages = with pkgs; [ vlc geeqie playerctl ];
}
