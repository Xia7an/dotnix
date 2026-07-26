{ pkgs, ... }: {
  home.packages = with pkgs.unstable; [
    vivaldi
  ];
}
