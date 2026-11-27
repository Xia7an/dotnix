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
    // Repeater のモデル。セッション中は変えない: 移動のたびに作り直すと全カードが作り直され、
    // プレビュー (ScreencopyView) を取り直す間ちらついたり真っ暗になったりする。
    property var cards: []
    property var rows: []
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
        cards = Model.allCards(s);
        rows = s.rows.map((row, rowIndex) => ({ rowIndex }));
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
        cards = [];
        rows = [];
        const target = commit ? Model.selectedWindow(s) : null;
        // グリッド (キーボードを独占するレイヤー) が表示中だと Hyprland はフォーカスの移動を拒否するので、
        // レイヤーが閉じてから (closelayer イベント) 移す。イベントを取り逃したときは Timer で移す。
        pendingFocus = target ? target.toplevel.address : "";
        if (pendingFocus)
            focusFallback.restart();
    }

    property string pendingFocus: ""

    function focusPending() {
        const address = pendingFocus;
        pendingFocus = "";
        focusFallback.stop();
        if (!address)
            return;
        Hyprland.dispatch(`focuswindow address:0x${address}`);
        // focuswindow は (フルスクリーン時を除き) floating ウィンドウを前面に出さない。
        // すべて floating なので、同じワークスペース内では選んだウィンドウが後ろに隠れたままになる。
        Hyprland.dispatch(`alterzorder top,address:0x${address}`);
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "closelayer" && event.data === "aerogrid-grid")
                root.focusPending();
        }
    }

    Timer {
        id: focusFallback
        interval: 300
        onTriggered: root.focusPending()
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
                model: root.rows
                Item {
                    id: rowLabel
                    required property var modelData
                    // popup.s は revision ごとに変わるので、row.first などの変化もここで拾える。
                    readonly property var row: popup.s?.rows[modelData.rowIndex] ?? null
                    readonly property var st: popup.s ? Model.rowState(popup.s, modelData.rowIndex) : null
                    readonly property bool selected: modelData.rowIndex === popup.s?.selectedRow
                    readonly property color tint: selected ? Theme.accent : Theme.dim
                    visible: (st?.visible ?? false) && row !== null
                    y: st?.y ?? 0
                    Text {
                        x: popup.s?.rowText.name.x ?? 0
                        y: popup.s?.rowText.name.y ?? 0
                        width: popup.s?.rowText.name.width ?? 0
                        text: rowLabel.row?.name ?? ""
                        color: rowLabel.tint
                        font.pixelSize: 18
                        elide: Text.ElideRight
                    }
                    Text {
                        x: popup.s?.rowText.range.x ?? 0
                        y: popup.s?.rowText.range.y ?? 0
                        text: rowLabel.row ? `${rowLabel.row.first + 1}–${rowLabel.st.last + 1}/${rowLabel.row.windows.length}` : ""
                        color: rowLabel.tint
                        font.pixelSize: 11
                    }
                    Text {
                        x: popup.s?.rowText.arrow.x ?? 0
                        y: popup.s?.rowText.arrow.y ?? 0
                        text: rowLabel.row ? `${rowLabel.row.first > 0 ? "← " : ""}${rowLabel.st.last < rowLabel.row.windows.length - 1 ? "→" : ""}` : ""
                        color: rowLabel.tint
                        font.pixelSize: 14
                    }
                }
            }

            // カードはセッション中ずっと同じもの (root.cards) を使い、位置・表示・選択だけ更新する。
            Repeater {
                model: root.cards
                WindowCard {
                    required property var modelData
                    readonly property var st: popup.s ? Model.cardState(popup.s, modelData.rowIndex, modelData.index) : null
                    toplevel: modelData.window.toplevel
                    visible: st?.visible ?? false
                    selected: st?.selected ?? false
                    x: st?.x ?? 0
                    y: st?.y ?? 0
                    width: popup.s?.cardWidth ?? 0
                    height: popup.s?.cardHeight ?? 0
                }
            }
        }
    }
}
