// 配色 (Hammerspoon 版グリッドと同じ)。
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property color accent: "#66b3ff"
    readonly property color popup: Qt.rgba(0.07, 0.07, 0.07, 0.97)
    readonly property color card: "#1f1f1f"
    readonly property color cardSelected: "#303030"
    readonly property color cardBorder: "#3d3d3d"
    readonly property color text: "#f2f2f2"
    readonly property color dim: "#a6a6a6"
    readonly property color faint: Qt.rgba(1, 1, 1, 0.45)
    readonly property color onAccent: "#121212"
}
