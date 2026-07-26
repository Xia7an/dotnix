{ pkgs, ... }: {
  home.packages = with pkgs.unstable; [ nextcloud-client ];
}