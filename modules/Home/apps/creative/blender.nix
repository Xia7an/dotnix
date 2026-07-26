{ pkgs, ... }: {
  home.packages = with pkgs.unstable; [ blender ];
}