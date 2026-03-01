{ pkgs, lib, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      # fcitx5-skk
      fcitx5-gtk
    ];
  };
  xsession.initExtra = ''
    # Xwayland キーボード配列を JIS にする
    setxkbmap -layout jp -model jp106
  '';
  home.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    GTK_IM_MODULE = lib.mkForce "fcitx";
    QT_IM_MODULE = lib.mkForce "fcitx";
    GLFW_IM_MODULE = lib.mkForce "fcitx";
  };
  xdg.configFile."fcitx5/conf/waylandim.conf".text = ''
# 現在実行中のアプリケーションを検出する（再起動が必要）
DetectApplication=True
# キーイベントが処理されない場合、テキストをコミットする代わりにキーイベントを転送する
PreferKeyEvent=False
# V2 プロトコルの仮想キーボードオブジェクトを維持する (再起動が必要)
PersistentVirtualKeyboard=False
'';
}
