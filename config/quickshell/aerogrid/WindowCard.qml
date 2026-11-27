// グリッドで使うウィンドウのカード: プレビュー、アプリ名、タイトル。
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

Rectangle {
    id: card
    required property HyprlandToplevel toplevel
    property bool selected: false
    property real uiScale: 1

    readonly property string appClass: toplevel?.lastIpcObject?.class ?? ""
    readonly property var entry: appClass ? DesktopEntries.heuristicLookup(appClass) : null

    radius: 10 * uiScale
    color: selected ? Theme.cardSelected : Theme.card
    border.width: (selected ? 3 : 1) * uiScale
    border.color: selected ? Theme.accent : Theme.cardBorder

    // 上端 6 / プレビュー / 2 / アプリ名 18 / タイトル 20 / 下端 3 (model.mjs の cardText と同じ)
    Item {
        id: previewArea
        x: 8 * card.uiScale
        y: 6 * card.uiScale
        width: card.width - 16 * card.uiScale
        height: Math.max(1, card.height - 49 * card.uiScale)

        // 別のワークスペースのウィンドウも、最後に描画された内容を取得できる。
        // 初めて表示されたときに 1 回だけ取得し、スクロールで隠れても破棄しない
        // (captureSource を外すと、再表示のたびに取り直してちらつく)。
        property bool shown: false
        Component.onCompleted: if (card.visible) shown = true
        Connections {
            target: card
            function onVisibleChanged() { if (card.visible) previewArea.shown = true; }
        }
        ScreencopyView {
            id: preview
            anchors.centerIn: parent
            captureSource: previewArea.shown ? (card.toplevel?.wayland ?? null) : null
            live: false
            constraintSize: Qt.size(previewArea.width, previewArea.height)
            width: implicitWidth
            height: implicitHeight
        }
        IconImage {
            visible: !preview.hasContent
            anchors.centerIn: parent
            implicitSize: Math.min(64 * card.uiScale, parent.height)
            source: Quickshell.iconPath(card.entry?.icon ?? "", "application-x-executable")
        }
    }
    Text {
        x: 10 * card.uiScale
        y: card.height - 41 * card.uiScale
        width: card.width - 20 * card.uiScale
        text: card.entry?.name ?? card.appClass
        color: Theme.dim
        font.pixelSize: 11 * card.uiScale
        elide: Text.ElideRight
    }
    Text {
        x: 10 * card.uiScale
        y: card.height - 23 * card.uiScale
        width: card.width - 20 * card.uiScale
        text: (card.toplevel?.title ?? "").replace(/\s+/g, " ")
        color: Theme.text
        font.pixelSize: 12 * card.uiScale
        elide: Text.ElideRight
    }
}
