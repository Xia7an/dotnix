// グリッドとスイッチャーで使うウィンドウのカード: プレビュー、アプリ名、タイトル。
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

Rectangle {
    id: card
    required property HyprlandToplevel toplevel
    property bool selected: false
    property real scale: 1

    readonly property string appClass: toplevel?.lastIpcObject?.class ?? ""
    readonly property var entry: appClass ? DesktopEntries.heuristicLookup(appClass) : null

    radius: 10 * scale
    color: selected ? Theme.cardSelected : Theme.card
    border.width: (selected ? 3 : 1) * scale
    border.color: selected ? Theme.accent : Theme.cardBorder

    // 上端 6 / プレビュー / 2 / アプリ名 18 / タイトル 20 / 下端 3 (model.mjs の cardText と同じ)
    Item {
        id: previewArea
        x: 8 * card.scale
        y: 6 * card.scale
        width: card.width - 16 * card.scale
        height: Math.max(1, card.height - 49 * card.scale)

        // 別のワークスペースのウィンドウも、最後に描画された内容を取得できる。
        ScreencopyView {
            id: preview
            anchors.centerIn: parent
            captureSource: card.toplevel?.wayland ?? null
            live: false
            constraintSize: Qt.size(previewArea.width, previewArea.height)
            width: implicitWidth
            height: implicitHeight
        }
        IconImage {
            visible: !preview.hasContent
            anchors.centerIn: parent
            implicitSize: Math.min(64 * card.scale, parent.height)
            source: Quickshell.iconPath(card.entry?.icon ?? "", "application-x-executable")
        }
    }
    Text {
        x: 10 * card.scale
        y: card.height - 41 * card.scale
        width: card.width - 20 * card.scale
        text: card.entry?.name ?? card.appClass
        color: Theme.dim
        font.pixelSize: 11 * card.scale
        elide: Text.ElideRight
    }
    Text {
        x: 10 * card.scale
        y: card.height - 23 * card.scale
        width: card.width - 20 * card.scale
        text: (card.toplevel?.title ?? "").replace(/\s+/g, " ")
        color: Theme.text
        font.pixelSize: 12 * card.scale
        elide: Text.ElideRight
    }
}
