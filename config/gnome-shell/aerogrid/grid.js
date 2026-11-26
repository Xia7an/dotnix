// Option+Tab のワークスペース別ウィンドウグリッド。
// 選択中は実際のワークスペースやフォーカスを変えず、修飾キーを離したときだけ
// Main.activateWindow でワークスペースの切り替えとフォーカスを行う。
import Clutter from 'gi://Clutter';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import St from 'gi://St';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';

import * as Model from './model.js';

const DIRECTIONS = new Map([
    [Clutter.KEY_h, 'left'], [Clutter.KEY_H, 'left'], [Clutter.KEY_Left, 'left'],
    [Clutter.KEY_j, 'down'], [Clutter.KEY_J, 'down'], [Clutter.KEY_Down, 'down'],
    [Clutter.KEY_k, 'up'], [Clutter.KEY_K, 'up'], [Clutter.KEY_Up, 'up'],
    [Clutter.KEY_l, 'right'], [Clutter.KEY_L, 'right'], [Clutter.KEY_Right, 'right'],
]);

function label(text, styleClass, x, y, width, height) {
    return new St.Label({ text: text ?? '', style_class: styleClass, x, y, width, height });
}

export class WindowGrid {
    // modifierMask: 押し続ける修飾キーの Clutter.ModifierType。
    // workspaceNames: ワークスペース番号 → 名前。
    constructor(modifierMask, workspaceNames) {
        this._modifierMask = modifierMask;
        this._workspaceNames = workspaceNames;
        this._session = null;
    }

    _modifierHeld() {
        const [, , mods] = global.get_pointer();
        return (mods & this._modifierMask) !== 0;
    }

    open() {
        if (this._session)
            return;
        const focused = global.display.focus_window;
        const tracker = Shell.WindowTracker.get_default();
        const windows = global.display.get_tab_list(Meta.TabList.NORMAL_ALL, null).map(meta => {
            const index = meta.get_workspace()?.index() ?? 0;
            const app = tracker.get_window_app(meta);
            return {
                id: meta.get_id(),
                workspace: this._workspaceNames[index] ?? String(index + 1),
                meta, app,
                appName: app?.get_name() ?? meta.get_wm_class() ?? '',
                title: meta.get_title() ?? '',
            };
        });
        const s = Model.buildSession(windows, focused?.get_id());
        if (s.rows.length === 0)
            return;

        const monitor = focused?.get_monitor() ?? Main.layoutManager.primaryIndex;
        const area = Main.layoutManager.getWorkAreaForMonitor(monitor);
        Model.layout(s, area);

        // 画面全体を覆う透明な背景。外側のクリックで取り消す。
        s.backdrop = new St.Widget({
            reactive: true, can_focus: true,
            x: 0, y: 0, width: global.stage.width, height: global.stage.height,
        });
        s.popup = new St.Widget({
            style_class: 'aerogrid-popup',
            x: s.x, y: s.y, width: s.width, height: s.height,
        });
        s.backdrop.add_child(s.popup);
        Main.uiGroup.add_child(s.backdrop);

        const grab = Main.pushModal(s.backdrop, { actionMode: Shell.ActionMode.SYSTEM_MODAL });
        if ((grab.get_seat_state() & Clutter.GrabState.KEYBOARD) === 0) {
            Main.popModal(grab);
            s.backdrop.destroy();
            return;
        }
        s.grab = grab;
        this._session = s;
        s.backdrop.grab_key_focus();
        s.backdrop.connect('key-press-event', (_actor, event) => this._onKeyPress(event));
        s.backdrop.connect('key-release-event', () => this._onKeyRelease());
        s.backdrop.connect('button-press-event', () => {
            this.finish(false);
            return Clutter.EVENT_STOP;
        });

        // 表示前に修飾キーを離していたら、何も変えずに閉じる。
        if (!this._modifierHeld()) {
            this.finish(false);
            return;
        }
        this._draw();
    }

    _onKeyPress(event) {
        const symbol = event.get_key_symbol();
        if (symbol === Clutter.KEY_Escape) {
            this.finish(false);
        } else if (DIRECTIONS.has(symbol)) {
            Model.move(this._session, DIRECTIONS.get(symbol));
            this._draw();
        }
        // Tab の自動リピートや無関係なキーも含め、表示中のキーはすべて消費する。
        return Clutter.EVENT_STOP;
    }

