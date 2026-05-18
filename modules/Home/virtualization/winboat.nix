{ pkgs, ... }: {
  home.packages = with pkgs; [  (winboat.override { electron = pkgs.electron_40; }) ];
}
