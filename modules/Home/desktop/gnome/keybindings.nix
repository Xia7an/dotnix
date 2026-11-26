# Magic Keyboard では Option = Alt、Command = Super。macOS と同じ物理キーで操作する:
#   Option+Tab           → AeroGrid のグリッド (Hammerspoon 版の代わり)
#   Option+文字          → AeroGrid のワークスペース切り替え
#   Command+Tab          → GNOME のウィンドウスイッチャー (alt-tab-macos の代わり)
#   Command+`            → 同じアプリのウィンドウ切り替え
#   Option+Control+hjkl/Space → AeroGrid のウィンドウ配置 (Raycast の代わり)
# GNOME 既定の Alt+Tab / Alt+` を外し、拡張がキーを掴めるようにする。
{ lib, ... }:
let
  inherit (lib.hm.gvariant) mkEmptyArray type;
  none = mkEmptyArray type.string;
in
{
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = none;
      switch-applications-backward = none;
      switch-windows = [ "<Super>Tab" ];
      switch-windows-backward = [ "<Shift><Super>Tab" ];
      switch-group = [ "<Super>Above_Tab" ];
      switch-group-backward = [ "<Shift><Super>Above_Tab" ];
    };

    # 画面ロックは Super+L (Command+L) だけにし、Ctrl+Alt+L を AeroGrid に空ける。
    "org/gnome/settings-daemon/plugins/media-keys".screensaver = [ "<Super>l" ];

    # alt-tab-macos と同じく全ワークスペースのウィンドウを対象にする。
    "org/gnome/shell/window-switcher".current-workspace-only = false;
    "org/gnome/shell/app-switcher".current-workspace-only = false;
  };
}
