# Hammerspoon 本体は nix-darwin の Homebrew cask で管理する。
{
  lib,
  pkgs,
  ...
}:
let
  defaultInit = pkgs.writeText "hammerspoon-init.lua" ''
    -- Hammerspoon 設定
    hs.autoLaunch(true)
    hs.automaticallyCheckForUpdates(true)

    aerospaceWindowGrid = require("aerospace-window-grid").start()
  '';
in
{
  # 既存の設定を優先する。init.lua を home.file で管理すると、既存の
  # 通常ファイルとの競合時に Home Manager が切り替えを中断するため、
  # ファイルがまだない場合だけ初期設定を作成する。
  home.activation.hammerspoonInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.hammerspoon/init.lua"

    if [ -e "$target" ] || [ -L "$target" ]; then
      verboseEcho "Keeping existing $target"
    elif [[ -v DRY_RUN ]]; then
      verboseEcho "Would create $target"
    else
      mkdir -p "$(dirname "$target")"
      install -m 0644 ${defaultInit} "$target"
    fi
  '';

  home.file.".hammerspoon/aerospace-window-grid.lua".source =
    ../../../config/hammerspoon/aerospace-window-grid.lua;
}
