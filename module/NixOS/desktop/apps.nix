# NixOS レベルで管理するデスクトップアプリケーション
# ブラウザ・Discord などユーザー設定が必要なものは module/Home/apps/ で管理する
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # メール
    thunderbird

    # ドキュメント・ビューア
    kdePackages.okular

    # ファイルマネージャー
    nautilus
    gnome-text-editor
    sushi       # Nautilus のプレビュー機能

    # ノート・知識管理
    obsidian
    notion-app-enhanced
  ];
}
