// AeroGrid: noctalia に無い機能だけを Quickshell で補う。
//   WindowGrid      Option+Tab: ワークスペース別のウィンドウグリッド (Hammerspoon 版の移植)
//   WindowPlacement Option+Control+hjkl/Space: ウィンドウ配置 (Raycast 相当)
//   WorkspaceFit    ワークスペースを別のモニタへ移したとき、ウィンドウをそのモニタに収める
// バー・ランチャー・通知・Command+Tab などは noctalia (config/noctalia/config.toml)。
// キーは config/hypr/aerogrid/keybinds.conf の `global, aerogrid:*` で受け取る。
// 起動: qs -c aerogrid (Hyprland の exec-once)。変更は home-manager switch で反映される。
import Quickshell

ShellRoot {
    WindowGrid {}
    WindowPlacement {}
    WorkspaceFit {}
}
