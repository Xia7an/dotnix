# system ごとに適用する overlay のリストを組み立てる。
#
# 戻り値は { <system> = [ overlay ... ]; ... } の attrset。
# genAttrs でメモ化しているため、nixpkgs-unstable のインスタンス化は
# system ごとに高々 1 回しか行われない。
#
# 各 overlay の役割:
#   rust-overlay      … pkgs.rust-bin.* (任意バージョンの Rust ツールチェイン) を追加
#   local-packages    … modules/pkgs/ の自作パッケージを追加
#   unstable          … nixpkgs-unstable 一式を pkgs.unstable として追加 (stable は上書きしない)
{
  inputs,
  config,
  systems,
}:
let
  inherit (inputs.nixpkgs) lib;
in
lib.genAttrs systems (
  system:
  let
    unstablePkgs = import inputs.nixpkgs-unstable { inherit system config; };
  in
  [
    (import inputs.rust-overlay)
    (import ./local-packages.nix)
    (import ./unstable.nix unstablePkgs)
  ]
)
