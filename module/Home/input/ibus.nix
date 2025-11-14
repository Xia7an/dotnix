{ pkgs, config, ... }:

{
  # Mozc 設定ツールに必要なパッケージ
  home.packages = with pkgs; [
    # Qt6 プラットフォームプラグイン
    qt6.qtbase
    qt6.qtwayland
    
    # IBus と Mozc
    ibus
    ibus-engines.mozc-ut
    
    # 追加の Qt プラグイン
    libsForQt5.qt5.qtwayland  # Qt5 用(念のため)
  ];

  # systemdサービスとしてIBusを自動起動
  systemd.user.services.ibus-daemon = {
    Unit = {
      Description = "IBus Daemon";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.ibus}/bin/ibus-daemon --xim --panel disable --replace";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Qt プラットフォームプラグインの環境変数
  home.sessionVariables = {
    # Wayland 環境での Qt
    QT_QPA_PLATFORM = "wayland;xcb";  # Wayland を優先、フォールバックに X11
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    
    # 日本語キーボード設定
    XKB_DEFAULT_LAYOUT = "jp";
  };

  # IBus の設定ファイルを配置
  # 変換キー（Henkan）で IME オン、無変換キー（Muhenkan）で IME オフ
  xdg.configFile."ibus/ibus-setup.conf".text = ''
    [general]
    preload-engines = mozc-jp
    use-system-keyboard-layout = true
    
    [hotkey]
    # 変換キーで IME を有効化
    enable-unconditional = Henkan_Mode
    
    # 無変換キーで IME を無効化  
    disable-unconditional = Muhenkan
  '';

  # dconf 設定で IBus と Mozc のキーバインドを設定
  dconf.settings = {
    "desktop/ibus/general" = {
      preload-engines = [ "mozc-jp" ];
      use-system-keyboard-layout = true;
    };
    
    "desktop/ibus/general/hotkey" = {
      # 変換キー: Henkan で IME を有効化
      triggers = [ "Henkan_Mode" ];
    };
    
    # Mozc のキー設定
    "desktop/ibus/engine/Mozc/jp" = {
      # 直接入力モードから入力モードへの切り替え: 変換キー
      input-mode-activate = [ "Henkan_Mode" ];
      
      # 入力モードから直接入力モードへの切り替え: 無変換キー
      input-mode-deactivate = [ "Muhenkan" ];
    };
  };

  # Mozc の keymap 設定ファイル（config から読み込む）
  xdg.configFile."mozc/keymap.txt".source = ../../../config/mozc/keymap.txt;
}
