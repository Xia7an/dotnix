{ config, pkgs, ... }:

{
  # デスクトップアプリケーション群
  environment.systemPackages = with pkgs; [
    # メール/チャット
    thunderbird
    discord

    # ドキュメント/ビューワ
    kdePackages.okular # Qt6 版 Okular

    # ファイルマネージャー
    nautilus
    sushi # Nautilus のプレビュー機能

    # Notion と Obsidian (AppImage または公式パッケージ)
    # Notion は公式 Electron アプリ、Obsidian は Nix で利用可能
    obsidian
    # notion-app-enhanced # 必要に応じて追加

    # ネットワーク管理
    networkmanagerapplet # nm-applet
  ];
}
