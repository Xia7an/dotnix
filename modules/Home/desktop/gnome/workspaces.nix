# AeroSpace と同じく、GNOME (Mutter) のワークスペースは 1 つだけにして、
# 32 個のワークスペースは AeroGrid 拡張が仮想的に管理する (モニタごとに別々に表示するため)。
# 拡張も起動時に同じ値へそろえるが、拡張が読み込まれる前の状態も合わせておく。
{
  dconf.settings = {
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = false;
    };
    "org/gnome/desktop/wm/preferences".num-workspaces = 1;
  };
}
