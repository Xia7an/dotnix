# GNOME AeroGrid (Odin)

Lachesis の AeroSpace (floating 運用) + Hammerspoon の Option+Tab グリッドを、
Ubuntu 24.04 標準の GNOME 46 (Mutter / X11) で再現する。キーボードは Magic Keyboard。

| macOS (Lachesis) | GNOME (Odin) |
| --- | --- |
| AeroSpace の floating | GNOME 標準 (もともと floating) |
| 32 個の名前付きワークスペース | `dynamic-workspaces=false`。数と名前は AeroGrid が設定 |
| `on-window-detected` | AeroGrid の `RULES` (WM_CLASS で判定) |
| Option+文字 (`summon-workspace`) | Option+文字。GNOME のワークスペースは全モニタ共通 |
| Option+Shift+文字 (`move-node-to-workspace`) | 同じ。移動したウィンドウには追従しない |
| Option+Tab (Hammerspoon グリッド) | AeroGrid のグリッド |
| Command+Tab (alt-tab-macos) | GNOME の `switch-windows` (全ワークスペース) |
| Dock 自動非表示 | Ubuntu Dock を下・自動非表示 |

Magic Keyboard は Linux の `hid_apple` で Option = Alt、Command = Super になる。
そのため AeroGrid は Alt を、GNOME のウィンドウスイッチャーは Super を使う。

## グリッドの操作

Hammerspoon 版 (`docs/aerospace-window-grid.md`) と同じ。

| 操作 | 動作 |
| --- | --- |
| Option + Tab | 一覧を開く。初期選択は現在のウィンドウ |
| h / l、左右キー | 同じワークスペース内の前後のウィンドウ |
| j / k、上下キー | 下 / 上のワークスペース |
| Option を離す | 選択したウィンドウのワークスペースへ移ってフォーカス |
| Esc、一覧の外をクリック | 何も変えずに閉じる |

最大 4 列 × 6 行。行ごとに選択と横スクロールを保持し、選択に 1 項目ずつ追従する。
プレビューは `Clutter.Clone` によるライブ表示で、画像を保持しない。
最小化中のウィンドウはアプリのアイコンで表示する。

## 構成

- `config/gnome-shell/aerogrid/`: 拡張本体 (UUID `aerogrid@inoyu`)
  - `config.js`: 修飾キー、ワークスペース一覧、アプリの割り当てルール
  - `extension.js`: キー登録、ワークスペース設定、割り当て
  - `grid.js`: グリッドの UI
  - `model.js`: グリッドの状態 (GNOME 非依存、テスト対象)
- `modules/Home/desktop/gnome/`: Home Manager モジュール
  - `workspaces.nix`: 固定ワークスペース、全モニタ共通
  - `keybindings.nix`: GNOME の Alt+Tab / Alt+` を外し、Command 側へ移す
  - `dock.nix`: Ubuntu Dock
  - `aerogrid.nix`: 拡張を `~/.local/share/gnome-shell/extensions/` へリンクして有効化
- `hosts/Odin/`: `template/linux-general-desktop` を元にしたホスト

## 適用

```sh
home-manager switch --flake .#OdinHome
```

初回はその後ログアウトして再ログインする (GNOME Shell が新しい拡張を読むため)。
`enabled-extensions` は Home Manager が丸ごと置き換える。Ubuntu Dock などの標準拡張は
セッションモード側で有効になるので影響しないが、手動で入れた拡張は `aerogrid.nix` に追加する。

拡張はリポジトリ (`~/Gits/dotnix`) へ直接リンクしている。`config.js` などを編集したら
switch は不要で、`Alt+F2` → `r` → Enter で GNOME Shell を再起動すれば反映される (X11 のみ)。

## ルールの追加

`xprop WM_CLASS` を実行してウィンドウをクリックすると `WM_CLASS = "instance", "Class"` が出る。
どちらかに一致する正規表現を `config.js` の `RULES` に足す。割り当ては新しく開いた
ウィンドウだけに適用し、既存のウィンドウは動かさない。

## トラブルシュート

```sh
journalctl -f -o cat /usr/bin/gnome-shell   # 拡張のログとエラー
gnome-extensions info aerogrid@inoyu         # 状態 (ACTIVE / ERROR)
gsettings list-recursively | grep -E "<Alt>[a-z0-9]'|<Alt>Tab"   # キーの衝突確認
```

`AeroGrid: <Alt>... を登録できません` と出たら、同じキーを GNOME や別のアプリが使っている。

## テスト

```sh
node tests/gnome-aerogrid-model-test.mjs
```

並び順、初期選択、端での停止、行ごとの横スクロールと位置の復元、6 行を超える縦スクロール、
画面内への収まりを確認する。実機では、複数ワークスペースにウィンドウを置いて Option+Tab を押し、
hjkl で枠だけが動くこと、Option を離すと別のワークスペースのウィンドウに移れることを確認する。

## 制限

- GNOME のワークスペースは全モニタで共通。AeroSpace のようにモニタごとに別のワークスペースを
  表示する `summon-workspace` や `move-workspace-to-monitor` は再現していない。
- L (Looking Glass Go) のモニタ固定は未対応。割り当てだけ行う。
- 対象は GNOME 46。GNOME 49 以降 (Ubuntu 26.04 など) では `metadata.json` の
  `shell-version` の追加と API の確認が必要。X11 セッションが無くなるため、
  `Alt+F2 r` による再読込も使えなくなる。
