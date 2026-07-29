# Lachesis 用アプリケーション設定
# nixpkgs で導入できない(または cask 版が実質標準の) GUI アプリだけ
# nix-darwin の Homebrew cask に残し、それ以外は Home Manager へ委譲する。
{
  imports = [
    # ─── macOS 自動化 / ウィンドウ管理 ───
    ../../../modules/Home/darwin/aquaskk.nix
    ../../../modules/Home/darwin/ice.nix

    # ─── マルチメディア / PDF ───
    ../../../modules/Home/apps/media/multimedia.nix
    ../../../modules/Home/apps/document/pdf.nix

    # ─── Nixpkgs で管理する GUI アプリ ───
    ../../../modules/Home/apps/vdesktop/immersed.nix
    ../../../modules/Home/apps/creative/blender.nix
    ../../../modules/Home/apps/creative/musescore.nix
    ../../../modules/Home/apps/communication/discord.nix
    ../../../modules/Home/apps/communication/slack.nix
    ../../../modules/Home/apps/browser/chrome.nix
    ../../../modules/Home/apps/document/obsidian.nix
  ];
}
