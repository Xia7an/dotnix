// 上部バーのワークスペース表示。ウィンドウがあるワークスペースと表示中のワークスペースを並べ、
// 操作中のモニタのものを塗りつぶし、別のモニタに表示中のものを枠で示す。クリックで呼び出す。
import Clutter from 'gi://Clutter';
import GObject from 'gi://GObject';
import St from 'gi://St';

import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

export const WorkspaceIndicator = GObject.registerClass(
class WorkspaceIndicator extends PanelMenu.Button {
    // onActivate(name): 項目をクリックしたときに呼ぶ。
    _init(onActivate) {
        super._init(0.0, 'AeroGrid Workspaces', true);
        this._onActivate = onActivate;
        this._box = new St.BoxLayout({ style_class: 'aerogrid-indicator', y_align: Clutter.ActorAlign.CENTER });
        this.add_child(this._box);
        this._key = '';
    }

    // items: workspaces.js の indicatorItems() の結果。
    update(items) {
        const key = items.map(item => `${item.name}:${item.state}`).join(' ');
        if (key === this._key)
            return;
        this._key = key;
        this._box.destroy_all_children();
        for (const item of items) {
            const button = new St.Button({
                style_class: `aerogrid-ws aerogrid-ws-${item.state}`,
                label: item.name,
                y_align: Clutter.ActorAlign.CENTER,
            });
            button.connect('clicked', () => this._onActivate(item.name));
            this._box.add_child(button);
        }
    }
});
