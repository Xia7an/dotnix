# Lachesis 用アプリケーション設定
# 通常のデスクトップアプリケーション + macOS 固有アプリ
#
# 共通アプリ (全プラットフォーム)
#   - chrome, vivaldi, discord       → modules/Home/apps/
#   - blender, slack, obsidian, etc. → modules/Home/apps/
#
# macOS 固有アプリ
#   - hammerspoon, raycast, alt-tab, iterm2, macvim → modules/Home/darwin/
{
  imports = [
    # ─── ブラウザ ───
    ../../modules/Home/apps/chrome.nix
    ../../modules/Home/apps/vivaldi.nix

    # ─── コミュニケーション ───
    ../../modules/Home/apps/discord.nix
    ../../modules/Home/apps/slack.nix

    # ─── クリエイティブ ───
    ../../modules/Home/apps/blender.nix
    ../../modules/Home/apps/musescore.nix
    ../../modules/Home/apps/spotify.nix

    # ─── ノート / ドキュメント ───
    ../../modules/Home/apps/obsidian.nix
    ../../modules/Home/darwin/skimpdf.nix

    # ─── 開発 / IDE ───
    ../../modules/Home/apps/rstudio.nix
    ../../modules/Home/darwin/iterm2.nix
    ../../modules/Home/darwin/macvim.nix

    # ─── VNC ───
    ../../modules/Home/apps/tigervnc.nix

    # ─── 同期 / セキュリティ ───
    ../../modules/Home/apps/nextcloud.nix
    ../../modules/Home/apps/bitwarden.nix

    # ─── macOS 自動化 / ウィンドウ管理 ───
    ../../modules/Home/darwin/aquaskk.nix
    ../../modules/Home/darwin/hammerspoon.nix
    ../../modules/Home/darwin/ice.nix
    ../../modules/Home/darwin/raycast.nix
    ../../modules/Home/darwin/alt-tab.nix

    # ─── マルチメディア / PDF ───
    ../../modules/Home/apps/multimedia.nix
    ../../modules/Home/apps/pdf.nix
  ];
}
