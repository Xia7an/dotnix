// モニタごとの上部バー。
//   左: ワークスペース。このモニタに表示中のものを塗りつぶし (操作中のモニタなら青、そうでなければ灰)、
//       別のモニタに表示中のものを枠、隠れているがウィンドウがあるものを薄い文字で示す。
//       クリックすると、そのワークスペースをこのモニタに呼ぶ。
//   中央: このモニタでフォーカス中のウィンドウのタイトル
//   右: システムトレイと時計
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "model.mjs" as Model

PanelWindow {
    id: bar
    required property ShellScreen modelData
    screen: modelData

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)
    readonly property bool focusedMonitor: Hyprland.focusedMonitor === monitor

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 30
    color: Theme.bar

    // ウィンドウがあるか、どこかのモニタに表示中のワークスペースを、数字 → 名前の順で並べる。
    readonly property var workspaces: Hyprland.workspaces.values
        .filter(ws => ws.name && !ws.name.startsWith("special"))
        .filter(ws => ws.toplevels.values.length > 0 || ws.monitor?.activeWorkspace === ws)
        .sort((a, b) => Model.compareWorkspaceNames(a.name, b.name))

    function stateOf(ws) {
        if (ws.monitor === monitor && monitor?.activeWorkspace === ws)
            return "here";
        if (ws.monitor?.activeWorkspace === ws)
            return "elsewhere";
        return "hidden";
    }

    function summon(ws) {
        const target = /^\d+$/.test(ws.name) ? ws.name : `name:${ws.name}`;
        Hyprland.dispatch(`focusmonitor ${monitor.name}`);
        Hyprland.dispatch(`focusworkspaceoncurrentmonitor ${target}`);
    }

    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: bar.workspaces
            Rectangle {
                id: chip
                required property HyprlandWorkspace modelData
                readonly property string state_: bar.stateOf(modelData)
                implicitWidth: Math.max(22, label.implicitWidth + 12)
                implicitHeight: 22
                radius: 6
                color: state_ === "here" ? (bar.focusedMonitor ? Theme.accent : Theme.dim) : "transparent"
                border.width: state_ === "elsewhere" ? 1 : 0
                border.color: Theme.accent

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: chip.modelData.name
                    font.pixelSize: 13
                    font.bold: true
                    color: chip.state_ === "here" ? Theme.onAccent
                        : chip.state_ === "elsewhere" ? Theme.accent : Theme.faint
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bar.summon(chip.modelData)
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        width: Math.min(implicitWidth, parent.width * 0.4)
        readonly property var active: Hyprland.activeToplevel
        text: active && active.monitor === bar.monitor ? active.title : ""
        color: Theme.text
        font.pixelSize: 13
        elide: Text.ElideRight
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Repeater {
            model: SystemTray.items
            IconImage {
                id: trayIcon
                required property SystemTrayItem modelData
                implicitSize: 18
                source: modelData.icon
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton && !trayIcon.modelData.onlyMenu)
                            trayIcon.modelData.activate();
                        else if (trayIcon.modelData.hasMenu)
                            trayIcon.modelData.display(bar, bar.mapFromItem(trayIcon, 0, 0).x, bar.height);
                    }
                }
            }
        }

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }
        Text {
            // Lachesis のメニューバーと同じく曜日と秒まで表示する。
            text: clock.date.toLocaleString(Qt.locale("ja_JP"), "M/d(ddd) H:mm:ss")
            color: Theme.text
            font.pixelSize: 13
        }
    }
}
