{ pkgs, lib, ... }:
{
  # Waylandセッションに必要なもの（例: HyprlandやGnomeなどを使う前提）
  services.dbus.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc-ut ];
  };

  # XKB設定（Waylandでもキーマップに影響）
  # 日本語106/109キーボードの変換/無変換キーを認識させる
  services.xserver.xkb = {
    layout = "jp";
    variant = "";
    # 日本語キーボードの特殊キーを有効化
    options = "terminate:ctrl_alt_bksp";
  };
  
  # コンソール設定も日本語キーボードに
  console.keyMap = "jp106";

  # Mozc 設定ツールに必要なパッケージをシステムに追加
  environment.systemPackages = with pkgs; [
    # Qt6 とプラットフォームプラグイン
    qt6.qtbase
    qt6.qtwayland
    
    # IBus と Mozc
    ibus
    ibus-engines.mozc
    
    # Qt5 サポート（互換性のため）
    libsForQt5.qt5.qtwayland
  ];

  # Qt プラットフォームプラグインの環境変数（システム全体）
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    # IBus の設定
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    # 日本語キーボードレイアウトの明示的な設定
    XKB_DEFAULT_LAYOUT = "jp";
    # Waylandでキーボードレイアウトを保持
    SDL_VIDEODRIVER = "wayland";
  };

  # Qt プラットフォームサポートを有効化
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

}
