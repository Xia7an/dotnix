# Lachesis 用アプリケーション設定
# GUI アプリ本体は nix-darwin の Homebrew cask で管理し、ここでは設定と
# プラットフォーム共通の CLI ツールだけを Home Manager へ委譲する。
{
  imports = [
    # ─── macOS 自動化 / ウィンドウ管理 ───
    ../../modules/Home/darwin/aquaskk.nix
    ../../modules/Home/darwin/hammerspoon.nix
    ../../modules/Home/darwin/ice.nix
    ../../modules/Home/darwin/alt-tab.nix

    # ─── マルチメディア / PDF ───
    ../../modules/Home/apps/media/multimedia.nix
    ../../modules/Home/apps/document/pdf.nix
  ];
}
