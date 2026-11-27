// Option+Tab: ワークスペース別のウィンドウグリッド (Hammerspoon 版 aerospace-window-grid の移植)。
//   h/l・左右: 同じワークスペース内の前後のウィンドウ    j/k・上下: 下/上のワークスペース
//   Option を離す: 選んだウィンドウにフォーカス (隠れていれば、そのワークスペースを元のモニタに表示)
//   Esc・外側のクリック: 何も変えずに閉じる
// 状態とレイアウトは model.mjs (tests/aerogrid-model-test.mjs でテスト)。
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "model.mjs" as Model

Scope {
    id: root

    property var session: null
    property int revision: 0 // session (ただの JS オブジェクト) を変えたら増やし、表示を更新する
    property ShellScreen targetScreen: Quickshell.screens[0]

    GlobalShortcut {
        appid: "aerogrid"
        name: "grid"
        description: "Window grid (Option+Tab)"
        // 表示中の Tab の押し直しや自動リピートでは何もしない。
        onPressed: if (!root.session) root.open()
    }

    function open() {
        const monitor = Hyprland.focusedMonitor;
        const screen = Quickshell.screens.find(s => s.name === monitor?.name) ?? Quickshell.screens[0];
        const windows = Hyprland.toplevels.values
            .filter(t => t.workspace?.name && !t.workspace.name.startsWith("special"))
            .map(t => ({ id: parseInt(t.address, 16), workspace: t.workspace.name, toplevel: t }));
        const active = Hyprland.activeToplevel;
        const s = Model.buildSession(windows, active ? parseInt(active.address, 16) : undefined);
        if (s.rows.length === 0)
            return;
        Model.layout(s, { x: 0, y: 0, width: screen.width, height: screen.height });
        Hyprland.refreshToplevels(); // アプリ名 (class) を最新にする
        targetScreen = screen;
        session = s;
        revision++;
    }

    function move(direction) {
        Model.move(session, direction);
        revision++;
    }

    function finish(commit) {
        const s = session;
        if (!s)
            return;
        session = null;
        revision++;
        const target = commit ? Model.selectedWindow(s) : null;
        if (target)
            Hyprland.dispatch(`focuswindow address:0x${target.toplevel.address}`);
    }

    PanelWindow {
        id: window
        visible: root.session !== null
        screen: root.targetScreen
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "aerogrid-grid"

        onVisibleChanged: if (visible) keys.forceActiveFocus()

        MouseArea {
            anchors.fill: parent
            onClicked: root.finish(false)
        }

        Item {
            id: keys
            anchors.fill: parent
            focus: true
            Keys.onPressed: event => {
                const directions = {
                    [Qt.Key_H]: "left", [Qt.Key_Left]: "left",
                    [Qt.Key_J]: "down", [Qt.Key_Down]: "down",
                    [Qt.Key_K]: "up", [Qt.Key_Up]: "up",
                    [Qt.Key_L]: "right", [Qt.Key_Right]: "right",
                };
                if (event.key === Qt.Key_Escape)
                    root.finish(false);
                else if (directions[event.key] && root.session)
                    root.move(directions[event.key]);
                event.accepted = true;
            }
            // Option (Alt) を離したら確定する。
            Keys.onReleased: event => {
                if (event.key === Qt.Key_Alt || event.key === Qt.Key_AltGr)
                    root.finish(true);
                event.accepted = true;
            }
        }

        Rectangle {
            id: popup
            // revision ごとに新しいオブジェクトにして、参照しているバインディングを確実に更新する。
            readonly property var s: { root.revision; return root.session ? Object.assign({}, root.session) : null; }
            visible: s !== null
            x: s?.x ?? 0
            y: s?.y ?? 0
            width: s?.width ?? 0
            height: s?.height ?? 0
            radius: 18
            color: Theme.popup

            MouseArea {
                anchors.fill: parent // 一覧の中のクリックでは閉じない
            }

            Text {
                x: popup.s?.text.title.x ?? 0
                y: popup.s?.text.title.y ?? 0
                width: popup.s?.text.title.width ?? 0
                text: popup.s ? `Windows   ·   ${popup.s.windowCount} windows / ${popup.s.rows.length} workspaces` : ""
                color: Theme.text
                font.pixelSize: 19
                elide: Text.ElideRight
            }
            Text {
                x: popup.s?.text.hint1.x ?? 0
                y: popup.s?.text.hint1.y ?? 0
                text: "h l  ウィンドウ    j k  ワークスペース"
                color: Theme.dim
                font.pixelSize: 12
            }
            Text {
                x: popup.s?.text.hint2.x ?? 0
                y: popup.s?.text.hint2.y ?? 0
                text: "⌥ を離すと確定 · Esc 取消"
                color: Theme.dim
                font.pixelSize: 12
            }
            Text {
                readonly property int last: popup.s ? Model.lastVisibleRow(popup.s) : 0
                x: popup.s?.text.range.x ?? 0
                y: popup.s?.text.range.y ?? 0
                width: popup.s?.text.range.width ?? 0
                horizontalAlignment: Text.AlignRight
                text: popup.s ? `${popup.s.firstRow > 0 ? "↑ " : ""}${popup.s.firstRow + 1}–${last + 1} / ${popup.s.rows.length}`
                    + `${last < popup.s.rows.length - 1 ? " ↓" : ""}` : ""
                color: Theme.dim
                font.pixelSize: 12
            }

            // 行見出し: ワークスペース名、表示範囲、横スクロールの矢印
            Repeater {
                model: popup.s ? Model.visibleRows(popup.s) : []
                Item {
                    id: rowLabel
                    required property var modelData
                    readonly property bool selected: modelData.rowIndex === popup.s.selectedRow
                    readonly property color tint: selected ? Theme.accent : Theme.dim
                    y: modelData.y
                    Text {
                        x: popup.s.rowText.name.x
                        y: popup.s.rowText.name.y
                        width: popup.s.rowText.name.width
                        text: rowLabel.modelData.row.name
                        color: rowLabel.tint
                        font.pixelSize: 18
                        elide: Text.ElideRight
                    }
                    Text {
                        x: popup.s.rowText.range.x
                        y: popup.s.rowText.range.y
                        text: `${rowLabel.modelData.row.first + 1}–${rowLabel.modelData.last + 1}/${rowLabel.modelData.row.windows.length}`
                        color: rowLabel.tint
                        font.pixelSize: 11
                    }
                    Text {
                        x: popup.s.rowText.arrow.x
                        y: popup.s.rowText.arrow.y
                        text: `${rowLabel.modelData.row.first > 0 ? "← " : ""}${rowLabel.modelData.last < rowLabel.modelData.row.windows.length - 1 ? "→" : ""}`
                        color: rowLabel.tint
                        font.pixelSize: 14
                    }
                }
            }

            Repeater {
                model: popup.s ? Model.visibleCards(popup.s) : []
                WindowCard {
                    required property var modelData
                    toplevel: modelData.window.toplevel
                    selected: modelData.selected
                    x: modelData.x
                    y: modelData.y
                    width: popup.s.cardWidth
                    height: popup.s.cardHeight
                }
            }
        }
    }
}
