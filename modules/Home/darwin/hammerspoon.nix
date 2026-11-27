# Hammerspoon 本体は nix-darwin の Homebrew cask で管理する。
# 設定はリポジトリのファイルを Nix store に取り込んで配置する (リポジトリの置き場所に依存しない)。
# 編集後は home-manager switch のあと、Hammerspoon の Reload Config で反映される。
{ ... }:
let
  configDir = ../../../config/hammerspoon;
in
{
  home.file.".hammerspoon/init.lua".source = "${configDir}/init.lua";
  home.file.".hammerspoon/aerospace-window-grid.lua".source =
    "${configDir}/aerospace-window-grid.lua";
}
