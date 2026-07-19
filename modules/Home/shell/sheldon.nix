{ pkgs, ... }: {
  home.packages = with pkgs; [ sheldon ];
}