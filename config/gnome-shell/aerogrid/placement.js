// Raycast の Window Management 相当の配置計算。GNOME 非依存 (Node でテストする)。
// area: ウィンドウがあるモニタの作業領域 (パネルと Dock を除く) { x, y, width, height }。

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
