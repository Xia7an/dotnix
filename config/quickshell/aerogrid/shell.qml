// AeroGrid: Hyprland 上で Lachesis のデスクトップを再現する Quickshell 設定。
//   Bar             モニタごとの上部バー (そのモニタのワークスペース、タイトル、トレイ、時計)
//   WindowGrid      Option+Tab: ワークスペース別のウィンドウグリッド (Hammerspoon 版の移植)
//   WindowSwitcher  Command+Tab: 最近使った順のウィンドウスイッチャー (alt-tab-macos 相当)
//   WindowPlacement Option+Control+hjkl/Space: ウィンドウ配置 (Raycast 相当)
// キーは config/hypr/aerogrid/keybinds.conf の `global, aerogrid:*` で受け取る。
// 起動: qs -c aerogrid (Hyprland の exec-once)。ファイルを保存すると自動で再読込される。
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }
    WindowGrid {}
    WindowSwitcher {}
    WindowPlacement {}
}
