// AeroGrid の仮想ワークスペース (config/gnome-shell/aerogrid/workspaces.js) のテスト。
// 実行: node tests/gnome-aerogrid-workspaces-test.mjs  (GNOME は不要)
import assert from 'node:assert/strict';
import { MonitorWorkspaces, indicatorModel, looksMerged } from '../config/gnome-shell/aerogrid/workspaces.js';

const names = ['1', '2', 'A', 'T', 'W'];

// 保存した状態を復元する。重複や不明な名前は捨て、空きのワークスペースで埋める。
{
    const ws = new MonitorWorkspaces(names, 3, ['T', 'T', 'nope'], name => name !== '1');
    assert.deepEqual(ws.visible, ['T', '2', 'A']);
    assert.equal(ws.monitorOf('T'), 0);
    assert.equal(ws.monitorOf('W'), -1);
    assert.equal(ws.isVisible('2'), true);
}

// 空きが無ければ、表示されていないものを先頭から使う。
{
    const ws = new MonitorWorkspaces(names, 2, [], () => false);
    assert.deepEqual(ws.visible, ['1', '2']);
}

// 初回: 主モニタだけ決まっている (疎な配列)。
{
    const visible = [];
    visible[1] = 'W';
    const ws = new MonitorWorkspaces(names, 2, visible);
    assert.deepEqual(ws.visible, ['1', 'W']);
}

// summon: 非表示のワークスペースを呼ぶと、元のワークスペースが非表示になる。
{
    const ws = new MonitorWorkspaces(names, 2, ['T', 'W']);
    assert.deepEqual(ws.summon('A', 0), [{ monitor: 0, from: 'T', to: 'A' }]);
    assert.deepEqual(ws.visible, ['A', 'W']);
    assert.equal(ws.isVisible('T'), false);
}

// summon: 別のモニタに表示中なら入れ替える (どちらも見えたまま)。
{
    const ws = new MonitorWorkspaces(names, 2, ['T', 'W']);
    assert.deepEqual(ws.summon('W', 0), [
        { monitor: 0, from: 'T', to: 'W' },
        { monitor: 1, from: 'W', to: 'T' },
    ]);
    assert.deepEqual(ws.visible, ['W', 'T']);
}

// summon: 既に表示中・不明な名前・範囲外のモニタは何もしない。
{
    const ws = new MonitorWorkspaces(names, 2, ['T', 'W']);
    assert.deepEqual(ws.summon('T', 0), []);
    assert.deepEqual(ws.summon('nope', 0), []);
    assert.deepEqual(ws.summon('A', 5), []);
    assert.deepEqual(ws.visible, ['T', 'W']);
}

// モニタを外す / つなぐ。
{
    const ws = new MonitorWorkspaces(names, 2, ['T', 'W']);
    assert.deepEqual(ws.resize(1), { hidden: ['W'], shown: [] });
    assert.deepEqual(ws.visible, ['T']);
    const occupied = new Set(['T', 'W', '1']);
    assert.deepEqual(ws.resize(3, name => !occupied.has(name)), {
        hidden: [],
        shown: [{ monitor: 1, to: '2' }, { monitor: 2, to: 'A' }],
    });
    assert.deepEqual(ws.visible, ['T', '2', 'A']);
}

// 上部バー: モニタごとの表示と、隠れているがウィンドウがあるワークスペース。
{
    const ws = new MonitorWorkspaces(names, 2, ['T', '2']);
    assert.deepEqual(indicatorModel(ws, new Set(['W', 'T', 'A']), 0), {
        monitors: [{ monitor: 0, name: 'T', active: true }, { monitor: 1, name: '2', active: false }],
        hidden: ['A', 'W'],
    });
    ws.summon('W', 1);
    assert.deepEqual(indicatorModel(ws, new Set(['W', 'T', 'A']), 1), {
        monitors: [{ monitor: 0, name: 'T', active: false }, { monitor: 1, name: 'W', active: true }],
        hidden: ['A'],
    });
}

// 1 枚に統合された画面の検出。
assert.equal(looksMerged([{ width: 3840, height: 1080 }]), true);
assert.equal(looksMerged([{ width: 5120, height: 1440 }]), true);
assert.equal(looksMerged([{ width: 2560, height: 1440 }]), false);
assert.equal(looksMerged([{ width: 1920, height: 1080 }, { width: 1920, height: 1080 }]), false);

console.log('gnome-aerogrid workspaces: ok');
