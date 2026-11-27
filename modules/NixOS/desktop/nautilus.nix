{ ... }: {
  # ゴミ箱、SMB/SFTP/MTP、「他の場所」、オンラインアカウントのマウント
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Google Drive / Nextcloud などを Nautilus のサイドバーにマウントする
  services.gnome.gnome-online-accounts.enable = true;

  # Nautilus 検索でファイルの中身まで含めて全文検索する
  services.gnome.localsearch.enable = true;
  services.gnome.tinysparql.enable = true;

  # 公開フォルダを WebDAV で共有する
  services.gnome.gnome-user-share.enable = true;

  # ISO などのイメージファイルをダブルクリックでマウントする (gnome-disk-utility)
  programs.gnome-disks.enable = true;
}
