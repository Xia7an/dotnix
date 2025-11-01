{pkgs, ...}: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };
  i18n.inputMethod.fcitx5.waylandFrontend = true;

  # Electron アプリ (Discord, VSCode など) で Fcitx5 を使うための環境変数
  environment.sessionVariables = {
    # Fcitx5 の基本設定
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    
    # Electron/Chromium アプリで IME を有効化
    GLFW_IM_MODULE = "ibus"; # GLFW ベースのアプリ用
    
    # Wayland 環境での IME サポート
    SDL_IM_MODULE = "fcitx";
  };

  # Electron フラグを設定して IME サポートを有効化
  environment.etc."electron-flags.conf".text = ''
    --enable-wayland-ime
    --wayland-text-input-version=3
  '';

  environment.etc."electron25-flags.conf".text = ''
    --enable-wayland-ime
    --wayland-text-input-version=3
  '';

  environment.etc."code-flags.conf".text = ''
    --enable-wayland-ime
    --wayland-text-input-version=3
  '';
}

