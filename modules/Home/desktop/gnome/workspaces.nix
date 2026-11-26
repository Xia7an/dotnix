# AeroSpace と同じく固定数のワークスペースを全モニタ共通で使う。
# 数と名前は AeroGrid 拡張が config/gnome-shell/aerogrid/config.js から設定する。
{
  dconf.settings."org/gnome/mutter" = {
    dynamic-workspaces = false;
    # true だとサブモニタのウィンドウが全ワークスペースに出て、アプリの割り当てが効かない。
    workspaces-only-on-primary = false;
  };
}
