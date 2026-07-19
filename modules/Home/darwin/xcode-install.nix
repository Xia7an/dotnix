{ pkgs, ... }: {
  home.packages = with pkgs; [ xcode-install ];
}