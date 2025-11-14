{pkgs, ...} : {
  home.file.".config/niri" = {
    source = ../../../config/niri;
    recursive = true;
  };
  # 1. dconf/GSettings を有効にする
  # これにより、GSettingsスキーマがコンパイルされ、
  # 関連する環境変数 (GSETTINGS_SCHEMA_DIR) が設定されます。
  dconf.enable = true;

  # 2. XDGデスクトップポータルを有効にする
  # Wayland環境で多くのデスクトップ機能（ファイルピッカー、スクリーンショットなど）
  # と設定（GTKテーマ、アイコンなど）を正しく読み込むために必要です。
  xdg.portal = {
    enable = true;
    
    # Hyprlandを使っているので、バックエンドを指定します
    # (もし systemPackages で gtk, gnome, kde などを
    #  インストールしている場合は不要なこともあります)
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      # Hyprland を使っている場合は以下も推奨されます
      # pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # 3. (念のため) GTKテーマやアイコンを設定する
  # これらが設定されていると、Home Managerが関連する
  # XDG_DATA_DIRS パスを自動的に追加してくれます。
  gtk = {
    enable = true;
    theme.name = "Adwaita"; # 例: 好きなテーマ名
    iconTheme.name = "Adwaita"; # 例: 好きなアイコンテーマ名
  };
}
