# Windows integration modules
# winapps は Linux/QEMU 向け。macOS ではスキップする
{ pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    (lib.mkIf isLinux ./winapps.nix)
  ];
}