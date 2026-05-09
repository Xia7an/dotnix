# Lachesis 用アプリケーション設定
# 通常のデスクトップアプリケーション + macOS 固有アプリ
#
# 共通アプリ (全プラットフォーム)
#   - chrome, vivaldi, discord       → module/Home/apps/
#   - blender, slack, obsidian, etc. → module/Home/apps/
#
# macOS 固有アプリ
#   - hammerspoon, raycast, alt-tab, iterm2, macvim → module/Home/darwin/
{
  imports = [
    # ─── ブラウザ ───
    ../../module/Home/apps/chrome.nix
    ../../module/Home/apps/vivaldi.nix

    # ─── コミュニケーション ───
    ../../module/Home/apps/discord.nix
    ../../module/Home/apps/slack.nix

    # ─── クリエイティブ ───
    ../../module/Home/apps/blender.nix
    ../../module/Home/apps/musescore.nix
    ../../module/Home/apps/spotify.nix

    # ─── ノート / ドキュメント ───
    ../../module/Home/apps/obsidian.nix
    ../../module/Home/darwin/skimpdf.nix

    # ─── 開発 / IDE ───
    ../../module/Home/apps/rstudio.nix
    ../../module/Home/darwin/iterm2.nix
    ../../module/Home/darwin/macvim.nix

    # ─── VNC ───
    ../../module/Home/apps/tigervnc.nix

    # ─── 同期 / セキュリティ ───
    ../../module/Home/apps/nextcloud.nix
    ../../module/Home/apps/bitwarden.nix

    # ─── macOS 自動化 / ウィンドウ管理 ───
    ../../module/Home/darwin/aquaskk.nix
    ../../module/Home/darwin/hammerspoon.nix
    ../../module/Home/darwin/ice.nix
    ../../module/Home/darwin/raycast.nix
    ../../module/Home/darwin/alt-tab.nix

    # ─── マルチメディア / PDF ───
    ../../module/Home/apps/multimedia.nix
    ../../module/Home/apps/pdf.nix
  ];
}
