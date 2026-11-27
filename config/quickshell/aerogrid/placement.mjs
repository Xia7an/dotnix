// Raycast の Window Management 相当の配置計算。Quickshell 非依存 (Node でテストする)。
// area: ウィンドウがあるモニタの作業領域 (バーを除く) { x, y, width, height }。
// 座標は Hyprland のレイアウト座標 (論理ピクセル)。

export const PLACEMENTS = ['left-half', 'right-half', 'top-half', 'bottom-half', 'maximize'];

export function placementRect(area, placement) {
    const { x, y, width, height } = area;
    const left = Math.floor(width / 2);
    const top = Math.floor(height / 2);
    switch (placement) {
    case 'left-half': return { x, y, width: left, height };
    case 'right-half': return { x: x + left, y, width: width - left, height };
    case 'top-half': return { x, y, width, height: top };
    case 'bottom-half': return { x, y: y + top, width, height: height - top };
    case 'maximize': return { x, y, width, height };
    default: throw new Error(`unknown placement: ${placement}`);
    }
}

// `hyprctl monitors -j` のモニタ情報から作業領域を求める。
// width/height は物理ピクセルなので scale で割り、90°/270° 回転 (transform が奇数) なら縦横を入れ替える。
// reserved はバーなどが確保した [左, 上, 右, 下] (論理ピクセル)。
export function workArea(monitor) {
    const rotated = (monitor.transform ?? 0) % 2 === 1;
    const scale = monitor.scale || 1;
    const width = Math.round((rotated ? monitor.height : monitor.width) / scale);
    const height = Math.round((rotated ? monitor.width : monitor.height) / scale);
    const [left, top, right, bottom] = monitor.reserved ?? [0, 0, 0, 0];
    return {
        x: monitor.x + left,
        y: monitor.y + top,
        width: width - left - right,
        height: height - top - bottom,
    };
}

// 作業領域の辺からこの距離 (論理ピクセル) 以内なら、その辺に吸着しているとみなす。
export const SNAP_DISTANCE = 8;

// ワークスペースを別のモニタへ移したとき、ウィンドウの矩形 rect を移動元の作業領域 from から
// 移動先の作業領域 to へ移す。
// - 横と縦の両方で作業領域の辺に吸着しているもの (半分・全体に置いたものなど) は、
//   作業領域に対する比率を保って拡大縮小し、吸着していた辺は移動先でも吸着させる。
// - それ以外はサイズを保ち、中心の相対位置だけを移す。
// どちらも最後に移動先の作業領域へ収める (入りきらなければ縮める)。
export function fitRect(rect, from, to) {
    const near = (a, b) => Math.abs(a - b) <= SNAP_DISTANCE;
    const touches = {
        left: near(rect.x, from.x),
        top: near(rect.y, from.y),
        right: near(rect.x + rect.width, from.x + from.width),
        bottom: near(rect.y + rect.height, from.y + from.height),
    };
    const snapped = (touches.left || touches.right) && (touches.top || touches.bottom);
    const sx = from.width > 0 ? to.width / from.width : 1;
    const sy = from.height > 0 ? to.height / from.height : 1;

    const width = Math.max(1, Math.min(snapped ? Math.round(rect.width * sx) : rect.width, to.width));
    const height = Math.max(1, Math.min(snapped ? Math.round(rect.height * sy) : rect.height, to.height));

    const cx = from.width > 0 ? (rect.x + rect.width / 2 - from.x) / from.width : 0.5;
    const cy = from.height > 0 ? (rect.y + rect.height / 2 - from.y) / from.height : 0.5;
    let x = Math.round(to.x + cx * to.width - width / 2);
    let y = Math.round(to.y + cy * to.height - height / 2);
    if (snapped) {
        if (touches.left) x = to.x;
        else if (touches.right) x = to.x + to.width - width;
        if (touches.top) y = to.y;
        else if (touches.bottom) y = to.y + to.height - height;
    }
    x = Math.min(Math.max(x, to.x), to.x + to.width - width);
    y = Math.min(Math.max(y, to.y), to.y + to.height - height);
    return { x, y, width, height };
}

// ワークスペース workspaceId をモニタ oldMonitor から newMonitor へ移した直後の調整内容を求める。
// clients: `hyprctl -j clients`、モニタは `hyprctl -j monitors` の要素 (oldMonitor は無くてもよい)。
// Hyprland は floating のウィンドウをモニタの位置の差だけ平行移動しているので、移動元での矩形に戻してから移す。
// 移動元が分からない (取り外されたなど) ときは、移動先の作業領域に収めるだけにする。
// 戻り値: 変更が必要なウィンドウの [{ address, rect }]。
export function fitWorkspaceWindows(clients, workspaceId, oldMonitor, newMonitor) {
    const to = workArea(newMonitor);
    const from = oldMonitor ? workArea(oldMonitor) : to;
    const dx = oldMonitor ? oldMonitor.x - newMonitor.x : 0;
    const dy = oldMonitor ? oldMonitor.y - newMonitor.y : 0;
    const result = [];
    for (const c of clients) {
        if (c.workspace?.id !== workspaceId || !c.floating || c.pinned || c.fullscreen || c.hidden || c.mapped === false)
            continue;
        const rect = { x: c.at[0] + dx, y: c.at[1] + dy, width: c.size[0], height: c.size[1] };
        const fitted = fitRect(rect, from, to);
        if (fitted.x !== c.at[0] || fitted.y !== c.at[1] || fitted.width !== c.size[0] || fitted.height !== c.size[1])
            result.push({ address: c.address, rect: fitted });
    }
    return result;
}
