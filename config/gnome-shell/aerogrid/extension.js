// AeroGrid: Lachesis の AeroSpace (floating 運用) + Hammerspoon グリッドを GNOME 46 で再現する。
//   - config.js の WORKSPACES で固定数・名前付きのワークスペースを用意する
//   - 修飾キー+キー: そのワークスペースへ切り替え (summon-workspace 相当)
//   - 修飾キー+Shift+キー: フォーカス中のウィンドウを移動 (move-node-to-workspace 相当)
//   - 修飾キー+Tab: ワークスペース別のウィンドウグリッド
//   - 新しいウィンドウを RULES に従ってワークスペースへ振り分ける (on-window-detected 相当)
// GNOME の既定ショートカットとの衝突は modules/Home/desktop/gnome/keybindings.nix で外す。
import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

import { KEYLESS, MODIFIER, RULES, WORKSPACES } from './config.js';
import { WindowGrid } from './grid.js';

const MODIFIER_MASKS = {
    '<Alt>': Clutter.ModifierType.MOD1_MASK,
    '<Super>': Clutter.ModifierType.MOD4_MASK,
    '<Control>': Clutter.ModifierType.CONTROL_MASK,
};

export default class AeroGridExtension extends Extension {
    enable() {
        this._actions = new Map(); // action -> { name, callback }
        this._pending = new Map(); // window -> notify::wm-class handler
        this._applyWorkspaces();

        this._grid = new WindowGrid(MODIFIER_MASKS[MODIFIER], WORKSPACES);
        WORKSPACES.forEach((name, index) => {
            if (KEYLESS.includes(name))
                return;
            const key = name.toLowerCase();
            this._bind(`${MODIFIER}${key}`, () => this._summon(index));
            this._bind(`${MODIFIER}<Shift>${key}`, () => this._moveFocused(index));
        });
        this._bind(`${MODIFIER}Tab`, () => this._grid.open());

        this._acceleratorId = global.display.connect('accelerator-activated',
            (_display, action) => this._actions.get(action)?.callback());
        this._windowCreatedId = global.display.connect('window-created',
            (_display, window) => this._onWindowCreated(window));
    }

    disable() {
        // 画面ロック中も無効化される (session-modes 未指定のため)。解除時に再度 enable される。
        this._grid?.finish(false);
        this._grid = null;
        global.display.disconnect(this._acceleratorId);
        global.display.disconnect(this._windowCreatedId);
        for (const [window, id] of this._pending)
            window.disconnect(id);
        this._pending = null;
        for (const [action, { name }] of this._actions) {
            global.display.ungrab_accelerator(action);
            Main.wm.allowKeybinding(name, Shell.ActionMode.NONE);
        }
        this._actions = null;
    }

    // ワークスペースの数と名前は config.js を唯一の定義元にする。
    // 固定数にする設定 (dynamic-workspaces = false) は Home Manager 側で行う。
    _applyWorkspaces() {
        const prefs = new Gio.Settings({ schema_id: 'org.gnome.desktop.wm.preferences' });
        if (prefs.get_int('num-workspaces') !== WORKSPACES.length)
            prefs.set_int('num-workspaces', WORKSPACES.length);
        if (prefs.get_strv('workspace-names').join('\n') !== WORKSPACES.join('\n'))
            prefs.set_strv('workspace-names', WORKSPACES);
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

    _summon(index) {
        const workspace = global.workspace_manager.get_workspace_by_index(index);
        if (workspace && !workspace.active)
            workspace.activate(global.get_current_time());
        if (Main.overview.visible)
            Main.overview.hide();
    }

    // AeroSpace と同じく、移動したウィンドウには追従しない。
    _moveFocused(index) {
        const window = global.display.focus_window;
        if (window && index < global.workspace_manager.get_n_workspaces())
            window.change_workspace_by_index(index, false);
    }

    _onWindowCreated(window) {
        if (window.get_window_type() !== Meta.WindowType.NORMAL || window.get_transient_for())
            return;
        if (this._applyRule(window) || window.get_wm_class())
            return;
        // WM_CLASS がまだ無い場合は、設定されるまで一度だけ待つ。
        const id = window.connect('notify::wm-class', () => {
            window.disconnect(id);
            this._pending.delete(window);
            this._applyRule(window);
        });
        this._pending.set(window, id);
        window.connect('unmanaged', () => {
            if (this._pending?.get(window) === id) {
                window.disconnect(id);
                this._pending.delete(window);
            }
        });
    }

    _applyRule(window) {
        const classes = [window.get_wm_class(), window.get_wm_class_instance()].filter(Boolean);
        const rule = RULES.find(r => classes.some(c => r.match.test(c)));
        if (!rule)
            return false;
        const index = WORKSPACES.indexOf(rule.workspace);
        if (index >= 0 && index < global.workspace_manager.get_n_workspaces())
            window.change_workspace_by_index(index, false);
        return true;
    }
}
