# AeroSpace 本体は nix-darwin の Homebrew cask で管理する。
# 設定はリポジトリのファイルを Nix store に取り込んで配置する (リポジトリの置き場所に依存しない)。
# 編集後は home-manager switch のあと、`aerospace reload-config` で反映される。
{ ... }:
{
  xdg.configFile."aerospace/aerospace.toml".source = ../../../config/aerospace/aerospace.toml;
}
