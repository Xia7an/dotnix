{ pkgs, ... }: {
  home.packages = with pkgs; [
    nautilus

    # サムネイラー (Nautilus のサムネイル生成)
    papers # PDF
    evince # PDF
    ffmpegthumbnailer # 動画
    gnome-epub-thumbnailer # EPUB / MOBI
    gnome-font-viewer # フォント
    f3d # 3D モデル

    # ファイル種別ごとのアプリ・プレビュー
    sushi # スペースキーでクイックプレビュー
    loupe # 画像
    showtime # 動画
    decibels # 音声
    gnome-text-editor # テキスト
    meld # 差分

    # Nautilus の裏で動く基盤まわりの GUI
    gnome-online-accounts-gtk # GNOME 設定なしでオンラインアカウントを追加する UI
    baobab # ディスク使用量
  ];
}