    _onKeyRelease() {
        if (this._session && !this._modifierHeld())
            this.finish(true);
        return Clutter.EVENT_STOP;
    }

    finish(commit) {
        const s = this._session;
        if (!s)
            return;
        this._session = null;
        const target = commit ? Model.selectedWindow(s)?.meta : null;
        Main.popModal(s.grab);
        s.backdrop.destroy(); // Clone はソースを参照するだけなので一緒に破棄される。
        // 表示中に閉じられたウィンドウは対象外にする。
        if (target && global.display.list_all_windows().includes(target))
            Main.activateWindow(target, global.get_current_time());
    }

    _draw() {
        const s = this._session;
        const popup = s.popup;
        popup.destroy_all_children();
        const W = s.width, H = s.height;

        popup.add_child(label(`Windows   ·   ${s.windowCount} windows / ${s.rows.length} workspaces`,
            'aerogrid-title', 24, 16, W - 48, 28));
        popup.add_child(label('h l  ウィンドウ    j k  ワークスペース',
            'aerogrid-hint', 24, H - 54, W - 48, 24));
        popup.add_child(label('⌥ を離すと確定 · Esc 取消', 'aerogrid-hint', 24, H - 30, W - 200, 24));
        const lastRow = Model.lastVisibleRow(s);
        popup.add_child(label(
            `${s.firstRow > 0 ? '↑ ' : ''}${s.firstRow + 1}–${lastRow + 1} / ${s.rows.length}` +
                `${lastRow < s.rows.length - 1 ? ' ↓' : ''}`,
            'aerogrid-hint', W - 150, H - 30, 126, 24));

        for (const { row, rowIndex, y, last } of Model.visibleRows(s)) {
            const style = rowIndex === s.selectedRow ? 'aerogrid-row aerogrid-row-selected' : 'aerogrid-row';
            popup.add_child(label(row.name, `${style} aerogrid-row-name`, 20, y + 12, 80, 28));
            popup.add_child(label(`${row.first + 1}–${last + 1}/${row.windows.length}`, style, 20, y + 40, 80, 22));
            popup.add_child(label(
                `${row.first > 0 ? '← ' : ''}${last < row.windows.length - 1 ? '→' : ''}`,
                `${style} aerogrid-row-arrow`, 20, y + 62, 80, 22));
        }

        for (const card of Model.visibleCards(s))
            popup.add_child(this._card(card));
    }

    _card({ window, x, y, selected }) {
        const s = this._session;
        const card = new St.Widget({
            style_class: selected ? 'aerogrid-card aerogrid-card-selected' : 'aerogrid-card',
            x, y, width: s.cardWidth, height: s.cardHeight,
        });
        const previewW = Math.max(1, s.cardWidth - 16);
        const previewH = Math.max(1, s.cardHeight - 48);
        card.add_child(this._preview(window, previewW, previewH));
        card.add_child(label(window.appName, 'aerogrid-card-app', 10, s.cardHeight - 40, s.cardWidth - 20, 18));
        card.add_child(label(window.title, 'aerogrid-card-title', 10, s.cardHeight - 23, s.cardWidth - 20, 20));
        return card;
    }

    // ライブのプレビュー。別ワークスペースのウィンドウも Clone で描ける。
    // 最小化中や actor が無いときはアプリのアイコンで代用する。
    _preview(window, maxW, maxH) {
        const actor = window.meta.get_compositor_private();
        const [w, h] = actor ? actor.get_size() : [0, 0];
        if (actor && !window.meta.minimized && w > 0 && h > 0) {
            const scale = Math.min(1, maxW / w, maxH / h);
            const cw = Math.floor(w * scale), ch = Math.floor(h * scale);
            return new Clutter.Clone({
                source: actor, width: cw, height: ch,
                x: 8 + Math.floor((maxW - cw) / 2), y: 6 + Math.floor((maxH - ch) / 2),
            });
        }
        const size = Math.max(16, Math.min(64, maxH));
        const icon = window.app?.create_icon_texture(size)
            ?? new St.Icon({ icon_name: 'application-x-executable', icon_size: size });
        icon.set_position(8 + Math.floor((maxW - size) / 2), 6 + Math.floor((maxH - size) / 2));
        return icon;
    }
}
