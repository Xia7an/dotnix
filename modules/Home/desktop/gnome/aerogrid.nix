# AeroGrid (GNOME Shell 拡張) を配置して有効にする。
# 拡張はリポジトリのファイルへ直接リンクするので、編集後は switch せず
# Alt+F2 → r (X11) で GNOME Shell を再起動するだけで反映される。
{ config, lib, ... }:
let
  source = "${config.home.homeDirectory}/Gits/dotnix/config/gnome-shell/aerogrid";
  inherit (lib.importJSON ../../../../config/gnome-shell/aerogrid/metadata.json) uuid;
in
{
  xdg.dataFile."gnome-shell/extensions/${uuid}".source =
    config.lib.file.mkOutOfStoreSymlink source;

  dconf.settings."org/gnome/shell" = {
    disable-user-extensions = false;
    # Home Manager はこの一覧を丸ごと置き換える。Ubuntu Dock などの標準拡張は
    # セッションモード側で有効になるので不要だが、手動で入れた拡張はここに追加する。
    enabled-extensions = [ uuid ];
  };
}
