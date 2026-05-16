{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  services.awww.enable = true;
}
