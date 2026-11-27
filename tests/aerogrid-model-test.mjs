// AeroGrid (config/quickshell/aerogrid) のグリッド状態とウィンドウ配置のテスト。
// 実行: node tests/aerogrid-model-test.mjs  (Hyprland / Quickshell は不要)
import assert from 'node:assert/strict';
import * as M from '../config/quickshell/aerogrid/model.mjs';
import { placementRect, workArea } from '../config/quickshell/aerogrid/placement.mjs';

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

// 既定の寸法は Hammerspoon 版と同じ。
{
    const s = M.layout(M.buildSession([w(1, 'A'), w(2, 'A')], 1), frame);
    assert.equal(s.rowsTop, 56);
    assert.equal(s.cardsLeft, 112);
    assert.equal(s.width, 132 + 2 * (s.cardWidth + 12) - 12);
    assert.equal(s.height, 124 + s.rowHeight - 12);
    assert.deepEqual(s.cardText.app, { x: 10, y: s.cardHeight - 41, width: s.cardWidth - 20, height: 18 });
}

// 文字が枠に収まり、互いに重ならないこと (表示倍率 1/2、大きな文字、狭い画面、行数の多い場合)。
const overlaps = (a, b) => a.y < b.y + b.height && b.y < a.y + a.height
    && a.x < b.x + b.width && b.x < a.x + a.width;
const inside = (a, width, height) => a.x >= 0 && a.y >= 0
    && a.x + a.width <= width + 0.001 && a.y + a.height <= height + 0.001;
const bigText = { scale: 1, title: 40, hint: 32, rowName: 36, rowSmall: 30, rowArrow: 30, app: 26, cardTitle: 28 };
const hidpi = Object.fromEntries(Object.entries(M.DEFAULT_METRICS).map(([key, v]) => [key, v * 2]));
for (const [name, metrics, area] of [
    ['default', M.DEFAULT_METRICS, frame],
    ['hidpi', hidpi, { x: 0, y: 0, width: 3840, height: 2100 }],
    ['big text', bigText, frame],
    ['small screen + big text', bigText, { x: 0, y: 0, width: 1280, height: 720 }],
]) {
    const windows = Array.from({ length: 30 }, (_, i) => w(i + 1, String(i % 9 + 1)));
    const s = M.layout(M.buildSession(windows, 1), area, metrics);
    const t = s.text;
    for (const box of Object.values(t))
        assert.ok(inside(box, s.width, s.height), `${name}: ヘッダー/フッターがポップアップ内`);
    assert.ok(!overlaps(t.hint1, t.hint2) && !overlaps(t.hint2, t.range), `${name}: フッターが重ならない`);
    assert.ok(t.title.y + t.title.height <= s.rowsTop, `${name}: タイトルとカードが重ならない`);
    const lastRowBottom = s.rowsTop + s.visibleRows * s.rowHeight - s.gap;
    assert.ok(lastRowBottom <= t.hint1.y, `${name}: カードとフッターが重ならない`);
    const c = s.cardText;
    for (const box of Object.values(c))
        assert.ok(inside(box, s.cardWidth, s.cardHeight), `${name}: カード内に収まる`);
    assert.ok(!overlaps(c.preview, c.app) && !overlaps(c.app, c.title), `${name}: カード内で重ならない`);
    const r = s.rowText;
    assert.ok(!overlaps(r.name, r.range) && !overlaps(r.range, r.arrow), `${name}: 行見出しが重ならない`);
    assert.ok(r.arrow.y + r.arrow.height <= s.rowHeight, `${name}: 行見出しが行の高さに収まる`);
    assert.ok(r.name.x + r.name.width <= s.cardsLeft, `${name}: 行見出しとカードが重ならない`);
}

// ウィンドウ配置 (Raycast 相当)。奇数幅でも隙間・重なりなく作業領域を分ける。
{
    const area = { x: 100, y: 32, width: 1921, height: 1047 };
    const l = placementRect(area, 'left-half'), r = placementRect(area, 'right-half');
    const t = placementRect(area, 'top-half'), b = placementRect(area, 'bottom-half');
    assert.deepEqual(l, { x: 100, y: 32, width: 960, height: 1047 });
    assert.deepEqual(r, { x: 1060, y: 32, width: 961, height: 1047 });
    assert.equal(l.width + r.width, area.width);
    assert.deepEqual(t, { x: 100, y: 32, width: 1921, height: 523 });
    assert.deepEqual(b, { x: 100, y: 555, width: 1921, height: 524 });
    assert.deepEqual(placementRect(area, 'maximize'), area);
    assert.throws(() => placementRect(area, 'nope'));
}

// hyprctl monitors のモニタ情報から作業領域 (バーを除く、論理ピクセル) を求める。
assert.deepEqual(workArea({ x: 0, y: 0, width: 2560, height: 1440, scale: 1, transform: 0, reserved: [0, 30, 0, 0] }),
    { x: 0, y: 30, width: 2560, height: 1410 });
assert.deepEqual(workArea({ x: 2560, y: 0, width: 3840, height: 2160, scale: 2, transform: 0, reserved: [0, 30, 0, 0] }),
    { x: 2560, y: 30, width: 1920, height: 1050 });
assert.deepEqual(workArea({ x: -1080, y: 0, width: 1920, height: 1080, scale: 1, transform: 1, reserved: [0, 30, 0, 0] }),
    { x: -1080, y: 30, width: 1080, height: 1890 });
assert.deepEqual(workArea({ x: 0, y: 0, width: 1920, height: 1080, scale: 1 }),
    { x: 0, y: 0, width: 1920, height: 1080 });

console.log('aerogrid model: ok');
