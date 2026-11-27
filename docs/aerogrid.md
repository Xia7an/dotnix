# AeroGrid (Odin: NixOS + Hyprland)

Lachesis のデスクトップ (AeroSpace の floating 運用、Hammerspoon の Option+Tab グリッド、
alt-tab-macos、Raycast のウィンドウ配置) を、Odin の Hyprland + Quickshell で再現する。
キーボードは Magic Keyboard (Option = ALT、Command = SUPER)。GPU は RTX 2070 Super。

| macOS (Lachesis) | Odin |
| --- | --- |
| AeroSpace の floating | `windowrule = float, class:.*` |
| 32 個のワークスペース (モニタごとに別表示) | Hyprland のワークスペース (1〜9 は番号、他は `name:W` など) |
| Option+文字 (`summon-workspace`) | `focusworkspaceoncurrentmonitor`。別のモニタに表示中なら入れ替える |
| Option+Shift+文字 (`move-node-to-workspace`) | `movetoworkspacesilent` (追従しない) |
| `on-window-detected` | `config/hypr/aerogrid/rules.conf` |
| `move-mouse monitor-lazy-center` | `cursor:warp_on_change_workspace` |
| Option+Tab (Hammerspoon グリッド) | Quickshell の `WindowGrid.qml` |
| Command+Tab (alt-tab-macos) | Quickshell の `WindowSwitcher.qml` |
| Option+Control+hjkl/Space (Raycast) | Quickshell の `WindowPlacement.qml` |
| メニューバー | Quickshell の `Bar.qml` (モニタごと) |
| Raycast (Command+Space) | rofi |
| 画面ロック (Control+Command+Q) | hyprlock |

操作中のモニタは、マウスがあるモニタ (Hyprland の focused monitor)。フォーカスは
クリックで移る (`follow_mouse = 2`、macOS と同じ)。H/J/K と L にはキーを割り当てない
(L は Looking Glass Go 専用)。

## 上部バー

モニタごとに 1 本。左にワークスペースを数字 → 名前の順で並べる。

| 表示 | 意味 |
| --- | --- |
| 青の塗りつぶし | このモニタに表示中で、このモニタが操作中 |
| 灰の塗りつぶし | このモニタに表示中 (操作中のモニタは別) |
| 青の枠 | 別のモニタに表示中 |
| 薄い文字 | 隠れているがウィンドウがある |

クリックすると、そのワークスペースをこのモニタに呼ぶ。中央はこのモニタでフォーカス中の
ウィンドウのタイトル、右はシステムトレイと時計。

## グリッド (Option+Tab)

Hammerspoon 版 (`docs/aerospace-window-grid.md`) と同じ。

| 操作 | 動作 |
| --- | --- |
| Option + Tab | 一覧を開く。初期選択は現在のウィンドウ |
| h / l、左右キー | 同じワークスペース内の前後のウィンドウ |
| j / k、上下キー | 下 / 上のワークスペース |
| Option を離す | 選んだウィンドウにフォーカス (隠れていれば、そのワークスペースを元のモニタに表示) |
| Esc、外側のクリック | 何も変えずに閉じる |

最大 4 列 × 6 行。行ごとに選択と横スクロールを保持する。プレビューは
`hyprland-toplevel-export` で取得し、取れないときはアプリのアイコンを出す。

Option を Tab よりかなり早く離すと、一覧がキーボードを受け取る前に離したことになり、
開いたままになることがある。その場合は Esc で閉じるか、Option を押して離すと確定する。

## ウィンドウスイッチャー (Command+Tab)

全ワークスペースのウィンドウを最近使った順に並べる。Command+Tab で次、Command+Shift+Tab で前、
左右キーでも移動し、Command を離すとフォーカスする。1 回目の Command+Tab では直前に使った
ウィンドウを選ぶ。

## ウィンドウ配置 (Option+Control)

| 操作 | 動作 |
| --- | --- |
| Option + Control + H / L | 左半分 / 右半分 |
| Option + Control + K / J | 上半分 / 下半分 |
| Option + Control + Space | 作業領域 (バーを除く) いっぱい |

全画面のウィンドウは動かさない。

## 構成

- `config/hypr/aerogrid/`: Hyprland の設定 (`~/.config/hypr/aerogrid/` へリンク)
  - `hyprland.conf`: 入力、見た目、起動するもの
  - `keybinds.conf`: キー割り当て
  - `rules.conf`: floating と、アプリごとのワークスペース
  - `nvidia.conf`: NVIDIA 用の環境変数
- `config/quickshell/aerogrid/`: Quickshell の設定 (`~/.config/quickshell/aerogrid/` へリンク)
  - `shell.qml`、`Bar.qml`、`WindowGrid.qml`、`WindowSwitcher.qml`、`WindowPlacement.qml`、
    `WindowCard.qml`、`Theme.qml`
  - `model.mjs`: グリッドの状態とレイアウト (Quickshell 非依存、テスト対象)
  - `placement.mjs`: ウィンドウ配置と作業領域の計算 (Quickshell 非依存、テスト対象)
- `modules/Home/desktop/aerogrid/`: 上の 2 つのリンク、Hyprland の Home Manager 設定
  (本体はシステム側を使い、`hyprland-session.target` だけ用意する)、Quickshell など
- `modules/NixOS/desktop/hyprland-aerogrid.nix`: Hyprland 本体、ポータル、hyprlock の PAM、PipeWire
- `hosts/Odin/`: NixOS ホスト

Quickshell が受け取るキーは、`keybinds.conf` の `global, aerogrid:<名前>` と
QML の `GlobalShortcut { appid: "aerogrid"; name: "<名前>" }` の組で対応する。

## セットアップ

1. RTX 2070 Super に換装し、NixOS をインストールする (UEFI)。
2. このリポジトリを `~/Gits/dotnix` に置く (設定ファイルのリンク先)。
3. ハードウェア設定を実機のものに置き換える。仮のファイルのままだと assertion で止まる。

   ```sh
   sudo nixos-generate-config --show-hardware-config > hosts/Odin/hardware.nix
   ```

4. 適用する。

   ```sh
   sudo nixos-rebuild switch --flake .#Odin
   home-manager switch --flake .#OdinHome
   ```

5. ログイン画面 (GDM) で Hyprland を選んでログインする。

NVIDIA のドライバは unfree のため公式のバイナリキャッシュに無く、手元でビルドされる。

## 調整

- アプリの class は `hyprctl clients` で確認して `rules.conf` に書く。
- `config/hypr/aerogrid/` と `config/quickshell/aerogrid/` は保存すると自動で再読込される。
  Quickshell のログは `qs -c aerogrid log`、Hyprland の設定エラーは画面上部に表示される。
- 入力メソッドは fcitx5 + Mozc (US 配列)。

## テスト

```sh
node tests/aerogrid-model-test.mjs
```

グリッドの並び順、初期選択、端での停止、行ごとの横スクロールと位置の復元、6 行を超える縦スクロール、
画面内への収まり、文字が枠に収まって重ならないこと、ウィンドウ配置の矩形、
モニタ情報からの作業領域 (倍率、回転、バーの領域) を確認する。
