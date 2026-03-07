# NixOS レベルの開発環境設定
# ユーザーレベルの開発ツールは module/Home/development/ で管理する
{ pkgs, inputs, ...} : {
  imports = [
    # unity.nix はシステムレベルの設定が必要なため NixOS 側で管理
    ./unity.nix
    # mise / uv (python) はユーザーレベルで十分なため Home Manager 側に移動
    # → module/Home/development/dev-tools.nix を参照
  ];
}
