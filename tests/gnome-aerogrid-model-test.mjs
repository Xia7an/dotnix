// AeroGrid のグリッド状態 (config/gnome-shell/aerogrid/model.js) のテスト。
// 実行: node tests/gnome-aerogrid-model-test.mjs  (GNOME は不要)
import assert from 'node:assert/strict';
import * as M from '../config/gnome-shell/aerogrid/model.js';

const frame = { x: 0, y: 0, width: 1600, height: 1000 };
const w = (id, workspace) => ({ id, workspace });

// 並び順: 数字は数値順で先、その後に名前順。空のワークスペースは行にならない。
{
    const s = M.buildSession([w(5, 'W'), w(1, '10'), w(2, '2'), w(3, 'A'), w(4, 'T')], 4);
    assert.deepEqual(s.rows.map(r => r.name), ['2', '10', 'A', 'T', 'W']);
    assert.equal(s.windowCount, 5);
    assert.equal(s.selectedRow, 3, '初期選択はフォーカス中のウィンドウ');
}

// 行内は id 順、重複 id は無視、初期選択の位置。
{
    const s = M.buildSession([w(9, 'T'), w(3, 'T'), w(3, 'T'), w(7, 'T')], 7);
    assert.deepEqual(s.rows[0].windows.map(x => x.id), [3, 7, 9]);
    assert.equal(s.rows[0].selected, 1);
    assert.equal(s.windowCount, 3);
}

// フォーカス中のウィンドウが無ければ先頭。
{
    const s = M.buildSession([w(1, 'A'), w(2, 'B')], undefined);
    assert.equal(s.selectedRow, 0);
    assert.equal(s.rows[0].selected, 0);
}

// 空一覧。
assert.equal(M.buildSession([], 1).rows.length, 0);

// 端で止まる (折り返さない)。
{
    const s = M.layout(M.buildSession([w(1, 'A'), w(2, 'A'), w(3, 'B')], 1), frame);
    M.move(s, 'left');
    M.move(s, 'up');
    assert.equal(s.selectedRow, 0);
    assert.equal(s.rows[0].selected, 0);
    M.move(s, 'right'); M.move(s, 'right');
    assert.equal(s.rows[0].selected, 1);
    M.move(s, 'down'); M.move(s, 'down');
    assert.equal(s.selectedRow, 1);
    assert.equal(M.selectedWindow(s).id, 3);
}

// 行ごとに独立した選択と横スクロール。5 枚目以降でその行だけスクロールする。
{
    const many = Array.from({ length: 7 }, (_, i) => w(i + 1, 'A'));
    const s = M.layout(M.buildSession([...many, w(20, 'B'), w(21, 'B')], 1), frame);
    assert.equal(s.columns, 4);
    for (let i = 0; i < 5; i++) M.move(s, 'right');
    assert.equal(s.rows[0].selected, 5);
    assert.equal(s.rows[0].first, 2);
    M.move(s, 'down');
    M.move(s, 'right');
    assert.equal(s.rows[1].selected, 1);
    assert.equal(s.rows[1].first, 0, '別の行の横位置は変わらない');
    M.move(s, 'up');
    assert.equal(M.selectedWindow(s).id, 6, '戻ると最後に選んだウィンドウ');
    assert.equal(s.rows[0].first, 2);
    const cards = M.visibleCards(s);
    assert.deepEqual(cards.filter(c => c.rowIndex === 0).map(c => c.window.id), [3, 4, 5, 6]);
    assert.deepEqual(cards.filter(c => c.selected).map(c => c.window.id), [6]);
}

// 6 行を超えると 1 行ずつ縦スクロールする。
{
    const names = ['1', '2', '3', '4', '5', '6', '7', '8'];
    const s = M.layout(M.buildSession(names.map((n, i) => w(i + 1, n)), 1), frame);
    assert.equal(s.visibleRows, 6);
    for (let i = 0; i < 6; i++) M.move(s, 'down');
    assert.equal(s.selectedRow, 6);
    assert.equal(s.firstRow, 1);
    assert.equal(M.lastVisibleRow(s), 6);
    assert.deepEqual(M.visibleRows(s).map(r => r.row.name), ['2', '3', '4', '5', '6', '7']);
    for (let i = 0; i < 6; i++) M.move(s, 'up');
    assert.equal(s.firstRow, 0);
}

// 起動時、フォーカス中のウィンドウが範囲外なら見える位置までスクロールする。
{
    const names = ['1', '2', '3', '4', '5', '6', '7', '8'];
    const extra = Array.from({ length: 6 }, (_, i) => w(100 + i, '8'));
    const s = M.layout(M.buildSession([...names.map((n, i) => w(i + 1, n)), ...extra], 105), frame);
    assert.equal(s.selectedRow, 7);
    assert.equal(s.firstRow, 2);
    assert.equal(s.rows[7].first, s.rows[7].selected - 3);
}

// レイアウトは画面内に収まり、中央に置かれる。
{
    const small = { x: 1600, y: 0, width: 1280, height: 800 };
    const many = Array.from({ length: 10 }, (_, i) => w(i + 1, String(i % 8 + 1)));
    const s = M.layout(M.buildSession(many, 1), small);
    assert.ok(s.width <= small.width && s.height <= small.height);
    assert.ok(s.x >= small.x && s.x + s.width <= small.x + small.width);
}

console.log('gnome-aerogrid model: ok');
