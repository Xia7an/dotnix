# AeroSpace 本体は nix-darwin の Homebrew cask で管理する。
# 設定はリポジトリのファイルへ直接リンクするので、編集後は
# `aerospace reload-config` だけで反映される (switch は不要)。
{ config, ... }:
{
  xdg.configFile."aerospace/aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Gits/dotnix/config/aerospace/aerospace.toml";
}
