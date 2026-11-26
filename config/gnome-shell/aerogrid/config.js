// AeroGrid の設定 (config/aerospace/aerospace.toml の GNOME 版)。
// 編集後は Alt+F2 → r (X11) で GNOME Shell を再起動すれば反映される。

// Magic Keyboard では hid_apple により Option = Alt、Command = Super。
// macOS と同じ物理キー (Option) で操作するため Alt を使う。
export const MODIFIER = '<Alt>';

// ワークスペースの並び = GNOME のワークスペース番号順 (0 始まり)。
// 拡張が有効になると num-workspaces と workspace-names をこの一覧に合わせる。
// H/J/K は AeroSpace と同じく欠番 (macOS 側で Option+hjkl をフォーカス移動に使っていたため)。
export const WORKSPACES = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'I', 'M', 'N', 'O', 'P', 'Q',
    'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'L',
];

// キーを割り当てないワークスペース (macOS 側でも L はキーなし)。
export const KEYLESS = ['L'];

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
