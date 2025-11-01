{ pkgs, lib, ... }:
{
  # Waylandセッションに必要なもの（例: HyprlandやGnomeなどを使う前提）
  services.dbus.enable = true;

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc];
  };

  # XKB設定（Waylandでもキーマップに影響）
  services.xserver = {
    layout = "jp";
    xkbVariant = "";
  };

}
