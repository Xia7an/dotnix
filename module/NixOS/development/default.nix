# NixOS レベルの開発環境設定
# ユーザーレベルの開発ツールは module/Home/development/ で管理する
# unity.nix は Atropos 固有のため hosts/Atropos/default.nix でインポートする
{ pkgs, inputs, ...} : {
  imports = [
    # mise / uv (python) はユーザーレベルで十分なため Home Manager 側に移動
    # → module/Home/development/dev-tools.nix を参照
  ];
}
