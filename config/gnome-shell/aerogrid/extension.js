// AeroGrid: Lachesis の AeroSpace (floating 運用) + Hammerspoon グリッドを GNOME 46 で再現する。
//
// AeroSpace と同じく GNOME (Mutter) のワークスペースは 1 つだけ使い、32 個の仮想ワークスペースを
// この拡張が管理する。各モニタが別々の仮想ワークスペースを表示し、表示しないワークスペースの
// ウィンドウは最小化して隠す (アニメーションなし)。利用者が自分で最小化したウィンドウとは区別する。
//
//   - 修飾キー+キー: そのワークスペースを操作中のモニタに表示 (summon-workspace)
//   - 修飾キー+Shift+キー: フォーカス中のウィンドウを移動 (move-node-to-workspace)
//   - 修飾キー+Tab: ワークスペース別のウィンドウグリッド
//   - 新しいウィンドウを RULES に従って振り分け (on-window-detected)
//   - Option+Control+hjkl/Space: ウィンドウを半分/全体に配置 (Raycast の Window Management)
//   - 上部バー: ウィンドウがあるワークスペースと、各モニタに表示中のワークスペース
//
// 所属と表示状態は ~/.cache/aerogrid/state.json に保存し、GNOME Shell の再起動 (Alt+F2 r) 後に
// X11 のウィンドウ ID で復元する。GNOME の既定ショートカットとの衝突は
// modules/Home/desktop/gnome/keybindings.nix で外す。
import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

import { KEYLESS, MODIFIER, PLACEMENT_KEYS, PLACEMENT_MODIFIER, RULES, WORKSPACES } from './config.js';
import { WindowGrid } from './grid.js';
import { WorkspaceIndicator } from './indicator.js';
import { placementRect } from './placement.js';
import { MonitorWorkspaces, indicatorItems } from './workspaces.js';

const MODIFIER_MASKS = {
    '<Alt>': Clutter.ModifierType.MOD1_MASK,
    '<Super>': Clutter.ModifierType.MOD4_MASK,
    '<Control>': Clutter.ModifierType.CONTROL_MASK,
};
const MANAGED_TYPES = [Meta.WindowType.NORMAL, Meta.WindowType.DIALOG, Meta.WindowType.MODAL_DIALOG];
const STATE_VERSION = 1;

export default class AeroGridExtension extends Extension {
    enable() {
        this._actions = new Map(); // action -> { name, callback }
        this._windows = new Map(); // Meta.Window -> { workspace, settling, ids }
        this._hidden = new Set(); // AeroGrid が最小化して隠したウィンドウ
        this._busy = 0; // 自分で最小化・移動している間は、そのシグナルに反応しない
        this._signals = [];
        this._saveId = 0;
        this._statePath = GLib.build_filenamev([GLib.get_user_cache_dir(), 'aerogrid', 'state.json']);

        this._restore();

        this._indicator = new WorkspaceIndicator(name => this._summon(name, this._focusedMonitor()));
        Main.panel.addToStatusArea(this.uuid, this._indicator, 1, 'left');

        this._grid = new WindowGrid(MODIFIER_MASKS[MODIFIER], {
            windows: () => [...this._windows].map(([meta, entry]) => ({ meta, workspace: entry.workspace })),
            focusedMonitor: () => this._focusedMonitor(),
            activate: window => this._activate(window),
        });

        for (const name of WORKSPACES) {
            if (KEYLESS.includes(name))
                continue;
            const key = name.toLowerCase();
            this._bind(`${MODIFIER}${key}`, () => this._summon(name, this._focusedMonitor()));
            this._bind(`${MODIFIER}<Shift>${key}`, () => this._moveFocused(name));
        }
        this._bind(`${MODIFIER}Tab`, () => this._grid.open());
        for (const [key, placement] of Object.entries(PLACEMENT_KEYS))
            this._bind(`${PLACEMENT_MODIFIER}${key}`, () => this._place(placement));

        const display = global.display;
        this._connect(display, 'accelerator-activated', (_d, action) => this._actions.get(action)?.callback());
        this._connect(display, 'window-created', (_d, window) => this._onWindowCreated(window));
        this._connect(display, 'window-entered-monitor', (_d, monitor, window) =>
            this._onWindowEnteredMonitor(window, monitor));
        this._connect(display, 'notify::focus-window', () => this._onFocusChanged());
        this._connect(Main.layoutManager, 'monitors-changed', () => this._onMonitorsChanged());
        // 画面ロック中も有効なまま (metadata の session-modes)。バーの表示だけ隠す。
        this._connect(Main.sessionMode, 'updated', () => this._updateIndicator());

        this._updateIndicator();
    }

