{ pkgs, lib, inputs, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  programs.wlogout = {
    enable = true;
  };
  home.file.".config/wlogout" = {
    source = ../../../config/wlogout;
    recursive = true;
  };
}
