# Atropos 用アプリケーション設定
{
  imports = [
    # ─── ブラウザ ───
    ../../modules/Home/apps/browser/chrome.nix
    ../../modules/Home/apps/browser/vivaldi.nix

    # ─── コミュニケーション ───
    ../../modules/Home/apps/communication/discord.nix
    ../../modules/Home/apps/communication/slack.nix

    # ─── クリエイティブ ───
    ../../modules/Home/apps/creative/blender.nix
    ../../modules/Home/apps/media/spotify.nix

    # ─── ノート / ドキュメント ───
    ../../modules/Home/apps/document/obsidian.nix


    # ─── AI ───
    ../../modules/Home/apps/ai/opencode.nix
    ../../modules/Home/apps/ai/codex.nix

    # ─── 開発 / IDE ───
    ../../modules/Home/development/rider.nix

    # ─── リモートデスクトップ ───
    ../../modules/Home/apps/vdesktop/tigervnc.nix

    # ─── 同期 / セキュリティ ───
    ../../modules/Home/apps/communication/nextcloud.nix
    ../../modules/Home/apps/utility/bitwarden.nix
  ];
}
