{ inputs, pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  programs.rofi = {
    enable = true;
  };
}
