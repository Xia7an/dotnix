# Anemoi 用アプリケーション設定
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

    # ─── VNC ───
    ../../module/Home/apps/tigervnc.nix

    # ─── 同期 / セキュリティ ───
    ../../module/Home/apps/nextcloud.nix
    ../../module/Home/apps/bitwarden.nix
  ];
}