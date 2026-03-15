# Atropos ホスト固有の Home Manager 設定
# 共通設定は home.nix に記述されている
# Atropos 固有のアプリ (Rider など) はここでインポートする
{ inputs, pkgs, pkgs-stable, ... }:
{
  imports = [
    # 共通 Home Manager 設定
    ../../home.nix

    # Atropos 固有モジュール (Anemoi にはインストールしない)
    ../../module/Home/development/rider.nix
  ];
}
