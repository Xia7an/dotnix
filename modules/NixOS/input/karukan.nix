# karukan (ニューラルかな漢字変換 IME) の fcitx5 アドオンをシステムの fcitx5 に追加する。
# fcitx5 を NixOS 側 (modules/NixOS/input/fcitx5.nix) で有効にしているホスト向け。
#
#   imports = [ ../../modules/NixOS/input/karukan.nix ];
#   programs.karukan.enable = true;
#
# 辞書と config.toml はユーザーごとのファイルなので、Home Manager 側で
# modules/Home/input/karukan.nix を addToFcitx5Addons = false にして併用する。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.karukan;
in
{
  options.programs.karukan = {
    enable = lib.mkEnableOption "karukan Japanese input method for fcitx5";
    package = lib.mkPackageOption pkgs "fcitx5-karukan" { };
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod.fcitx5.addons = [ cfg.package ];
  };
}
