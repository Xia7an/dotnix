# Nyx 用アプリケーション設定
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

    # ─── VNC ───
    ../../modules/Home/apps/tigervnc.nix

    # ─── 同期 / セキュリティ ───
    ../../modules/Home/apps/nextcloud.nix
    ../../modules/Home/apps/bitwarden.nix
  ];
}