    disable() {
        this._grid?.finish(false);
        this._grid = null;
        for (const [object, id] of this._signals)
            object.disconnect(id);
        this._signals = null;
        for (const [action, { name }] of this._actions) {
            global.display.ungrab_accelerator(action);
            Main.wm.allowKeybinding(name, Shell.ActionMode.NONE);
        }
        this._actions = null;
        this._indicator?.destroy();
        this._indicator = null;

        // 所属を保存してから、隠していたウィンドウをすべて戻す (拡張を切っても窓が消えないように)。
        // 再度有効になったときは保存した状態から隠し直す。
        this._writeState();
        if (this._saveId) {
            GLib.source_remove(this._saveId);
            this._saveId = 0;
        }
        this._busy++;
        for (const window of [...this._hidden]) {
            this._hidden.delete(window);
            this._skipEffect(window);
            window.unminimize();
        }
        for (const [window, entry] of this._windows)
            entry.ids.forEach(id => window.disconnect(id));
        this._windows = null;
        this._hidden = null;
        this._workspaces = null;
    }

    _connect(object, signal, callback) {
        this._signals.push([object, object.connect(signal, callback)]);
    }

    _bind(accelerator, callback) {
        const action = global.display.grab_accelerator(accelerator, Meta.KeyBindingFlags.NONE);
        if (action === Meta.KeyBindingAction.NONE) {
            // GNOME の既定ショートカットなど、ほかが同じキーを掴んでいる。
            console.warn(`AeroGrid: ${accelerator} を登録できません (別のショートカットと衝突)`);
            return;
        }
        const name = Meta.external_binding_name_for_action(action);
        Main.wm.allowKeybinding(name, Shell.ActionMode.NORMAL | Shell.ActionMode.OVERVIEW);
        this._actions.set(action, { name, callback });
    }

    // ---- 状態の復元と保存 -------------------------------------------------

    _restore() {
        const saved = this._readState();
        const windowsByKey = saved?.windows ?? {};
        const hiddenKeys = new Set(saved?.hidden ?? []);
        const manager = global.workspace_manager;
        const monitors = global.display.get_n_monitors();

        // 初回 (保存が無い) は GNOME のワークスペースの所属をそのまま引き継ぐ。
        const assigned = new Map();
        for (const window of global.display.list_all_windows().filter(w => this._isManaged(w))) {
            const index = window.get_workspace()?.index();
            const name = saved ? windowsByKey[this._windowKey(window)] : WORKSPACES[index];
            assigned.set(window, WORKSPACES.includes(name) ? name : null);
        }
        let visible = saved?.visible ?? [];
        if (!saved) {
            visible = [];
            visible[Main.layoutManager.primaryIndex] = WORKSPACES[manager.get_active_workspace_index()];
        }
        const used = new Set(assigned.values());
        this._workspaces = new MonitorWorkspaces(WORKSPACES, monitors, visible, name => !used.has(name));

        this._collapseWorkspaces();
        for (const [window, name] of assigned) {
            const workspace = name ?? this._workspaces.visibleOn(this._monitorOf(window));
            this._track(window, workspace, false);
            if (window.minimized && hiddenKeys.has(this._windowKey(window)))
                this._hidden.add(window);
        }
        this._busy++;
        try {
            for (const [window, entry] of this._windows)
                this._sync(window, entry.workspace);
        } finally {
            this._busy--;
        }
        this._scheduleSave();
    }

