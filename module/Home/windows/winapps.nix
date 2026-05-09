{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  home.file.".config/winapps" = {
    source = ../../../config/winapps;
    recursive = true;
  };
}
