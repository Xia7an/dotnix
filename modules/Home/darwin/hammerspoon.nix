# Hammerspoon — macOS 自動化フレームワーク
{ pkgs, ... }: {
  home.packages = with pkgs; [ hammerspoon ];

  home.file.".hammerspoon/init.lua".text = ''
    -- Hammerspoon 設定
    hs.autoLaunch(true)
    hs.automaticallyCheckForUpdates(true)

    -- ウィンドウ管理 (yabai 使用時はコメントアウト)
    -- hs.loadSpoon("WindowManagement")
  '';
}