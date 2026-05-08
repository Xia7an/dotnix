# Lachesis ホスト固有の Home Manager 設定
# macOS (Apple Silicon) 用のユーザー環境設定
# 各カテゴリの詳細は apps.nix, develop.nix, terminal.nix を参照
{ config, pkgs, lib, ... }:
{
  imports = [
    ../../home.nix
    ./apps.nix
    ./develop.nix
    ./terminal.nix

    # macOS 固有設定
    ../../module/Home/desktop/darwin.nix

    # macOS 固有パッケージ
    ../../module/Home/darwin/fonts.nix
    ../../module/Home/darwin/pinentry-mac.nix
    ../../module/Home/darwin/m-cli.nix
  ];

  # ───────────────────────────────────────────
  # ユーザー基本情報
  # ───────────────────────────────────────────
  home = {
    username = "inoyu";
    homeDirectory = "/Users/inoyu";
    stateVersion = "25.11";
  };

  # ───────────────────────────────────────────
  # 環境変数 (macOS 固有)
  # ───────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Ghostty macOS 固有の設定を重ねる
  programs.ghostty.settings = lib.mkIf (builtins.hasAttr "ghostty" pkgs) {
    font-size = 14;
    theme = "catppuccin-macchiato";
    macos-titlebar-style = "tabs";
    background-opacity = 0.92;
  };
}