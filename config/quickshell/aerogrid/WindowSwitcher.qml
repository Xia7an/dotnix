// Command+Tab: 最近使った順のウィンドウスイッチャー (Lachesis の alt-tab-macos 相当)。
// 全ワークスペースのウィンドウが対象。Command+Tab で次、Command+Shift+Tab で前、
// 左右キーでも移動。Command を離すと選んだウィンドウにフォーカス、Esc で取消。
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    id: root

    property var mru: [] // 最近フォーカスした順のアドレス
    property var items: []
    property int index: 0
    property bool opened: false
    property ShellScreen targetScreen: Quickshell.screens[0]

    // フォーカスが移るたびに先頭へ。起動直後は Hyprland の focusHistoryID で並べる。
    Connections {
        target: Hyprland
        function onActiveToplevelChanged() {
            const address = Hyprland.activeToplevel?.address;
            if (address)
                root.mru = [address, ...root.mru.filter(a => a !== address)];
        }
    }
    Timer {
        interval: 1500
        running: true
        onTriggered: {
            const known = Hyprland.toplevels.values
                .filter(t => t.lastIpcObject?.focusHistoryID !== undefined)
                .sort((a, b) => a.lastIpcObject.focusHistoryID - b.lastIpcObject.focusHistoryID)
                .map(t => t.address);
            root.mru = [...root.mru, ...known.filter(a => !root.mru.includes(a))];
        }
    }

    GlobalShortcut {
        appid: "aerogrid"
        name: "switcher"
        description: "Window switcher (Command+Tab)"
        onPressed: root.opened ? root.step(1) : root.open(1)
    }
    GlobalShortcut {
        appid: "aerogrid"
        name: "switcher-back"
        description: "Window switcher backwards (Command+Shift+Tab)"
        onPressed: root.opened ? root.step(-1) : root.open(-1)
    }

    function open(direction) {
        const order = address => {
            const i = mru.indexOf(address);
            return i < 0 ? Number.MAX_SAFE_INTEGER : i;
        };
        const list = Hyprland.toplevels.values
            .filter(t => t.workspace?.name && !t.workspace.name.startsWith("special"))
            .sort((a, b) => order(a.address) - order(b.address));
        if (list.length === 0)
            return;
        mru = mru.filter(a => list.some(t => t.address === a)); // 閉じたウィンドウを忘れる
        const monitor = Hyprland.focusedMonitor;
        targetScreen = Quickshell.screens.find(s => s.name === monitor?.name) ?? Quickshell.screens[0];
        items = list;
        // 1 回目の Command+Tab で 2 番目 (直前に使ったウィンドウ) を選ぶ。
        index = list.length > 1 ? (direction > 0 ? 1 : list.length - 1) : 0;
        Hyprland.refreshToplevels();
        opened = true;
    }

    function step(delta) {
        if (items.length > 0)
            index = (index + delta + items.length) % items.length;
    }

    function finish(commit) {
        if (!opened)
            return;
        opened = false;
        const target = commit ? items[index] : null;
        items = [];
        if (target)
            Hyprland.dispatch(`focuswindow address:0x${target.address}`);
    }

    PanelWindow {
        visible: root.opened
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
        WlrLayershell.namespace: "aerogrid-switcher"

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
                if (event.key === Qt.Key_Escape)
                    root.finish(false);
                else if (event.key === Qt.Key_Right || event.key === Qt.Key_L)
                    root.step(1);
                else if (event.key === Qt.Key_Left || event.key === Qt.Key_H)
                    root.step(-1);
                event.accepted = true;
            }
            // Command (Super) を離したら確定する。
            Keys.onReleased: event => {
                if (event.key === Qt.Key_Super_L || event.key === Qt.Key_Super_R || event.key === Qt.Key_Meta)
                    root.finish(true);
                event.accepted = true;
            }
        }

        Rectangle {
            id: popup
            readonly property int cardWidth: 220
            readonly property int cardHeight: 170
            readonly property int visibleCount: Math.max(1, Math.min(root.items.length,
                Math.floor((parent.width - 96) / (cardWidth + 12))))
            // 選択が見えるように、表示する範囲を選択に追従させる。
            readonly property int first: Math.max(0, Math.min(root.index - Math.floor(visibleCount / 2),
                root.items.length - visibleCount))

            anchors.centerIn: parent
            width: visibleCount * (cardWidth + 12) - 12 + 48
            height: cardHeight + 48
            radius: 18
            color: Theme.popup

            MouseArea {
                anchors.fill: parent
            }

            Row {
                x: 24
                y: 24
                spacing: 12
                Repeater {
                    model: root.items.slice(popup.first, popup.first + popup.visibleCount)
                    WindowCard {
                        required property var modelData
                        required property int index
                        toplevel: modelData
                        selected: popup.first + index === root.index
                        width: popup.cardWidth
                        height: popup.cardHeight
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.index = popup.first + parent.index;
                                root.finish(true);
                            }
                        }
                    }
                }
            }
        }
    }
}
