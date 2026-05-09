{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  services.swww.enable = true;
}
