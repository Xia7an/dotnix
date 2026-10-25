# Hammerspoon 本体は nix-darwin の Homebrew cask で管理する。
# 設定はリポジトリのファイルへ直接リンクするので、編集後は
# Hammerspoon の Reload Config だけで反映される (switch は不要)。
{ config, ... }:
let
  configDir = "${config.home.homeDirectory}/Gits/dotnix/config/hammerspoon";
  link = name: config.lib.file.mkOutOfStoreSymlink "${configDir}/${name}";
in
{
  home.file.".hammerspoon/init.lua".source = link "init.lua";
  home.file.".hammerspoon/aerospace-window-grid.lua".source = link "aerospace-window-grid.lua";
}
