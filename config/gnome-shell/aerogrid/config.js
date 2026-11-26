// AeroGrid の設定 (config/aerospace/aerospace.toml の GNOME 版)。
// 編集後は Alt+F2 → r (X11) で GNOME Shell を再起動すれば反映される。

// Magic Keyboard では hid_apple により Option = Alt、Command = Super。
// macOS と同じ物理キー (Option) で操作するため Alt を使う。
export const MODIFIER = '<Alt>';

// 仮想ワークスペースの一覧。グリッドと上部バーもこの順に並べる
// (グリッドは数字を先に数値順、残りを名前順)。
// GNOME 自体のワークスペースは 1 つにまとめ、各モニタがこの中から 1 つずつ表示する。
// H/J/K は AeroSpace と同じく欠番 (macOS 側で Option+hjkl をフォーカス移動に使っていたため)。
export const WORKSPACES = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'I', 'M', 'N', 'O', 'P', 'Q',
    'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'L',
];

// キーを割り当てないワークスペース (macOS 側でも L はキーなし)。
export const KEYLESS = ['L'];

// ワークスペースを別のモニタに呼んだとき、マウスをそのモニタの中央へ移す
// (Lachesis の on-focused-monitor-changed = 'move-mouse monitor-lazy-center' と同じ)。
// GNOME は新しいウィンドウをマウスのあるモニタに開くので、開く先もそろう。
export const MOUSE_FOLLOWS_FOCUS = true;

// true にすると、切り替えのたびにモニタ構成とウィンドウの移動を journal に出す。
// 確認: journalctl -f -o cat /usr/bin/gnome-shell | grep AeroGrid
export const DEBUG = true;

// ウィンドウ配置 (Raycast の Window Management 相当)。Option+Control+キー。
// 値は placement.js の PLACEMENTS のいずれか。maximize は GNOME の最大化状態にはせず、
// 作業領域いっぱいに広げるだけ (Raycast と同じ)。
export const PLACEMENT_MODIFIER = '<Control><Alt>';
export const PLACEMENT_KEYS = {
    h: 'left-half',
    j: 'bottom-half',
    k: 'top-half',
    l: 'right-half',
    space: 'maximize',
};

// 新しいウィンドウの自動割り当て (on-window-detected 相当)。
// match は X11 の WM_CLASS (class と instance の両方) に対して評価する。
// 実機の値は `xprop WM_CLASS` を実行してウィンドウをクリックすると分かる。
// 最初に一致したルールだけが適用される。
export const RULES = [
    { match: /^LookinGirl$/, workspace: 'L' }, // Looking Glass Go (Unity)

    { match: /^google-chrome$/i, workspace: 'W' },
    { match: /^com\.mitchellh\.ghostty$/i, workspace: 'T' },
    { match: /^code$/i, workspace: 'T' }, // VS Code
    { match: /^dev\.zed\.Zed$/i, workspace: 'T' },
    { match: /^unityhub$/i, workspace: 'U' },

    { match: /^chatgpt$/i, workspace: 'A' }, // 要確認: ChatGPT Linux preview
    { match: /^(evince|org\.gnome\.Evince|org\.gnome\.Papers|org\.gnome\.Loupe)$/i, workspace: 'S' }, // プレビュー相当
    { match: /^discord$/i, workspace: 'D' },
    { match: /^slack$/i, workspace: 'D' },
    { match: /^parsecd$/i, workspace: 'V' },
    { match: /^org\.prismlauncher\.PrismLauncher$/i, workspace: 'M' },
    { match: /^zoom$/i, workspace: 'Z' },
];
