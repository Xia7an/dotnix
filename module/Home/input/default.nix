# Input method modules
# fcitx5 は Linux/Wayland 向け。macOS ではスキップする
{ pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    (lib.mkIf isLinux ./fcitx5.nix)
    # (lib.mkIf isLinux ./ibus.nix)  # Alternative to Fcitx5
  ];
}