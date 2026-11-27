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
