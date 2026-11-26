// モニタごとに表示する仮想ワークスペースの管理 (AeroSpace と同じモデル)。
// GNOME 非依存 (Node でテストする)。ウィンドウの表示・非表示は extension.js が行う。
//
// - 各モニタは常にちょうど 1 つのワークスペースを表示する。
// - 同じワークスペースを 2 つのモニタに同時に表示することはない。
// - summon: 指定のワークスペースを指定のモニタに表示する。別のモニタに表示中なら、
//   そのモニタとワークスペースを入れ替える (どのウィンドウも見えなくならない)。

export class MonitorWorkspaces {
    // names: ワークスペース名の一覧 (並び順は config.js の WORKSPACES)。
    // saved: 前回の表示状態 (モニタ番号 → 名前)。無効な値は無視する。
    // isEmpty(name): そのワークスペースにウィンドウが無いか。空きの選択に使う。
    constructor(names, monitorCount, saved = [], isEmpty = () => true) {
        this.names = [...names];
        this.visible = [];
        for (let monitor = 0; monitor < monitorCount; monitor++) {
            const name = saved[monitor];
            this.visible.push(this.names.includes(name) && !this.visible.includes(name) ? name : null);
        }
        // 1 つずつ埋める (埋めた名前が次の選択から外れるように)。
        for (let monitor = 0; monitor < monitorCount; monitor++)
            this.visible[monitor] ??= this._claimFree(isEmpty);
    }

    get monitorCount() {
        return this.visible.length;
    }

    visibleOn(monitor) {
        return this.visible[monitor] ?? null;
    }

    // 表示中のモニタ番号。表示されていなければ -1。
    monitorOf(name) {
        return this.visible.indexOf(name);
    }

    isVisible(name) {
        return this.monitorOf(name) >= 0;
    }

    // 戻り値: 表示が変わったモニタの一覧 [{ monitor, from, to }]。
    // from のうち、どのモニタにも表示されなくなったものは非表示にする必要がある。
    summon(name, monitor) {
        if (!this.names.includes(name) || monitor < 0 || monitor >= this.visible.length)
            return [];
        const current = this.visible[monitor];
        if (current === name)
            return [];
        const other = this.monitorOf(name);
        this.visible[monitor] = name;
        const changes = [{ monitor, from: current, to: name }];
        if (other >= 0) {
            this.visible[other] = current;
            changes.push({ monitor: other, from: name, to: current });
        }
        return changes;
    }

    // モニタの数が変わったとき。外れたモニタのワークスペースは非表示になり、
    // 増えたモニタには表示されていないワークスペース (空きを優先) を割り当てる。
    // 戻り値: { hidden: [名前], shown: [{ monitor, to }] }
    resize(monitorCount, isEmpty = () => true) {
        const hidden = this.visible.slice(monitorCount);
        this.visible = this.visible.slice(0, monitorCount);
        const shown = [];
        while (this.visible.length < monitorCount) {
            const to = this._claimFree(isEmpty);
            this.visible.push(to);
            shown.push({ monitor: this.visible.length - 1, to });
        }
        return { hidden, shown };
    }

    // 表示されていないワークスペースのうち、空のものを優先して先頭から選ぶ。
    _claimFree(isEmpty) {
        const free = this.names.filter(name => !this.visible.includes(name));
        return free.find(name => isEmpty(name)) ?? free[0] ?? null;
    }
}

// 上部バーに出す項目。ウィンドウがあるか、どこかのモニタに表示中のワークスペースを
// config.js の並び順で返す。state は focused (操作中のモニタ) / visible (別のモニタに表示中)
// / occupied (非表示だがウィンドウがある)。
export function indicatorItems(workspaces, occupied, focusedMonitor) {
    return workspaces.names
        .filter(name => occupied.has(name) || workspaces.isVisible(name))
        .map(name => {
            const monitor = workspaces.monitorOf(name);
            const state = monitor < 0 ? 'occupied' : monitor === focusedMonitor ? 'focused' : 'visible';
            return { name, state, monitor };
        });
}
