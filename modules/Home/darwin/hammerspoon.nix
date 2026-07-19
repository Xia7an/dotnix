# Hammerspoon 本体は nix-darwin の Homebrew cask で管理する。
{
  home.file.".hammerspoon/init.lua".text = ''
    -- Hammerspoon 設定
    hs.autoLaunch(true)
    hs.automaticallyCheckForUpdates(true)

    -- ウィンドウ管理 (yabai 使用時はコメントアウト)
    -- hs.loadSpoon("WindowManagement")
  '';
}
