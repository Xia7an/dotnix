// グリッドの純粋な状態管理 (Hammerspoon 版 aerospace-window-grid.lua の移植)。
// GNOME の API に依存しないので Node でテストできる (tests/gnome-aerogrid-model-test.mjs)。
// インデックスはすべて 0 始まり。

export const MAX_COLUMNS = 4;
export const MAX_ROWS = 6;

// 数字だけの名前を数値順 (2 < 10) で先に、残りを名前順で並べる。
export function compareWorkspaceNames(a, b) {
    const an = /^\d+$/.test(a) ? Number(a) : null;
    const bn = /^\d+$/.test(b) ? Number(b) : null;
    if (an !== null && bn !== null && an !== bn)
        return an - bn;
    if ((an === null) !== (bn === null))
        return an !== null ? -1 : 1;
    return a < b ? -1 : a > b ? 1 : 0;
}

// windows: [{ id: number, workspace: string, ... }]
// 空のワークスペースは行にしない。行内は id 順。
// 初期選択はフォーカス中のウィンドウ (無ければ先頭行の先頭)。
export function buildSession(windows, focusedId) {
    const byWorkspace = new Map();
    const seen = new Set();
    let windowCount = 0;
    for (const window of windows) {
        if (typeof window.id !== 'number' || typeof window.workspace !== 'string' || seen.has(window.id))
            continue;
        seen.add(window.id);
        if (!byWorkspace.has(window.workspace))
            byWorkspace.set(window.workspace, { name: window.workspace, windows: [], selected: 0, first: 0 });
        byWorkspace.get(window.workspace).windows.push(window);
        windowCount++;
    }
    const rows = [...byWorkspace.values()].sort((a, b) => compareWorkspaceNames(a.name, b.name));
    let selectedRow = 0;
    rows.forEach((row, rowIndex) => {
        row.windows.sort((a, b) => a.id - b.id);
        const index = row.windows.findIndex(w => w.id === focusedId);
        if (index >= 0) {
            selectedRow = rowIndex;
            row.selected = index;
        }
    });
    return { rows, selectedRow, firstRow: 0, windowCount };
}

// frame: 表示先モニタの作業領域 { x, y, width, height }。カードを画面に合わせて縮める。
export function layout(session, frame) {
    const s = session;
    const maxWindows = Math.max(1, ...s.rows.map(r => r.windows.length));
    s.columns = Math.min(maxWindows, MAX_COLUMNS);
    s.visibleRows = Math.min(s.rows.length, MAX_ROWS);
    s.cardWidth = Math.floor(Math.min(300, (frame.width - 180) / s.columns - 12));
    s.rowHeight = Math.floor(Math.min(232, (frame.height - 164) / s.visibleRows));
    s.cardHeight = s.rowHeight - 12;
    s.width = 132 + s.columns * (s.cardWidth + 12) - 12;
    s.height = 124 + s.visibleRows * s.rowHeight - 12;
    s.x = Math.floor(frame.x + (frame.width - s.width) / 2);
    s.y = Math.floor(frame.y + (frame.height - s.height) / 2);
    reveal(s);
    return s;
}

// 選択が表示範囲に入るよう 1 項目ずつ追従させる (ページ送りや折り返しはしない)。
// 横スクロールは行ごとに独立している。
export function reveal(s) {
    s.firstRow = Math.max(s.selectedRow - s.visibleRows + 1, Math.min(s.firstRow, s.selectedRow));
    const row = s.rows[s.selectedRow];
    row.first = Math.max(row.selected - s.columns + 1, Math.min(row.first, row.selected));
}

export function move(s, direction) {
    const row = s.rows[s.selectedRow];
    if (direction === 'left')
        row.selected = Math.max(0, row.selected - 1);
    else if (direction === 'right')
        row.selected = Math.min(row.windows.length - 1, row.selected + 1);
    else if (direction === 'up')
        s.selectedRow = Math.max(0, s.selectedRow - 1);
    else if (direction === 'down')
        s.selectedRow = Math.min(s.rows.length - 1, s.selectedRow + 1);
    reveal(s);
}

export function selectedWindow(s) {
    const row = s.rows[s.selectedRow];
    return row ? row.windows[row.selected] : undefined;
}

export function lastVisibleRow(s) {
    return Math.min(s.rows.length, s.firstRow + s.visibleRows) - 1;
}

// 表示中の行: [{ row, rowIndex, y, last }] (座標はポップアップ内)。
export function visibleRows(s) {
    const result = [];
    for (let rowIndex = s.firstRow; rowIndex <= lastVisibleRow(s); rowIndex++) {
        const row = s.rows[rowIndex];
        result.push({
            row, rowIndex,
            y: 56 + (rowIndex - s.firstRow) * s.rowHeight,
            last: Math.min(row.windows.length, row.first + s.columns) - 1,
        });
    }
    return result;
}

// 表示中のカード: [{ window, rowIndex, index, x, y, selected }]。
export function visibleCards(s) {
    const cards = [];
    for (const { row, rowIndex, y, last } of visibleRows(s)) {
        for (let index = row.first; index <= last; index++) {
            cards.push({
                window: row.windows[index], rowIndex, index,
                x: 112 + (index - row.first) * (s.cardWidth + 12), y,
                selected: rowIndex === s.selectedRow && index === row.selected,
            });
        }
    }
    return cards;
}
