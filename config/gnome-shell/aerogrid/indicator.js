// 上部バーのワークスペース表示と、切り替え時に各モニタへ出すワークスペース名。
//
// バー: [1 T] [2 W]  ·  A D S
//   - 角括弧の組: モニタ番号と、そのモニタが表示中のワークスペース (モニタ番号順)。
//     操作中のモニタ (Option+文字が効くモニタ) を青で塗る。クリックでそのモニタを操作対象にする。
//   - 後ろの文字: 隠れているがウィンドウがあるワークスペース。クリックで操作中のモニタに呼ぶ。
import Clutter from 'gi://Clutter';
import GObject from 'gi://GObject';
import St from 'gi://St';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

export const WorkspaceIndicator = GObject.registerClass(
class WorkspaceIndicator extends PanelMenu.Button {
    // onSummon(name): 隠れているワークスペースをクリックしたとき。
    // onSelectMonitor(monitor): モニタの組をクリックしたとき。
    _init({ onSummon, onSelectMonitor }) {
        super._init(0.0, 'AeroGrid Workspaces', true);
        this._onSummon = onSummon;
        this._onSelectMonitor = onSelectMonitor;
        this._box = new St.BoxLayout({ style_class: 'aerogrid-indicator', y_align: Clutter.ActorAlign.CENTER });
        this.add_child(this._box);
        this._key = '';
    }

    // model: workspaces.js の indicatorModel() の結果。
    update(model) {
        const key = JSON.stringify(model);
        if (key === this._key)
            return;
        this._key = key;
        this._box.destroy_all_children();

        for (const { monitor, name, active } of model.monitors) {
            const button = new St.Button({
                style_class: `aerogrid-monitor${active ? ' aerogrid-monitor-active' : ''}`,
                y_align: Clutter.ActorAlign.CENTER,
            });
            const content = new St.BoxLayout();
            content.add_child(new St.Label({
                text: String(monitor + 1), style_class: 'aerogrid-monitor-number',
                y_align: Clutter.ActorAlign.CENTER,
            }));
            content.add_child(new St.Label({
                text: name ?? '-', style_class: 'aerogrid-monitor-workspace',
                y_align: Clutter.ActorAlign.CENTER,
            }));
            button.set_child(content);
            button.connect('clicked', () => this._onSelectMonitor(monitor));
            this._box.add_child(button);
        }

        if (model.hidden.length > 0) {
            this._box.add_child(new St.Label({
                text: '·', style_class: 'aerogrid-separator', y_align: Clutter.ActorAlign.CENTER,
            }));
        }
        for (const name of model.hidden) {
            const button = new St.Button({
                style_class: 'aerogrid-ws', label: name, y_align: Clutter.ActorAlign.CENTER,
            });
            button.connect('clicked', () => this._onSummon(name));
            this._box.add_child(button);
        }
    }
});

// 切り替えたモニタの中央に、ワークスペース名とモニタ番号を短時間表示する。
export class MonitorFlash {
    constructor() {
        this._labels = new Map(); // monitor -> actor
    }

    show(monitor, name) {
        this._labels.get(monitor)?.destroy();
        const geometry = Main.layoutManager.monitors[monitor];
        if (!geometry)
            return;
        const box = new St.BoxLayout({ style_class: 'aerogrid-flash', vertical: true });
        box.add_child(new St.Label({ text: name ?? '-', style_class: 'aerogrid-flash-workspace', x_align: Clutter.ActorAlign.CENTER }));
        box.add_child(new St.Label({ text: `モニタ ${monitor + 1}`, style_class: 'aerogrid-flash-monitor', x_align: Clutter.ActorAlign.CENTER }));
        Main.uiGroup.add_child(box);
        const [, width] = box.get_preferred_width(-1);
        const [, height] = box.get_preferred_height(width);
        box.set_position(geometry.x + Math.floor((geometry.width - width) / 2),
            geometry.y + Math.floor((geometry.height - height) / 2));
        this._labels.set(monitor, box);
        box.ease({
            opacity: 0, delay: 450, duration: 250, mode: Clutter.AnimationMode.EASE_OUT_QUAD,
            onComplete: () => {
                if (this._labels.get(monitor) === box)
                    this._labels.delete(monitor);
                box.destroy();
            },
        });
    }

    destroy() {
        for (const box of this._labels.values())
            box.destroy();
        this._labels.clear();
    }
}
