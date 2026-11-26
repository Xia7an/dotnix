# macOS の Dock (下・自動で隠す) に合わせる。Ubuntu Dock は dash-to-dock のスキーマを使う。
{
  dconf.settings."org/gnome/shell/extensions/dash-to-dock" = {
    dock-position = "BOTTOM";
    dock-fixed = false;
    autohide = true;
    intellihide = true;
    extend-height = false;
  };
}
