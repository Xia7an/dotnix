// ワークスペースを別のモニタへ移したとき (Option+文字 の summon / 入れ替え、モニタの取り外し)、
// そのワークスペースの floating ウィンドウを移動先のモニタの作業領域 (バーを除く) に収める。
// Hyprland はモニタの位置の差だけ平行移動するだけで、大きさの違うモニタでははみ出すため。
// 計算は placement.mjs の fitWorkspaceWindows (tests/aerogrid-model-test.mjs でテスト)。
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "placement.mjs" as Placement

Scope {
    id: root

    // ワークスペース ID → モニタ名。moveworkspacev2 には移動先しか無いので、移動元はここから引く。
    property var workspaceMonitors: ({})
    // 調整待ちの移動 [{ workspace, from, to }]。入れ替えでは 2 件続けて届くので、まとめて処理する。
    property var pending: []

    function refreshWorkspaces() {
        if (workspacesProc.running)
            workspacesProc.rerun = true;
        else
            workspacesProc.running = true;
    }

    function apply(monitors, clients) {
        const moves = root.pending;
        root.pending = [];
        for (const move of moves) {
            const newMonitor = monitors.find(m => m.name === move.to);
            if (!newMonitor)
                continue;
            const oldMonitor = monitors.find(m => m.name === move.from) ?? null;
            for (const { address, rect } of Placement.fitWorkspaceWindows(clients, move.workspace, oldMonitor, newMonitor)) {
                const target = `address:${address}`;
                // exact はレイアウト座標 (論理ピクセル) の絶対値。サイズを先に決めてから位置を合わせる。
                Hyprland.dispatch(`resizewindowpixel exact ${rect.width} ${rect.height},${target}`);
                Hyprland.dispatch(`movewindowpixel exact ${rect.x} ${rect.y},${target}`);
            }
        }
    }

    Process {
        id: workspacesProc
        property bool rerun: false
        command: ["hyprctl", "-j", "workspaces"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const map = {};
                    for (const ws of JSON.parse(text))
                        map[ws.id] = ws.monitor;
                    root.workspaceMonitors = map;
                } catch (e) {
                    console.warn(`aerogrid: hyprctl workspaces の解析に失敗: ${e}`);
                }
            }
        }
        onExited: {
            if (rerun) {
                rerun = false;
                running = true;
            }
        }
    }

    // 移動後のモニタとウィンドウの情報を 1 回で取る (区切りは RS 文字)。
    Process {
        id: stateProc
        property bool rerun: false
        command: ["sh", "-c", "hyprctl -j monitors; printf '\\036'; hyprctl -j clients"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const [monitors, clients] = text.split("\x1e").map(part => JSON.parse(part));
                    root.apply(monitors, clients);
                } catch (e) {
                    root.pending = [];
                    console.warn(`aerogrid: hyprctl monitors/clients の解析に失敗: ${e}`);
                }
            }
        }
        onExited: {
            if (rerun) {
                rerun = false;
                running = true;
            }
        }
    }

    // 同じイベントループで届いた移動 (入れ替えの 2 件) をまとめてから情報を取る。
    Timer {
        id: flush
        interval: 0
        onTriggered: {
            if (stateProc.running)
                stateProc.rerun = true;
            else
                stateProc.running = true;
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            switch (event.name) {
            case "moveworkspacev2": {
                // データは「ID,名前,モニタ名」。名前にカンマが入りうるので、ID は先頭、モニタ名は末尾から取る。
                const data = event.data;
                const workspace = Number(data.slice(0, data.indexOf(",")));
                const to = data.slice(data.lastIndexOf(",") + 1);
                const from = root.workspaceMonitors[workspace];
                const map = root.workspaceMonitors;
                map[workspace] = to;
                root.workspaceMonitors = map;
                if (from !== to) {
                    root.pending = root.pending.concat([{ workspace, from, to }]);
                    flush.restart();
                }
                break;
            }
            case "createworkspacev2":
            case "destroyworkspacev2":
            case "monitoradded":
            case "monitoraddedv2":
            case "configreloaded":
                root.refreshWorkspaces();
                break;
            }
        }
    }
}
