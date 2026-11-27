// Option+Control+hjkl/Space: フォーカス中のウィンドウを、そのモニタの作業領域 (バーを除く) の
// 左/下/上/右半分、または全体に合わせる (Lachesis の Raycast Window Management と同じキー)。
// 計算は placement.mjs (tests/aerogrid-model-test.mjs でテスト)。
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "placement.mjs" as Placement

Scope {
    id: root

    function place(kind) {
        const toplevel = Hyprland.activeToplevel;
        const monitor = toplevel?.monitor ?? Hyprland.focusedMonitor;
        const info = monitor?.lastIpcObject;
        // 次回のためにモニタ情報 (バーが確保した領域を含む) を更新しておく。
        Hyprland.refreshMonitors();
        // 全画面のウィンドウは Hyprland が移動を受け付けないので、そのままにする。
        if (!toplevel || !info || info.width === undefined || toplevel.lastIpcObject?.fullscreen)
            return;
        const rect = Placement.placementRect(Placement.workArea(info), kind);
        const address = `address:0x${toplevel.address}`;
        // exact はレイアウト座標 (論理ピクセル) の絶対値。サイズを先に決めてから位置を合わせる。
        Hyprland.dispatch(`resizewindowpixel exact ${rect.width} ${rect.height},${address}`);
        Hyprland.dispatch(`movewindowpixel exact ${rect.x} ${rect.y},${address}`);
    }

    Variants {
        model: [
            { name: "left-half", description: "Left half (Option+Control+H)" },
            { name: "right-half", description: "Right half (Option+Control+L)" },
            { name: "top-half", description: "Top half (Option+Control+K)" },
            { name: "bottom-half", description: "Bottom half (Option+Control+J)" },
            { name: "maximize", description: "Fill the work area (Option+Control+Space)" },
        ]
        GlobalShortcut {
            required property var modelData
            appid: "aerogrid"
            name: modelData.name
            description: modelData.description
            onPressed: root.place(modelData.name)
        }
    }

    // バーができて作業領域が確定した後と、モニタ構成が変わったときに情報を取り直す。
    Timer {
        interval: 2000
        running: true
        onTriggered: Hyprland.refreshMonitors()
    }
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (["monitoradded", "monitoraddedv2", "monitorremoved", "configreloaded"].includes(event.name))
                Hyprland.refreshMonitors();
        }
    }
}