    // Mutter のワークスペースは 1 つにまとめる (仮想ワークスペースで置き換えるため)。
    _collapseWorkspaces() {
        const manager = global.workspace_manager;
        const first = manager.get_workspace_by_index(0);
        if (!first.active)
            first.activate(global.get_current_time());
        for (const window of global.display.list_all_windows()) {
            if (!window.is_on_all_workspaces() && window.get_workspace() && window.get_workspace() !== first)
                window.change_workspace(first);
        }
        const prefs = new Gio.Settings({ schema_id: 'org.gnome.desktop.wm.preferences' });
        if (prefs.get_int('num-workspaces') !== 1)
            prefs.set_int('num-workspaces', 1);
    }

    _readState() {
        try {
            const [ok, bytes] = GLib.file_get_contents(this._statePath);
            if (!ok)
                return null;
            const state = JSON.parse(new TextDecoder().decode(bytes));
            return state?.version === STATE_VERSION ? state : null;
        } catch {
            return null;
        }
    }

    _scheduleSave() {
        if (this._saveId)
            return;
        this._saveId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
            this._saveId = 0;
            this._writeState();
            return GLib.SOURCE_REMOVE;
        });
    }

    _writeState() {
        if (!this._windows)
            return;
        const windows = {};
        for (const [window, entry] of this._windows)
            windows[this._windowKey(window)] = entry.workspace;
        const state = {
            version: STATE_VERSION,
            visible: this._workspaces.visible,
            windows,
            hidden: [...this._hidden].map(w => this._windowKey(w)),
        };
        try {
            GLib.mkdir_with_parents(GLib.path_get_dirname(this._statePath), 0o700);
            GLib.file_set_contents(this._statePath, JSON.stringify(state));
        } catch (e) {
            console.warn(`AeroGrid: 状態を保存できません: ${e.message}`);
        }
    }

    // X11 のウィンドウ ID は GNOME Shell を再起動しても変わらない。
    _windowKey(window) {
        const xid = /^0x[0-9a-f]+/i.exec(window.get_description() ?? '');
        return xid ? xid[0] : `seq-${window.get_stable_sequence()}`;
    }

    // ---- ウィンドウの追跡 -------------------------------------------------

    _isManaged(window) {
        return !window.is_override_redirect() && !window.skip_taskbar && !window.get_transient_for() &&
            !window.is_on_all_workspaces() && MANAGED_TYPES.includes(window.get_window_type());
    }

    _track(window, workspace, settling) {
        const entry = { workspace, settling, ids: [] };
        entry.ids.push(window.connect('notify::minimized', () => this._onMinimizedChanged(window)));
        entry.ids.push(window.connect('unmanaged', () => this._untrack(window)));
        this._windows.set(window, entry);
        return entry;
    }

    _untrack(window) {
        const entry = this._windows?.get(window);
        if (!entry)
            return;
        entry.ids.forEach(id => window.disconnect(id));
        this._windows.delete(window);
        this._hidden.delete(window);
        this._changed();
    }

    _onWindowCreated(window) {
        if (!this._isManaged(window))
            return;
        // 規則が無ければ、操作中のモニタに表示しているワークスペースに入れる。
        // 位置が決まるのは最初の表示時なので、それまでは settling として扱う。
        const rule = this._ruleFor(window);
        const entry = this._track(window, rule ?? this._workspaces.visibleOn(this._focusedMonitor()), true);
        if (!this._workspaces.isVisible(entry.workspace))
            this._withBusy(() => this._hide(window));

        if (!window.get_wm_class()) {
            // WM_CLASS が後から設定されるアプリは、設定されたときに規則を当て直す。
            const id = window.connect('notify::wm-class', () => {
                window.disconnect(id);
                entry.ids = entry.ids.filter(i => i !== id);
                const late = this._ruleFor(window);
                if (late)
                    this._moveWindow(window, late);
            });
            entry.ids.push(id);
        }
        const shownId = window.connect('shown', () => {
            window.disconnect(shownId);
            entry.ids = entry.ids.filter(i => i !== shownId);
            entry.settling = false;
            // Mutter が別のモニタに置いた場合は、所属するワークスペースのモニタへ戻す。
            this._withBusy(() => this._sync(window, entry.workspace));
        });
        entry.ids.push(shownId);
        this._changed();
    }

    _ruleFor(window) {
        const classes = [window.get_wm_class(), window.get_wm_class_instance()].filter(Boolean);
        const rule = RULES.find(r => classes.some(c => r.match.test(c)));
        return rule && WORKSPACES.includes(rule.workspace) ? rule.workspace : null;
    }

    // ドラッグなどで別のモニタへ移されたウィンドウは、そのモニタのワークスペースに所属を移す。
    _onWindowEnteredMonitor(window, monitor) {
        const entry = this._windows.get(window);
        if (!entry || this._busy || entry.settling || window.minimized || window.get_monitor() !== monitor)
            return;
        // モニタの抜き差しの途中 (monitors-changed の処理前) は無視する。
        if (global.display.get_n_monitors() !== this._workspaces.monitorCount)
            return;
        const workspace = this._workspaces.visibleOn(monitor);
        if (workspace && workspace !== entry.workspace) {
            entry.workspace = workspace;
            this._changed();
        }
    }

    // Dock・Command+Tab・通知などから、隠れているウィンドウが開かれたとき。
    // そのウィンドウのワークスペースを、ウィンドウがあるモニタに呼ぶ (AeroSpace と同じ)。
    _onMinimizedChanged(window) {
        if (this._busy)
            return;
        const entry = this._windows.get(window);
        if (!entry)
            return;
        if (window.minimized) {
            this._hidden.delete(window); // 利用者が自分で最小化した
            this._scheduleSave();
            return;
        }
        this._hidden.delete(window);
        if (!this._workspaces.isVisible(entry.workspace))
            this._summon(entry.workspace, this._monitorOf(window), window);
        else
            this._scheduleSave();
    }

    _onFocusChanged() {
        const window = global.display.focus_window;
        if (window && this._windows.has(window) && window.get_monitor() >= 0)
            this._lastMonitor = window.get_monitor();
        this._updateIndicator();
    }

    _onMonitorsChanged() {
        const count = global.display.get_n_monitors();
        const used = new Set([...this._windows.values()].map(e => e.workspace));
        const { hidden, shown } = this._workspaces.resize(count, name => !used.has(name));
        this._withBusy(() => {
            for (const name of hidden)
                this._windowsOf(name).forEach(w => this._hide(w));
            for (const { monitor, to } of shown)
                this._windowsOf(to).forEach(w => this._show(w, monitor));
        });
        if (this._lastMonitor >= count)
            this._lastMonitor = 0;
        this._changed();
    }

    // ---- 表示の切り替え ---------------------------------------------------

    // 操作中のモニタ: フォーカス中のウィンドウのモニタ。空のワークスペースを表示していて
    // フォーカスが無いときは、最後に操作したモニタ。
    _focusedMonitor() {
        const window = global.display.focus_window;
        const count = global.display.get_n_monitors();
        if (window && this._windows?.has(window) && window.get_monitor() >= 0)
            return window.get_monitor();
        if (this._lastMonitor !== undefined && this._lastMonitor < count)
            return this._lastMonitor;
        return Math.max(0, global.display.get_current_monitor());
    }

    _monitorOf(window) {
        const monitor = window.get_monitor();
        return monitor >= 0 && monitor < global.display.get_n_monitors() ? monitor : this._focusedMonitor();
    }

    _windowsOf(name) {
        return [...this._windows].filter(([, e]) => e.workspace === name).map(([w]) => w);
    }

    // focusWindow を渡すとそのウィンドウに、渡さなければワークスペースで最後に使った窓にフォーカスする。
    _summon(name, monitor, focusWindow = null) {
        if (Main.overview.visible)
            Main.overview.hide();
        const changes = this._workspaces.summon(name, monitor);
        this._withBusy(() => {
            // どのモニタにも表示されなくなったワークスペースを先に隠す。
            for (const { from } of changes) {
                if (from && !this._workspaces.isVisible(from))
                    this._windowsOf(from).forEach(w => this._hide(w));
            }
            for (const { monitor: m, to } of changes) {
                if (to)
                    this._windowsOf(to).forEach(w => this._show(w, m));
            }
        });
        this._lastMonitor = monitor;
        const time = global.get_current_time();
        const target = focusWindow ?? this._recentWindow(name);
        if (target)
            Main.activateWindow(target, time);
        else
            global.display.unset_input_focus?.(time);
        this._changed();
    }

    _recentWindow(name) {
        return global.display.get_tab_list(Meta.TabList.NORMAL_ALL, null)
            .find(w => this._windows.get(w)?.workspace === name && !w.minimized) ?? null;
    }

    // AeroSpace と同じく、移動したウィンドウには追従しない。
    _moveFocused(name) {
        const window = global.display.focus_window;
        if (window && this._windows.has(window))
            this._moveWindow(window, name);
    }

    _moveWindow(window, name) {
        const entry = this._windows.get(window);
        if (!entry || entry.workspace === name)
            return;
        entry.workspace = name;
        this._withBusy(() => this._sync(window, name));
        this._changed();
    }

    // ウィンドウを所属ワークスペースの状態に合わせる: 表示中ならそのモニタで表示、それ以外は隠す。
    _sync(window, name) {
        const monitor = this._workspaces.monitorOf(name);
        if (monitor >= 0)
            this._show(window, monitor);
        else
            this._hide(window);
    }

    _show(window, monitor) {
        if (window.get_monitor() !== monitor)
            window.move_to_monitor(monitor);
        if (this._hidden.delete(window)) {
            this._skipEffect(window);
            window.unminimize();
        }
    }

    // 利用者が最小化しているウィンドウはそのままにする (隠したものとして扱わない)。
    _hide(window) {
        if (window.minimized || this._hidden.has(window))
            return;
        if (!window.can_minimize()) {
            console.warn(`AeroGrid: 最小化できないウィンドウは隠せません: ${window.get_title()}`);
            return;
        }
        this._hidden.add(window);
        this._skipEffect(window);
        window.minimize();
    }

    _skipEffect(window) {
        const actor = window.get_compositor_private();
        if (actor)
            Main.wm.skipNextEffect(actor);
    }

    _withBusy(callback) {
        this._busy++;
        try {
            callback();
        } finally {
            this._busy--;
        }
    }

    // グリッドで選んだウィンドウ。隠れていれば操作中のモニタに呼ぶ。
    _activate(window) {
        const entry = this._windows.get(window);
        if (!entry)
            return;
        if (this._workspaces.isVisible(entry.workspace))
            Main.activateWindow(window, global.get_current_time());
        else
            this._summon(entry.workspace, this._focusedMonitor(), window);
    }

    _changed() {
        this._updateIndicator();
        this._scheduleSave();
    }

    _updateIndicator() {
        if (!this._indicator)
            return;
        this._indicator.container.visible = !Main.sessionMode.isLocked;
        const occupied = new Set([...this._windows.values()].map(e => e.workspace));
        this._indicator.update(indicatorItems(this._workspaces, occupied, this._focusedMonitor()));
    }

    // ---- ウィンドウ配置 ---------------------------------------------------

    _place(placement) {
        const window = global.display.focus_window;
        if (!window || window.get_window_type() !== Meta.WindowType.NORMAL)
            return;
        if (window.is_fullscreen())
            window.unmake_fullscreen();
        // 最大化中は位置とサイズを変えられないので、先に解除する。
        if (window.get_maximized())
            window.unmaximize(Meta.MaximizeFlags.BOTH);
        if (!window.allows_move() || !window.allows_resize())
            return;
        const rect = placementRect(window.get_work_area_current_monitor(), placement);
        // フレーム (影などの見えない枠を除いた範囲) を作業領域に合わせる。
        window.move_resize_frame(true, rect.x, rect.y, rect.width, rect.height);
    }
}
