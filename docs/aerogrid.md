# AeroGrid (Odin: NixOS + Hyprland)

Lachesis のデスクトップ (AeroSpace の floating 運用、Hammerspoon の Option+Tab グリッド、
alt-tab-macos、Raycast) を、Odin の Hyprland + noctalia + Quickshell で再現する。
シェル (バー、ランチャー、通知、壁紙、画面ロック、認証ダイアログ、Command+Tab) は noctalia v5 に
まとめ、noctalia に無い Option+Tab のグリッドとウィンドウ配置だけを AeroGrid (Quickshell) で補う。
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
| Command+Tab (alt-tab-macos) | noctalia のウィンドウスイッチャー |
| Option+Control+hjkl/Space (Raycast) | Quickshell の `WindowPlacement.qml` |
| メニューバー | noctalia のバー (モニタごと) |
| Raycast (Command+Space) | noctalia のランチャー |
| 画面ロック (Control+Command+Q) | noctalia のロック画面 |
| 通知、壁紙、認証ダイアログ | noctalia |

操作中のモニタは、マウスがあるモニタ (Hyprland の focused monitor)。フォーカスは
クリックで移る (`follow_mouse = 2`、macOS と同じ)。H/J/K と L にはキーを割り当てない
(L は Looking Glass Go 専用)。

## 上部バー (noctalia)

モニタごとに 1 本。左からランチャー、そのモニタのワークスペース、フォーカス中のウィンドウ、
中央に時計 (日付・曜日・秒)、右にトレイ、通知、ネットワーク、Bluetooth、音量、
コントロールセンター、セッション (ロック・ログアウトなど)。

ワークスペースは、各バーにそのモニタのものを出す。操作中のモニタ (マウスがあるモニタ) の
表示中ワークスペースだけを強調し、他のモニタの表示中ワークスペースは控えめな色になる
(`[widget.workspaces].focused_output_only`)。

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

## ウィンドウスイッチャー (Command+Tab、noctalia)

全モニタ・全ワークスペースのウィンドウを最近使った順に並べる (`[shell.window_switcher]`)。
Command+Tab で次、Command+Shift+Tab で前、Command を離すとフォーカスする。Command+Tab を
素早く押して離すと、直前に使ったウィンドウへ切り替わる。Esc で取消。

## ランチャー (Command+Space、noctalia)

アプリの検索と起動のほか、計算、絵文字、ウィンドウ検索などを同じ入力欄で使える。

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
- `config/noctalia/config.toml`: noctalia の設定 (`~/.config/noctalia/config.toml` へリンク)。
  設定画面で変えた値は `~/.config/noctalia/settings.toml` に保存され、こちらより優先される。
- `config/quickshell/aerogrid/`: AeroGrid の設定 (`~/.config/quickshell/aerogrid/` へリンク)
  - `shell.qml`、`WindowGrid.qml`、`WindowPlacement.qml`、`WindowCard.qml`、`Theme.qml`
  - `model.mjs`: グリッドの状態とレイアウト (Quickshell 非依存、テスト対象)
  - `placement.mjs`: ウィンドウ配置と作業領域の計算 (Quickshell 非依存、テスト対象)
- `modules/Home/desktop/aerogrid/`: 上の 3 つのリンク、Hyprland の Home Manager 設定
  (本体はシステム側を使い、`hyprland-session.target` だけ用意する)、noctalia、Quickshell など。
  noctalia v5 は nixpkgs unstable にだけあるので `pkgs.unstable.noctalia` を使う (キャッシュあり)。
- `modules/NixOS/desktop/hyprland-aerogrid.nix`: Hyprland 本体、ポータル、polkit、upower、
  power-profiles-daemon、PipeWire。ロック画面は PAM の `login` サービスで認証する。
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
  noctalia のログは `~/.cache/noctalia/noctalia.log`、AeroGrid のログは `qs -c aerogrid log`、
  Hyprland の設定エラーは画面上部に表示される。
- noctalia の設定項目は `noctalia msg config-get <項目>` で確認でき、全項目の既定値は上流の
  `example.toml` にある。macOS の Dock に当たる `[dock]` もある (未設定)。
- 入力メソッドは fcitx5 + Mozc (US 配列)。

## テスト

```sh
node tests/aerogrid-model-test.mjs
```

グリッドの並び順、初期選択、端での停止、行ごとの横スクロールと位置の復元、6 行を超える縦スクロール、
画面内への収まり、文字が枠に収まって重ならないこと、ウィンドウ配置の矩形、
モニタ情報からの作業領域 (倍率、回転、バーの領域) を確認する。
