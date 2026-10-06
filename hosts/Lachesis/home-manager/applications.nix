# Lachesis 用アプリケーション設定
# nixpkgs で導入できない(または cask 版が実質標準の) GUI アプリだけ
# nix-darwin の Homebrew cask に残し、それ以外は Home Manager へ委譲する。
{
  imports = [
    # ─── macOS 自動化 / ウィンドウ管理 ───
    ../../../modules/Home/darwin/aquaskk.nix
    ../../../modules/Home/darwin/aerospace.nix
    ../../../modules/Home/darwin/hammerspoon.nix
    ../../../modules/Home/darwin/ice.nix

    # ─── AI ───
    # ChatGPT 本体は Homebrew、通常の Codex CLI は Nix で管理する。
    # claude は native installer 版 (~/.local/bin/claude) をそのまま使う
    # (nvim の avante.nvim もこれを ACP 経由で叩く)。
    ../../../modules/Home/apps/ai/chatgpt.nix
    ../../../modules/Home/apps/ai/opencode.nix

    # ─── マルチメディア / PDF ───
    ../../../modules/Home/apps/media/multimedia.nix
    ../../../modules/Home/apps/document/pdf.nix

    # ─── Nixpkgs で管理する GUI アプリ ───
    ../../../modules/Home/apps/vdesktop/immersed.nix
    ../../../modules/Home/apps/creative/blender.nix
    ../../../modules/Home/apps/creative/musescore.nix

    # discord / slack は Homebrew cask で管理する (modules/darwin/homebrew/applications.nix)
    ../../../modules/Home/apps/browser/chrome.nix
    ../../../modules/Home/apps/document/obsidian.nix
  ];
}
