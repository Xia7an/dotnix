// Option+Tab のワークスペース別ウィンドウグリッド。
// 選択中は実際のワークスペースやフォーカスを変えず、修飾キーを離したときだけ
// extension.js 経由でワークスペースの切り替えとフォーカスを行う。
import Clutter from 'gi://Clutter';
import Pango from 'gi://Pango';
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

// 1 行に収め、幅を超える部分は末尾を … で省略する (改行で下の行に重ならないように)。
function label(text, styleClass, { x, y, width, height }) {
    const actor = new St.Label({
        text: (text ?? '').replace(/\s+/g, ' '), style_class: styleClass, x, y, width, height,
    });
    actor.clutter_text.set({ single_line_mode: true, line_wrap: false, ellipsize: Pango.EllipsizeMode.END });
    return actor;
}

// 各テキストのスタイルと、高さを測るときの見本の文字列。
// 日本語や記号も含めて、実際に表示する中で一番高い行になるようにする。
const SAMPLE = 'Windows ウィンドウ gjpqy ↑↓←→ ⌥';
const TEXT_STYLES = {
    title: 'aerogrid-title',
    hint: 'aerogrid-hint',
    rowName: 'aerogrid-row aerogrid-row-name',
    rowSmall: 'aerogrid-row',
    rowArrow: 'aerogrid-row aerogrid-row-arrow',
    app: 'aerogrid-card-app',
    cardTitle: 'aerogrid-card-title',
};

// 表示倍率 (HiDPI) と文字の拡大 (アクセシビリティの「大きな文字」) を反映した
// 実際の文字の高さを、画面外のラベルで測る。固定の高さだと文字が枠からはみ出して
// 隠れたり重なったりするため。
function measureMetrics() {
    const scale = St.ThemeContext.get_for_stage(global.stage).scale_factor;
    const metrics = { scale };
    const probe = new St.Widget({ opacity: 0, x: -10000, y: -10000 });
    Main.uiGroup.add_child(probe);
    for (const [key, style] of Object.entries(TEXT_STYLES)) {
        const sample = new St.Label({ text: SAMPLE, style_class: style });
        probe.add_child(sample);
        const [, natural] = sample.get_preferred_height(-1);
        // 標準の文字サイズでは従来の寸法を保ち、文字が大きいときだけ広げる。
        metrics[key] = Math.max(Model.DEFAULT_METRICS[key] * scale, Math.ceil(natural + 2 * scale));
    }
    probe.destroy();
    return metrics;
}

export class WindowGrid {
    // modifierMask: 押し続ける修飾キーの Clutter.ModifierType。
    // provider: extension.js が持つ仮想ワークスペースの情報。
    //   windows() → [{ meta, workspace }]、focusedMonitor() → モニタ番号、activate(meta)
    constructor(modifierMask, provider) {
        this._modifierMask = modifierMask;
        this._provider = provider;
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
        const windows = this._provider.windows().map(({ meta, workspace }) => {
            const app = tracker.get_window_app(meta);
            return {
                id: meta.get_id(), workspace, meta, app,
                appName: app?.get_name() ?? meta.get_wm_class() ?? '',
                title: meta.get_title() ?? '',
            };
        });
        const s = Model.buildSession(windows, focused?.get_id());
        if (s.rows.length === 0)
            return;

        const monitor = this._provider.focusedMonitor();
        const area = Main.layoutManager.getWorkAreaForMonitor(monitor);
        Model.layout(s, area, measureMetrics());

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
        // 表示中に閉じられたウィンドウは対象外にする。隠れているワークスペースの
        // ウィンドウなら、extension.js が操作中のモニタにそのワークスペースを呼ぶ。
        if (target && global.display.list_all_windows().includes(target))
            this._provider.activate(target);
    }

    _draw() {
        const s = this._session;
        const popup = s.popup;
        popup.destroy_all_children();
        const t = s.text;

        popup.add_child(label(`Windows   ·   ${s.windowCount} windows / ${s.rows.length} workspaces`,
            'aerogrid-title', t.title));
        popup.add_child(label('h l  ウィンドウ    j k  ワークスペース', 'aerogrid-hint', t.hint1));
        popup.add_child(label('⌥ を離すと確定 · Esc 取消', 'aerogrid-hint', t.hint2));
        const lastRow = Model.lastVisibleRow(s);
        popup.add_child(label(
            `${s.firstRow > 0 ? '↑ ' : ''}${s.firstRow + 1}–${lastRow + 1} / ${s.rows.length}` +
                `${lastRow < s.rows.length - 1 ? ' ↓' : ''}`,
            'aerogrid-hint aerogrid-range', t.range));

        const at = (box, y) => ({ ...box, y: box.y + y });
        for (const { row, rowIndex, y, last } of Model.visibleRows(s)) {
            const style = rowIndex === s.selectedRow ? 'aerogrid-row aerogrid-row-selected' : 'aerogrid-row';
            popup.add_child(label(row.name, `${style} aerogrid-row-name`, at(s.rowText.name, y)));
            popup.add_child(label(`${row.first + 1}–${last + 1}/${row.windows.length}`, style,
                at(s.rowText.range, y)));
            popup.add_child(label(
                `${row.first > 0 ? '← ' : ''}${last < row.windows.length - 1 ? '→' : ''}`,
                `${style} aerogrid-row-arrow`, at(s.rowText.arrow, y)));
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
        card.add_child(this._preview(window, s.cardText.preview));
        card.add_child(label(window.appName, 'aerogrid-card-app', s.cardText.app));
        card.add_child(label(window.title, 'aerogrid-card-title', s.cardText.title));
        return card;
    }

    // ライブのプレビュー。隠れている (最小化中の) ウィンドウも、最後に描画された内容を
    // Clone で描く。actor が無いときや大きさが取れないときはアプリのアイコンで代用する。
    _preview(window, box) {
        const actor = window.meta.get_compositor_private();
        const [w, h] = actor ? actor.get_size() : [0, 0];
        if (actor && w > 0 && h > 0) {
            const scale = Math.min(1, box.width / w, box.height / h);
            const cw = Math.floor(w * scale), ch = Math.floor(h * scale);
            return new Clutter.Clone({
                source: actor, width: cw, height: ch,
                x: box.x + Math.floor((box.width - cw) / 2), y: box.y + Math.floor((box.height - ch) / 2),
            });
        }
        // アイコンの大きさは論理ピクセルで指定する (St が表示倍率を掛ける)。
        const k = this._session.metrics.scale;
        const size = Math.floor(Math.max(16, Math.min(64, box.height / k)));
        const icon = window.app?.create_icon_texture(size)
            ?? new St.Icon({ icon_name: 'application-x-executable', icon_size: size });
        icon.set_position(box.x + Math.floor((box.width - size * k) / 2),
            box.y + Math.floor((box.height - size * k) / 2));
        return icon;
    }
}
