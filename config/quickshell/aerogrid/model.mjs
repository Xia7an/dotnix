// Option+Tab グリッドの状態管理 (Hammerspoon 版 aerospace-window-grid.lua の移植)。
// Quickshell に依存しないので Node でテストできる (tests/aerogrid-model-test.mjs)。
// インデックスはすべて 0 始まり。座標は論理ピクセル。

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

// 文字の高さと倍率。既定値は Hammerspoon 版と同じ寸法 (WindowGrid.qml はこれを使う)。
export const DEFAULT_METRICS = {
    scale: 1, // St の scale_factor (HiDPI で 2 など)
    title: 28, hint: 24,
    rowName: 26, rowSmall: 22, rowArrow: 22,
    app: 18, cardTitle: 20,
};

// frame: 表示先モニタの領域 { x, y, width, height }。
// 余白は scale 倍し、文字の領域は metrics の高さで確保するので、文字が枠からはみ出さない。
export function layout(session, frame, metrics = DEFAULT_METRICS) {
    const s = session;
    // Qt の JavaScript エンジンはオブジェクトのスプレッド構文に対応していないので Object.assign を使う。
    const m = Object.assign({}, DEFAULT_METRICS, metrics);
    const k = m.scale;
    const gap = 12 * k;
    s.metrics = m;
    s.gap = gap;

    const maxWindows = Math.max(1, ...s.rows.map(r => r.windows.length));
    s.columns = Math.min(maxWindows, MAX_COLUMNS);
    s.visibleRows = Math.min(s.rows.length, MAX_ROWS);

    s.rowsTop = 16 * k + m.title + gap;
    s.cardsLeft = 32 * k + Math.max(80 * k, m.rowName * 2);
    const footer = gap + 2 * m.hint + 8 * k;
    const right = 20 * k;

    // カード内: 上端 6 / プレビュー / 2 / アプリ名 / タイトル / 下端 3
    const cardText = m.app + m.cardTitle + 3 * k;
    const minCardHeight = 6 * k + 24 * k + 2 * k + cardText;
    const rowLabels = 12 * k + m.rowName + 2 * k + m.rowSmall + m.rowArrow;
    const minRow = Math.max(minCardHeight + gap, rowLabels);

    s.cardWidth = Math.floor(Math.max(80 * k,
        Math.min(300 * k, (frame.width - s.cardsLeft - right - 48 * k) / s.columns - gap)));
    s.rowHeight = Math.floor(Math.max(minRow,
        Math.min(232 * k, (frame.height - s.rowsTop - footer - 40 * k) / s.visibleRows)));
    s.cardHeight = s.rowHeight - gap;
    s.width = Math.ceil(s.cardsLeft + s.columns * (s.cardWidth + gap) - gap + right);
    s.height = Math.ceil(s.rowsTop + s.visibleRows * s.rowHeight - gap + footer);
    s.x = Math.floor(frame.x + Math.max(0, frame.width - s.width) / 2);
    s.y = Math.floor(frame.y + Math.max(0, frame.height - s.height) / 2);

    // ポップアップ内の各テキストの位置 { x, y, width, height }。
    const pad = 24 * k;
    const hint2 = s.height - 6 * k - m.hint;
    s.text = {
        title: { x: pad, y: 16 * k, width: s.width - 2 * pad, height: m.title },
        hint1: { x: pad, y: hint2 - m.hint, width: s.width - 2 * pad, height: m.hint },
        hint2: { x: pad, y: hint2, width: s.width - 2 * pad - 150 * k, height: m.hint },
        range: { x: s.width - 150 * k, y: hint2, width: 126 * k, height: m.hint },
    };
    // 行見出し (行の y からの相対位置) とカード内の配置。
    const labelWidth = s.cardsLeft - 32 * k;
    const nameY = 12 * k;
    s.rowText = {
        name: { x: 20 * k, y: nameY, width: labelWidth, height: m.rowName },
        range: { x: 20 * k, y: nameY + m.rowName + 2 * k, width: labelWidth, height: m.rowSmall },
        arrow: { x: 20 * k, y: nameY + m.rowName + 2 * k + m.rowSmall, width: labelWidth, height: m.rowArrow },
    };
    const titleY = s.cardHeight - 3 * k - m.cardTitle;
    const appY = titleY - m.app;
    s.cardText = {
        preview: { x: 8 * k, y: 6 * k, width: Math.max(1, s.cardWidth - 16 * k), height: Math.max(1, appY - 8 * k) },
        app: { x: 10 * k, y: appY, width: s.cardWidth - 20 * k, height: m.app },
        title: { x: 10 * k, y: titleY, width: s.cardWidth - 20 * k, height: m.cardTitle },
    };
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
            y: s.rowsTop + (rowIndex - s.firstRow) * s.rowHeight,
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
                x: s.cardsLeft + (index - row.first) * (s.cardWidth + s.gap), y,
                selected: rowIndex === s.selectedRow && index === row.selected,
            });
        }
    }
    return cards;
}
